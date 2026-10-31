"""Per-cell readings of a telegram image (sdd/specs/form-layouts/SPEC.md, assisted-review F-18).

1. Tesseract reads the printed text of the whole page with word positions.
2. Each layout in contracts/layouts/ for the template lists printed anchors at known
   reference positions; matched anchors give an affine transform reference -> photo
   (least squares, outliers dropped). The layout that aligns best is used.
3. Every cell box is mapped onto the photo, cropped with an inner margin and read with a
   digits-only pass. Masked zones (signatures, names) are never read.

Readings are machine-extracted (origin "ocr-server"): suggestions a person validates,
never confirmed values. Needs the `tesseract` binary (spa) and Pillow.
"""
import difflib
import io
import json
import re
import subprocess
import tempfile
import unicodedata
from pathlib import Path

import digits

try:
    from PIL import Image, ImageFilter, ImageOps
except ImportError:  # pragma: no cover - reported by engine_status()
    Image = None

ROOT = Path(__file__).resolve().parents[1]
LAYOUTS = ROOT / "contracts/layouts"
UNREADABLE = "?"  # same mark as the transcription sheet (data/ocr-samples)
MIN_CONFIDENCE = 0.3  # below this a reading is shown as "?" (value kept only as a hint)
MAX_ERROR = 0.02  # anchor residual tolerated, as a fraction of the image width


def engine_status():
    return {"pillow": Image is not None, "layouts": sorted(p.stem for p in LAYOUTS.glob("*.json"))}


def layouts_for(template_id):
    return [json.loads(p.read_text()) for p in sorted(LAYOUTS.glob("*.json"))
            if json.loads(p.read_text()).get("templateId") == template_id]


def norm(text):
    text = unicodedata.normalize("NFKD", text).encode("ascii", "ignore").decode()
    return re.sub(r"[^A-Z0-9]", "", text.upper())


def similar(word, token):
    """Printed words come out slightly broken ("IMPUGNADA]", "NOYIEMBRE")."""
    if word == token:
        return True
    if len(word) >= 5 and len(token) >= 4 and (token.startswith(word[:5]) or word.startswith(token)):
        return True
    return len(word) >= 5 and difflib.SequenceMatcher(None, word, token).ratio() >= 0.8


def tsv_words(path, extra=()):
    out = subprocess.run(["tesseract", str(path), "-", "-l", "spa", *extra, "tsv"],
                         capture_output=True, text=True, timeout=120).stdout
    words = []
    for line in out.splitlines()[1:]:
        f = line.split("\t")
        if len(f) < 12 or not f[11].strip():
            continue
        x, y, w, h, conf = int(f[6]), int(f[7]), int(f[8]), int(f[9]), float(f[10])
        words.append({"x": x, "y": y, "w": w, "h": h, "conf": conf, "text": f[11], "n": norm(f[11])})
    return words


# --- affine alignment -------------------------------------------------------------

def solve3(m, v):
    """Gaussian elimination for a 3x3 system."""
    a = [row[:] + [v[i]] for i, row in enumerate(m)]
    for c in range(3):
        p = max(range(c, 3), key=lambda r: abs(a[r][c]))
        if abs(a[p][c]) < 1e-9:
            return None
        a[c], a[p] = a[p], a[c]
        for r in range(3):
            if r != c:
                k = a[r][c] / a[c][c]
                a[r] = [x - k * y for x, y in zip(a[r], a[c])]
    return [a[i][3] / a[i][i] for i in range(3)]


def fit_affine(pairs):
    """Least squares (x, y) -> (u, v): u = a x + b y + c, v = d x + e y + f."""
    if len(pairs) < 3:
        return None
    m = [[0.0] * 3 for _ in range(3)]
    bu, bv = [0.0] * 3, [0.0] * 3
    for (x, y), (u, v) in pairs:
        row = (x, y, 1.0)
        for i in range(3):
            for j in range(3):
                m[i][j] += row[i] * row[j]
            bu[i] += row[i] * u
            bv[i] += row[i] * v
    pu, pv = solve3(m, bu), solve3(m, bv)
    return (pu, pv) if pu and pv else None


def apply(t, x, y):
    (a, b, c), (d, e, f) = t
    return a * x + b * y + c, d * x + e * y + f


def map_box(t, box):
    x, y, w, h = box
    pts = [apply(t, px, py) for px, py in ((x, y), (x + w, y), (x, y + h), (x + w, y + h))]
    xs, ys = [p[0] for p in pts], [p[1] for p in pts]
    return [round(min(xs)), round(min(ys)), round(max(xs) - min(xs)), round(max(ys) - min(ys))]


def align(layout, words, size):
    W, H = size
    rw, rh = layout["reference"]["width"], layout["reference"]["height"]
    guess = ((W / rw, 0.0, 0.0), (0.0, H / rh, 0.0))
    pairs = []
    for anchor in layout["anchors"]:
        key = norm(anchor["text"])
        ex, ey = apply(guess, *anchor["center"])
        cands = [w for w in words if similar(key, w["n"])]
        if not cands:
            continue
        best = min(cands, key=lambda w: (w["x"] + w["w"] / 2 - ex) ** 2 + (w["y"] + w["h"] / 2 - ey) ** 2)
        if abs(best["x"] + best["w"] / 2 - ex) > 0.15 * W or abs(best["y"] + best["h"] / 2 - ey) > 0.15 * H:
            continue  # same word elsewhere on the page
        pairs.append((tuple(anchor["center"]), (best["x"] + best["w"] / 2, best["y"] + best["h"] / 2)))
    t = None
    for _ in range(3):
        t = fit_affine(pairs)
        if t is None:
            return None, 0, None
        errs = [((apply(t, *r)[0] - p[0]) ** 2 + (apply(t, *r)[1] - p[1]) ** 2) ** 0.5 for r, p in pairs]
        keep = [pr for pr, e in zip(pairs, errs) if e <= MAX_ERROR * W]
        if len(keep) == len(pairs):
            break
        pairs = keep
    if t is None or len(pairs) < 3:
        return None, len(pairs), None
    errs = [((apply(t, *r)[0] - p[0]) ** 2 + (apply(t, *r)[1] - p[1]) ** 2) ** 0.5 for r, p in pairs]
    return t, len(pairs), sum(errs) / len(errs)


# --- cell reading -------------------------------------------------------------------

def read_cell(img, box):
    """Digits-only reading of one cell. Returns (value, confidence, digit box, empty, alternatives)
    where alternatives are [(value, probability)] for the sum check."""
    x, y, w, h = box
    mx, my = int(0.03 * w) + 3, int(0.12 * h) + 2  # inner margin: skip the table lines
    x0, y0, x1, y1 = max(0, x + mx), max(0, y + my), min(img.width, x + w - mx), min(img.height, y + h - my)
    if x1 - x0 < 8 or y1 - y0 < 8:
        return None, 0.0, None, False, []
    crop = ImageOps.autocontrast(ImageOps.grayscale(img.crop((x0, y0, x1, y1))))
    ink = sum(1 for p in crop.getdata() if p < 110) / (crop.width * crop.height)
    if ink < 0.004:
        return None, 0.0, None, True, [(0, 0.6)]
    bw = crop.point(lambda p: 0 if p < 150 else 255)
    px = bw.load()
    # Drop long horizontal runs (table lines and underlines) so only the handwriting remains.
    for yy in range(bw.height):
        run = 0
        for xx in range(bw.width + 1):
            if xx < bw.width and px[xx, yy] == 0:
                run += 1
                continue
            if run > 0.35 * bw.width:
                for k in range(xx - run, xx):
                    px[k, yy] = 255
            run = 0
    box_ink = ImageOps.invert(bw).getbbox()
    if box_ink is None:
        return None, 0.0, None, True, [(0, 0.6)]
    ox, oy = box_ink[0], box_ink[1]
    bw = bw.crop(box_ink)
    # A short, wide stroke is the dash written for "no votes": it means 0.
    if bw.height < 0.3 * (y1 - y0) and bw.width > 2.2 * bw.height:
        return None, 0.0, [x0 + ox, y0 + oy, bw.width, bw.height], True, [(0, 0.8)]
    # Neural digit classifier first (server/digits.py); Tesseract is the fallback.
    alts = digits.candidates(bw)
    nn = digits.read(bw)
    if nn is not None and nn[1] >= 0.5:
        return nn[0], round(nn[1], 2), [x0 + ox, y0 + oy, bw.width, bw.height], False, alts
    scale = 80 / max(1, bw.height)
    big = bw.resize((max(1, round(bw.width * scale)), 80)).filter(ImageFilter.MinFilter(3))
    big = ImageOps.expand(big, border=30, fill=255)
    x0, y0 = x0 + ox, y0 + oy
    best = None
    with tempfile.TemporaryDirectory() as tmp:
        path = Path(tmp) / "cell.png"
        big.save(path, dpi=(300, 300))
        for psm in ("7", "8", "6", "13"):
            words = tsv_words(path, ("--psm", psm, "-c", "tessedit_char_whitelist=0123456789"))
            for w in words:
                if w["text"].isdigit() and (best is None or (w["conf"], len(w["text"])) > (best["conf"], len(best["text"]))):
                    best = w
    if best is None:
        dash = ink < 0.02  # a dash or a scribble: the person decides
        return None, 0.0, None, dash, alts or ([(0, 0.5)] if dash else [])
    vbox = [x0 + round((best["x"] - 30) / scale), y0 + round((best["y"] - 30) / scale),
            round(best["w"] / scale), round(best["h"] / scale)]
    conf = round(max(0.0, min(best["conf"], 99.0)) / 100, 2)
    return int(best["text"]), conf, vbox, False, alts or [(int(best["text"]), conf)]


def options(field, limit=3):
    """Plausible values of a cell: its reading first, then the classifier's alternatives."""
    opts = []
    if field["value"] is not None:
        opts.append((field["value"], max(field["confidence"], 0.05)))
    if field.get("empty"):
        opts.append((0, 0.8))
    for value, prob in field.get("_alts") or []:
        if all(value != v for v, _ in opts):
            opts.append((value, prob))
    return opts[:limit]


def sum_check(fields, template, category):
    """The form's own checksum: the rows of a category add up to the written TOTAL and to
    the envelopes (header.votantes). Picks the most probable combination of readings that
    closes the sum; when it closes, the cells involved become sum-verified."""
    by_ref = {f["ref"]: f for f in fields}
    rows = [by_ref.get(f"cells.{category}.{r['id']}") for r in template["rows"]]
    if any(r is None for r in rows):
        return {"category": category, "ok": False, "reason": "faltan filas"}
    targets = [by_ref[ref] for ref in ("header.votantes", f"total.{category}") if ref in by_ref]
    row_opts = [options(r) for r in rows]
    if not targets or any(not o for o in row_opts):
        return {"category": category, "ok": False, "reason": "lecturas insuficientes"}
    target_opts = {}
    for t in targets:
        for value, prob in options(t):
            target_opts.setdefault(value, []).append((t, prob))
    best = None

    def search(i, acc, prob, chosen):
        nonlocal best
        if best and prob <= best[0]:
            return
        if i == len(rows):
            if acc in target_opts:
                score = prob * max(p for _, p in target_opts[acc])
                if best is None or score > best[0]:
                    best = (score, acc, list(chosen))
            return
        for value, p in row_opts[i]:
            chosen.append(value)
            search(i + 1, acc + value, prob * p, chosen)
            chosen.pop()

    search(0, 0, 1.0, [])
    readings_sum = sum(r["value"] or 0 for r in rows)
    if best is None:
        return {"category": category, "ok": False, "sum": readings_sum,
                "total": next((t["value"] for t in targets if t["value"] is not None), None)}
    _, total, chosen = best
    changed = any(r["value"] != v for r, v in zip(rows, chosen))
    sources = {t["ref"] for t, _ in target_opts[total]}
    # Changing readings to make the sum close needs two independent witnesses (written
    # TOTAL and envelopes); otherwise a lucky combination could close by chance.
    strong = any(p >= 0.9 for _, p in target_opts[total])
    if changed and len(sources) < 2 and not strong:
        return {"category": category, "ok": False, "sum": readings_sum,
                "total": next((t["value"] for t in targets if t["value"] is not None), None)}
    for row, value in zip(rows, chosen):
        if row["value"] != value:
            row["value"], row["empty"] = value, False
        row["confidence"] = max(row["confidence"], 0.9)
        row["sumVerified"] = True
    for t, _ in target_opts[total]:
        t["value"], t["confidence"], t["sumVerified"] = total, max(t["confidence"], 0.9), True
    return {"category": category, "ok": True, "sum": total, "total": total}


def read_telegram(image_bytes, template):
    if Image is None:
        raise RuntimeError("Pillow no está disponible en el servidor")
    src = Image.open(io.BytesIO(image_bytes))
    dpi = src.info.get("dpi") or (0, 0)
    dpi = (round(float(dpi[0])),) * 2 if dpi[0] and float(dpi[0]) >= 100 else (300, 300)
    img = ImageOps.exif_transpose(src).convert("RGB")
    W, H = img.size
    with tempfile.TemporaryDirectory() as tmp:
        page = Path(tmp) / "page.png"
        img.save(page, dpi=dpi)  # Tesseract scales by the declared resolution
        words = [w for w in tsv_words(page, ("--psm", "11")) if w["conf"] >= 30]

    best = None
    candidates = layouts_for(template["id"]) or [json.loads(p.read_text()) for p in sorted(LAYOUTS.glob("*.json"))]
    for layout in candidates:
        t, used, err = align(layout, words, (W, H))
        if t and (best is None or (used, -err) > (best[2], -best[3])):
            best = (layout, t, used, err)
    expected = [f"header.{f['id']}" for f in template["headerFields"]] + \
               [f"cells.{c['id']}.{r['id']}" for c in template["categories"] for r in template["rows"]]
    base = {"origin": "ocr-server", "templateId": template["id"], "image": {"width": W, "height": H}}
    if best is None:
        return {**base, "layoutId": None, "alignment": {"ok": False, "anchorsUsed": 0, "meanErrorPx": None},
                "fields": [], "notFound": expected, "pending": expected}
    layout, t, used, err = best
    fields = []
    for cell in layout["cells"]:
        box = map_box(t, cell["box"])
        value, conf, vbox, empty, alts = read_cell(img, box)
        # status/text: "?" marks a cell that should hold a value but could not be read,
        # so the app shows an empty box for the person to fill.
        if value is not None and conf >= MIN_CONFIDENCE:
            status, text = "read", str(value)
        elif empty and value is None:
            status, text = "empty", ""
        else:  # writing present but not recognized (or barely): ask the person
            status, text = "unreadable", UNREADABLE
        field = {"ref": cell["ref"], "value": value, "confidence": conf, "empty": empty,
                 "status": status, "text": text,
                 "valueBox": vbox, "cellBox": box, "_alts": alts}
        if "label" in cell:
            field["label"] = {"text": cell["label"]["text"], "box": map_box(t, cell["label"]["box"])}
        fields.append(field)
    checks = [sum_check(fields, template, c["id"]) for c in template["categories"]]
    for f in fields:
        f.pop("_alts", None)
    found = {f["ref"] for f in fields}
    return {**base, "layoutId": layout["id"], "checks": checks,
            "alignment": {"ok": True, "anchorsUsed": used, "meanErrorPx": round(err, 1)},
            "masks": [map_box(t, m["box"]) for m in layout.get("masks", [])],
            "fields": fields, "notFound": [r for r in expected if r not in found],
            "pending": [f["ref"] for f in fields if f["status"] == "unreadable"]
                       + [r for r in expected if r not in found]}
