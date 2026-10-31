#!/usr/bin/env python3
"""Fetch Andy's official sample telegrams and bundle them for the app's sample mode.

Reads data/ocr-samples/manifest.json (official URL, Internet Archive copy, SHA-256)
and planilla-valores.csv (table identification). Downloads each PDF once into
data/private/ocr-samples/, verifies its SHA-256, renders page 1 to JPEG and writes
the images plus samples.json into ios/CuentaConmigo/Resources/Samples/.

Both destinations are git-ignored: the telegrams carry names, signatures and ID
numbers of real people (Ley 25.326), so they never enter the public repository.
Standard library only; renders with pdftoppm (Linux) or sips (macOS).
"""
import csv
import hashlib
import json
import shutil
import subprocess
import sys
import tempfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / "data/ocr-samples/manifest.json"
VALUES = ROOT / "data/ocr-samples/planilla-valores.csv"
CACHE = ROOT / "data/private/ocr-samples"
OUT = ROOT / "ios/CuentaConmigo/Resources/Samples"
ELECTIONS = {"balotaje-2015": "Balotaje 2015", "paso-2017": "PASO 2017"}


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def fetch(entry):
    dest = CACHE / entry["file"]
    if dest.exists() and sha256(dest) == entry["sha256"]:
        return dest
    dest.parent.mkdir(parents=True, exist_ok=True)
    for url in (entry["archive_url"], entry["original_url"]):
        try:
            with urllib.request.urlopen(url, timeout=60) as r:
                data = r.read()
        except OSError as e:
            print(f"  {url}: {e}", file=sys.stderr)
            continue
        if hashlib.sha256(data).hexdigest() == entry["sha256"]:
            dest.write_bytes(data)
            return dest
        print(f"  {url}: SHA-256 mismatch, skipped", file=sys.stderr)
    return None


def render(pdf, jpg):
    if shutil.which("pdftoppm"):
        with tempfile.TemporaryDirectory() as tmp:
            subprocess.run(["pdftoppm", "-jpeg", "-r", "150", "-f", "1", "-l", "1", "-singlefile",
                            str(pdf), str(Path(tmp) / "page")], check=True)
            shutil.move(str(Path(tmp) / "page.jpg"), jpg)
    elif shutil.which("sips"):
        subprocess.run(["sips", "-s", "format", "jpeg", str(pdf), "--out", str(jpg)],
                       check=True, capture_output=True)
    else:
        sys.exit("Need pdftoppm or sips to render PDFs")


def main():
    entries = json.loads(MANIFEST.read_text(encoding="utf-8-sig"))
    tables = {}
    with VALUES.open(encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f, delimiter=";"):
            tables.setdefault(r["archivo"], r)
    OUT.mkdir(parents=True, exist_ok=True)
    samples = []
    for i, entry in enumerate(entries, start=1):
        pdf = fetch(entry)
        row = tables.get(entry["file"])
        if pdf is None or row is None:
            print(f"skip {entry['file']}", file=sys.stderr)
            continue
        name = f"sample-{i:02d}.jpg"
        render(pdf, OUT / name)
        mesa = {"distrito": row["distrito"], "seccion": row["seccion"].zfill(3),
                "circuito": row["circuito"].zfill(4), "mesa": row["mesa"].zfill(5)}
        election = ELECTIONS.get(row["eleccion"], row["eleccion"])
        samples.append({"id": f"sample-{i:02d}", "file": name, "documentType": "telegrama",
                        "label": f"{election} · distrito {mesa['distrito']} · mesa {int(row['mesa'])}",
                        "election": row["eleccion"], "source": entry["file"], "mesa": mesa})
    (OUT / "samples.json").write_text(json.dumps({
        "note": "Telegramas oficiales de data/ocr-samples (Andy). Contienen datos personales: fuera de Git.",
        "samples": samples}, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"{len(samples)} samples in {OUT}")


if __name__ == "__main__":
    main()
