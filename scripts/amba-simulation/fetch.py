#!/usr/bin/env python3
"""Download the official sources listed in data/amba-simulation/manifest.json into
data/private/amba-simulation/raw/ (git-ignored, ~43 MB) and verify each SHA-256.

Files already present with the right hash are kept. A mismatch stops with an error:
the source changed upstream and the manifest must be reviewed, never silently updated.
Standard library only.
"""
import hashlib
import json
import sys
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "data/amba-simulation/manifest.json"
RAW = ROOT / "data/private/amba-simulation/raw"


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    RAW.mkdir(parents=True, exist_ok=True)
    failed = False
    for src in json.loads(MANIFEST.read_text())["sources"]:
        path = RAW / src["file"]
        if path.exists() and sha256(path) == src["sha256"]:
            print(f"ok (cache)  {src['file']}")
            continue
        print(f"descargando {src['file']} …", flush=True)
        req = urllib.request.Request(src["url"], headers={"User-Agent": "cuentaconmigo-fetch"})
        tmp = path.with_suffix(path.suffix + ".part")
        with urllib.request.urlopen(req, timeout=300) as resp, open(tmp, "wb") as out:
            while chunk := resp.read(1 << 20):
                out.write(chunk)
        digest = sha256(tmp)
        if digest != src["sha256"]:
            print(f"ERROR {src['file']}: sha256 {digest} ≠ manifiesto {src['sha256']}", file=sys.stderr)
            tmp.unlink()
            failed = True
            continue
        tmp.replace(path)
        print(f"ok          {src['file']}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
