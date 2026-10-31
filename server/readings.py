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

try:
    from PIL import Image, ImageFilter, ImageOps
except ImportError:  # pragma: no cover - reported by engine_status()
    Image = None

ROOT = Path(__file__).resolve().parents[1]
LAYOUTS = ROOT / "contracts/layouts"
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
    """Digits-only reading of one cell. Returns (value, confidence, digit box, empty)."""
    x, y, w, h = box
    mx, my = int(0.03 * w) + 3, int(0.12 * h) + 2  # inner margin: skip the table lines
    x0, y0, x1, y1 = max(0, x + mx), max(0, y + my), min(img.width, x + w - mx), min(img.height, y + h - my)
    if x1 - x0 < 8 or y1 - y0 < 8:
        return None, 0.0, None, False
    crop = ImageOps.autocontrast(ImageOps.grayscale(img.crop((x0, y0, x1, y1))))
    ink = sum(1 for p in crop.getdata() if p < 110) / (crop.width * crop.height)
    if ink < 0.004:
        return None, 0.0, None, True
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
        return None, 0.0, None, True
    ox, oy = box_ink[0], box_ink[1]
    bw = bw.crop(box_ink)
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
        return None, 0.0, None, ink < 0.02  # a dash or a scribble: the person decides
    vbox = [x0 + round((best["x"] - 30) / scale), y0 + round((best["y"] - 30) / scale),
            round(best["w"] / scale), round(best["h"] / scale)]
    return int(best["text"]), round(max(0.0, min(best["conf"], 99.0)) / 100, 2), vbox, False


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
                "fields": [], "notFound": expected}
    layout, t, used, err = best
    fields = []
    for cell in layout["cells"]:
        box = map_box(t, cell["box"])
        value, conf, vbox, empty = read_cell(img, box)
        field = {"ref": cell["ref"], "value": value, "confidence": conf, "empty": empty,
                 "valueBox": vbox, "cellBox": box}
        if "label" in cell:
            field["label"] = {"text": cell["label"]["text"], "box": map_box(t, cell["label"]["box"])}
        fields.append(field)
    found = {f["ref"] for f in fields}
    return {**base, "layoutId": layout["id"],
            "alignment": {"ok": True, "anchorsUsed": used, "meanErrorPx": round(err, 1)},
            "masks": [map_box(t, m["box"]) for m in layout.get("masks", [])],
            "fields": fields, "notFound": [r for r in expected if r not in found]}
