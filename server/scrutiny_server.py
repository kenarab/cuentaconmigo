#!/usr/bin/env python3
"""Prototype scrutiny backend: capture ingestion, immutable evidence and server OCR.

Implements a subset of the /v1 API in sdd/specs/scrutiny-backend/SPEC.md with the
Python standard library only (no installs): http.server, sqlite3 and the local
`tesseract` binary. FastAPI can replace the HTTP layer later without changing the API.

Run:   python3 server/scrutiny_server.py            # 127.0.0.1:8740
Env:   CC_ENROLL_CODE (default: a random code printed at start), CC_DATA_DIR,
       CC_HOST, CC_PORT. Data lives in .runtime/scrutiny/ (git-ignored).
       CC_PUBLIC=1 hardens for exposure behind a TLS reverse proxy: it refuses weak
       enrollment codes, makes codes single-use when given in CC_ENROLL_CODES_FILE
       (one per line), and trusts X-Forwarded-For only with CC_TRUST_PROXY=1.
"""
import hashlib
import json
import os
import queue
import re
import secrets
import sqlite3
import subprocess
import sys
import tempfile
import threading
import time
from collections import defaultdict, deque
import uuid
from datetime import datetime, timezone
from http import HTTPStatus
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

import readings

ROOT = Path(__file__).resolve().parents[1]
DATA = Path(os.environ.get("CC_DATA_DIR", ROOT / ".runtime/scrutiny"))
BLOBS = DATA / "blobs"
VERSION = "0.1.0"
ENROLL_CODE = os.environ.get("CC_ENROLL_CODE") or secrets.token_urlsafe(18)
CODES_FILE = os.environ.get("CC_ENROLL_CODES_FILE")
# Shared code bundled in the team's app builds (zero-config); rate limited like any enrollment.
APP_CODE = os.environ.get("CC_APP_ENROLL_CODE")
# Test mode decided by the owner (31/10/2026): accept a weak shared code such as "0000".
OPEN_TEST = os.environ.get("CC_OPEN_TEST") == "1"
PUBLIC = os.environ.get("CC_PUBLIC") == "1"
TRUST_PROXY = os.environ.get("CC_TRUST_PROXY") == "1"
MAX_BLOB = 15 * 1024 * 1024
MAX_QUEUE = 500
# Requests allowed per window: (count, seconds).
LIMITS = {"enroll": (5, 600), "ip": (240, 60), "capture": (120, 3600), "reading": (60, 3600)}
_hits = defaultdict(deque)
_hits_lock = threading.Lock()


def allowed(kind, key):
    """Sliding-window rate limit kept in memory (enough for one prototype process)."""
    count, window = LIMITS[kind]
    t = time.monotonic()
    with _hits_lock:
        q = _hits[(kind, key)]
        while q and t - q[0] > window:
            q.popleft()
        if len(q) >= count:
            return False
        q.append(t)
        return True


def take_enroll_code(code):
    """Single-use codes from CC_ENROLL_CODES_FILE, the app-build code, or the shared CC_ENROLL_CODE."""
    if APP_CODE and secrets.compare_digest(code, APP_CODE):
        return True
    if CODES_FILE:
        with DB_LOCK:
            path = Path(CODES_FILE)
            codes = [c.strip() for c in path.read_text().splitlines() if c.strip()]
            for c in codes:
                if secrets.compare_digest(c, code):
                    path.write_text("\n".join(x for x in codes if x != c) + "\n")
                    return True
        return False
    return secrets.compare_digest(code, ENROLL_CODE)
SHA_RE = re.compile(r"^[0-9a-f]{64}$")
JOBS: "queue.Queue[str]" = queue.Queue()
DB_LOCK = threading.Lock()


def now():
    return datetime.now(timezone.utc).isoformat(timespec="seconds")


def db():
    conn = sqlite3.connect(DATA / "scrutiny.db", check_same_thread=False)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    BLOBS.mkdir(parents=True, exist_ok=True)
    with db() as c:
        c.executescript("""
        PRAGMA journal_mode=WAL;
        CREATE TABLE IF NOT EXISTS devices (id TEXT PRIMARY KEY, token_hash TEXT UNIQUE, platform TEXT, created_at TEXT);
        CREATE TABLE IF NOT EXISTS captures (id TEXT PRIMARY KEY, device_id TEXT, body TEXT, body_sha256 TEXT, received_at TEXT);
        CREATE TABLE IF NOT EXISTS pages (capture_id TEXT, page INTEGER, sha256 TEXT, PRIMARY KEY (capture_id, sha256));
        CREATE TABLE IF NOT EXISTS chain (idx INTEGER PRIMARY KEY AUTOINCREMENT, capture_id TEXT, body_sha256 TEXT,
                                          received_at TEXT, prev_hash TEXT, chain_hash TEXT);
        CREATE TABLE IF NOT EXISTS ocr (sha256 TEXT PRIMARY KEY, status TEXT, engine TEXT, numbers TEXT, text TEXT, started_at TEXT, finished_at TEXT);
        CREATE TABLE IF NOT EXISTS audit (at TEXT, actor TEXT, action TEXT, target TEXT);
        """)


GENESIS = "0" * 64


def append_receipt(c, cid, body_sha):
    """Append-only hash chain: each receipt commits to every earlier one. Publishing the
    head (GET /v1/log/head) lets anyone check later that no receipt was removed or altered."""
    last = c.execute("SELECT chain_hash FROM chain ORDER BY idx DESC LIMIT 1").fetchone()
    prev = last["chain_hash"] if last else GENESIS
    at = now()
    chain_hash = hashlib.sha256(f"{prev}|{cid}|{body_sha}|{at}".encode()).hexdigest()
    cur = c.execute("INSERT INTO chain (capture_id, body_sha256, received_at, prev_hash, chain_hash) VALUES (?,?,?,?,?)",
                    (cid, body_sha, at, prev, chain_hash))
    return receipt_row(c.execute("SELECT * FROM chain WHERE idx=?", (cur.lastrowid,)).fetchone())


def receipt_row(r):
    return {"captureId": r["capture_id"], "bodySha256": r["body_sha256"], "receivedAt": r["received_at"],
            "index": r["idx"], "prevHash": r["prev_hash"], "chainHash": r["chain_hash"],
            "rule": "chainHash = sha256(prevHash|captureId|bodySha256|receivedAt)"}


def audit(c, actor, action, target):
    c.execute("INSERT INTO audit VALUES (?,?,?,?)", (now(), actor, action, target))


def tesseract_version():
    try:
        out = subprocess.run(["tesseract", "--version"], capture_output=True, text=True).stdout
        return out.split()[1] if out else "unknown"
    except OSError:
        return None


def ocr_worker():
    """Extracted values only: results are suggestions (origin "ocr"), never confirmed data."""
    while True:
        sha = JOBS.get()
        with DB_LOCK, db() as c:
            c.execute("UPDATE ocr SET status='running', started_at=? WHERE sha256=?", (now(), sha))
        status, numbers, text = "done", [], ""
        try:
            with tempfile.TemporaryDirectory() as tmp:
                for psm in ("11", "6"):
                    text += subprocess.run(["tesseract", str(BLOBS / sha), "-", "--psm", psm, "-l", "spa"],
                                           capture_output=True, text=True, timeout=120).stdout
            numbers = list(dict.fromkeys(int(n) for n in re.findall(r"\d+", text) if len(n) <= 4))
        except (OSError, subprocess.TimeoutExpired):
            status = "failed"
        with DB_LOCK, db() as c:
            c.execute("UPDATE ocr SET status=?, numbers=?, text=?, finished_at=? WHERE sha256=?",
                      (status, json.dumps(numbers), text, now(), sha))


def enqueue_ocr(c, sha):
    if JOBS.qsize() >= MAX_QUEUE:
        return  # stays unqueued; a later upload or restart retries it
    if c.execute("SELECT 1 FROM ocr WHERE sha256=?", (sha,)).fetchone() is None:
        c.execute("INSERT INTO ocr (sha256, status, engine) VALUES (?, 'queued', ?)",
                  (sha, f"tesseract-{tesseract_version()}"))
        JOBS.put(sha)


class Handler(BaseHTTPRequestHandler):
    server_version = "cuentaconmigo-scrutiny"
    sys_version = ""
    timeout = 30  # drop slow or idle connections

    def client_ip(self):
        if TRUST_PROXY and self.headers.get("X-Forwarded-For"):
            return self.headers["X-Forwarded-For"].split(",")[-1].strip()
        return self.client_address[0]

    def end_headers(self):
        self.send_header("X-Content-Type-Options", "nosniff")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()

    def handle_one_request(self):
        try:
            super().handle_one_request()
        except (ConnectionError, TimeoutError):
            self.close_connection = True

    def limited(self, kind="ip", key=None):
        if allowed(kind, key or self.client_ip()):
            return False
        self.problem(HTTPStatus.TOO_MANY_REQUESTS, "Demasiados pedidos", "Esperá un momento y probá de nuevo.")
        return True

    # --- helpers -----------------------------------------------------------
    def send_json(self, status, body, content_type="application/json"):
        data = json.dumps(body, ensure_ascii=False).encode()
        self.send_response(status)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def problem(self, status, title, detail=""):
        """RFC 9457 problem details."""
        self.send_json(status, {"type": "about:blank", "title": title, "status": int(status), "detail": detail},
                       "application/problem+json")

    def body(self, limit=MAX_BLOB):
        n = int(self.headers.get("Content-Length") or 0)
        if n > limit:
            raise ValueError("too large")
        return self.rfile.read(n)

    def device(self):
        """The device always comes from the token, never from the path (object-level authorization)."""
        auth = self.headers.get("Authorization", "")
        if not auth.startswith("Bearer "):
            return None
        token_hash = hashlib.sha256(auth[7:].encode()).hexdigest()
        with db() as c:
            row = c.execute("SELECT id FROM devices WHERE token_hash=?", (token_hash,)).fetchone()
        return row["id"] if row else None

    def log_message(self, fmt, *args):
        sys.stderr.write(f"{now()} {self.address_string()} {fmt % args}\n")

    # --- routes ------------------------------------------------------------
    def do_GET(self):
        if self.limited():
            return
        parts = [p for p in self.path.split("?")[0].split("/") if p]
        if parts == ["v1", "health"]:
            return self.send_json(HTTPStatus.OK, {"status": "ok", "version": VERSION, "time": now()})
        if parts == ["v1", "log", "head"]:
            with db() as c:
                r = c.execute("SELECT idx, chain_hash FROM chain ORDER BY idx DESC LIMIT 1").fetchone()
            return self.send_json(HTTPStatus.OK, {"index": r["idx"] if r else 0, "chainHash": r["chain_hash"] if r else GENESIS})
        if parts == ["v1", "ocr", "engines"]:
            return self.send_json(HTTPStatus.OK, {"engines": [{"engine": "tesseract", "version": tesseract_version(),
                                                               "languages": ["spa"], "metrics": "sdd/specs/scrutiny-backend/SPEC.md"}]})
        dev = self.device()
        if dev is None:
            return self.problem(HTTPStatus.UNAUTHORIZED, "Falta un token válido")
        if len(parts) in (3, 4) and parts[:2] == ["v1", "captures"]:
            with db() as c:
                cap = c.execute("SELECT * FROM captures WHERE id=? AND device_id=?", (parts[2], dev)).fetchone()
                if cap is None:
                    return self.problem(HTTPStatus.NOT_FOUND, "Captura inexistente")
                pages = c.execute("SELECT p.page, p.sha256, o.status, o.engine, o.numbers, o.started_at, o.finished_at "
                                  "FROM pages p LEFT JOIN ocr o ON o.sha256=p.sha256 WHERE p.capture_id=? ORDER BY p.page",
                                  (parts[2],)).fetchall()
            if len(parts) == 3:
                return self.send_json(HTTPStatus.OK, {
                    "id": cap["id"], "receivedAt": cap["received_at"],
                    "pages": [{"page": p["page"], "sha256": p["sha256"], "received": (BLOBS / p["sha256"]).exists(),
                               "ocr": p["status"]} for p in pages]})
            if parts[3] == "ocr":
                return self.send_json(HTTPStatus.OK, {"origin": "ocr", "results": [
                    {"page": p["page"], "engine": p["engine"], "status": p["status"] or "waiting-blob",
                     "numbers": json.loads(p["numbers"] or "[]"), "startedAt": p["started_at"],
                     "finishedAt": p["finished_at"]} for p in pages]})
        return self.problem(HTTPStatus.NOT_FOUND, "Ruta inexistente")

    def do_POST(self):
        if self.limited():
            return
        parts = [p for p in self.path.split("?")[0].split("/") if p]
        if parts == ["v1", "readings"]:
            return self.post_reading()
        try:
            raw = self.body(limit=1024 * 1024)
            payload = json.loads(raw or b"{}")
        except (ValueError, json.JSONDecodeError):
            return self.problem(HTTPStatus.BAD_REQUEST, "Cuerpo inválido")
        if parts == ["v1", "devices", "enroll"]:
            if self.limited("enroll"):
                return
            if not take_enroll_code(str(payload.get("enrollmentCode", ""))):
                return self.problem(HTTPStatus.FORBIDDEN, "Código de alta inválido")
            dev, token = str(uuid.uuid4()), secrets.token_urlsafe(32)
            with DB_LOCK, db() as c:
                c.execute("INSERT INTO devices VALUES (?,?,?,?)",
                          (dev, hashlib.sha256(token.encode()).hexdigest(), payload.get("platform", ""), now()))
                audit(c, dev, "enroll", dev)
            return self.send_json(HTTPStatus.CREATED, {"deviceId": dev, "deviceToken": token, "scopes": ["captures"]})
        dev = self.device()
        if dev is None:
            return self.problem(HTTPStatus.UNAUTHORIZED, "Falta un token válido")
        if parts == ["v1", "captures"]:
            if self.limited("capture", dev):
                return
            cid, pages = payload.get("id"), payload.get("pages") or []
            if not cid or not all(SHA_RE.match(str(p.get("sha256", ""))) for p in pages):
                return self.problem(HTTPStatus.UNPROCESSABLE_ENTITY, "Paquete inválido", "Falta id o un sha256 de página")
            body_sha = hashlib.sha256(raw).hexdigest()
            with DB_LOCK, db() as c:
                old = c.execute("SELECT device_id, body_sha256 FROM captures WHERE id=?", (cid,)).fetchone()
                if old and old["device_id"] != dev:
                    return self.problem(HTTPStatus.CONFLICT, "La captura pertenece a otro dispositivo")
                if old and old["body_sha256"] == body_sha:
                    status = HTTPStatus.OK
                    receipt = receipt_row(c.execute("SELECT * FROM chain WHERE capture_id=? AND body_sha256=? "
                                                    "ORDER BY idx DESC LIMIT 1", (cid, body_sha)).fetchone())
                else:
                    # New capture or a new version (draft edited, then confirmed): every version is kept.
                    status = HTTPStatus.CREATED
                    if old:
                        c.execute("UPDATE captures SET body=?, body_sha256=?, received_at=? WHERE id=?",
                                  (raw.decode(), body_sha, now(), cid))
                    else:
                        c.execute("INSERT INTO captures VALUES (?,?,?,?,?)", (cid, dev, raw.decode(), body_sha, now()))
                    for i, p in enumerate(pages, start=1):
                        c.execute("INSERT OR IGNORE INTO pages VALUES (?,?,?)", (cid, i, p["sha256"]))
                    receipt = append_receipt(c, cid, body_sha)
                    audit(c, dev, "capture", cid)
                missing = [p["sha256"] for p in pages if not (BLOBS / p["sha256"]).exists()]
                for p in pages:
                    if (BLOBS / p["sha256"]).exists():
                        enqueue_ocr(c, p["sha256"])
            return self.send_json(status, {"id": cid, "status": "received", "missingBlobs": missing, "receipt": receipt})
        return self.problem(HTTPStatus.NOT_FOUND, "Ruta inexistente")

    def post_reading(self):
        """Per-cell readings of one page image, aligned to the form layout (form-layouts SPEC).
        Nothing is stored: the person validates the readings and then sends the capture."""
        dev = self.device()
        if dev is None:
            return self.problem(HTTPStatus.UNAUTHORIZED, "Falta un token válido")
        if self.limited("reading", dev):
            return
        query = dict(q.split("=", 1) for q in (self.path.split("?", 1)[1:] or [""])[0].split("&") if "=" in q)
        template_id = query.get("templateId", "")
        tpath = ROOT / "contracts/templates" / f"{template_id}.json"
        if not re.fullmatch(r"[a-z0-9-]+", template_id) or not tpath.exists():
            return self.problem(HTTPStatus.UNPROCESSABLE_ENTITY, "Plantilla desconocida", template_id)
        try:
            data = self.body()
        except ValueError:
            return self.problem(HTTPStatus.REQUEST_ENTITY_TOO_LARGE, "Imagen demasiado grande")
        try:
            result = readings.read_telegram(data, json.loads(tpath.read_text()))
        except Exception as exc:  # unreadable image or OCR failure: the person loads values by hand
            return self.problem(HTTPStatus.UNPROCESSABLE_ENTITY, "No se pudo leer la imagen", type(exc).__name__)
        with DB_LOCK, db() as c:
            audit(c, dev, "reading", hashlib.sha256(data).hexdigest())
        return self.send_json(HTTPStatus.OK, result)

    def do_PUT(self):
        if self.limited():
            return
        parts = [p for p in self.path.split("?")[0].split("/") if p]
        dev = self.device()
        if dev is None:
            return self.problem(HTTPStatus.UNAUTHORIZED, "Falta un token válido")
        if len(parts) == 3 and parts[:2] == ["v1", "blobs"] and SHA_RE.match(parts[2]):
            try:
                data = self.body()
            except ValueError:
                return self.problem(HTTPStatus.REQUEST_ENTITY_TOO_LARGE, "Imagen demasiado grande")
            if not data.startswith(b"\xff\xd8\xff"):
                return self.problem(HTTPStatus.UNSUPPORTED_MEDIA_TYPE, "Sólo se aceptan imágenes JPEG")
            if hashlib.sha256(data).hexdigest() != parts[2]:
                return self.problem(HTTPStatus.UNPROCESSABLE_ENTITY, "El hash no coincide")
            path = BLOBS / parts[2]
            existed = path.exists()
            if not existed:
                tmp = path.with_suffix(".tmp")
                tmp.write_bytes(data)
                os.chmod(tmp, 0o444)  # evidence is immutable
                tmp.replace(path)
            with DB_LOCK, db() as c:
                audit(c, dev, "blob", parts[2])
                if c.execute("SELECT 1 FROM pages WHERE sha256=?", (parts[2],)).fetchone():
                    enqueue_ocr(c, parts[2])
            return self.send_json(HTTPStatus.OK if existed else HTTPStatus.CREATED, {"sha256": parts[2], "bytes": len(data)})
        return self.problem(HTTPStatus.NOT_FOUND, "Ruta inexistente")


def main():
    if PUBLIC and APP_CODE and len(APP_CODE) < 24 and not OPEN_TEST:
        sys.exit("CC_APP_ENROLL_CODE must have 24+ characters")
    if PUBLIC and not CODES_FILE and len(ENROLL_CODE) < 16:
        sys.exit("CC_PUBLIC=1 requires CC_ENROLL_CODES_FILE or a CC_ENROLL_CODE of 16+ characters")
    init_db()
    with db() as c:
        for row in c.execute("SELECT sha256 FROM ocr WHERE status IN ('queued','running')"):
            JOBS.put(row["sha256"])
    threading.Thread(target=ocr_worker, daemon=True).start()
    host, port = os.environ.get("CC_HOST", "127.0.0.1"), int(os.environ.get("CC_PORT", "8740"))
    if OPEN_TEST:
        print("WARNING: CC_OPEN_TEST=1, weak shared enrollment code accepted (test only)", file=sys.stderr)
    shown = "single-use codes file" if CODES_FILE else ENROLL_CODE
    print(f"scrutiny server {VERSION} on http://{host}:{port} · public={PUBLIC} · data {DATA} · enrollment: {shown}",
          file=sys.stderr)
    ThreadingHTTPServer((host, port), Handler).serve_forever()


if __name__ == "__main__":
    main()
