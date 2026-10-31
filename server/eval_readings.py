#!/usr/bin/env python3
"""Measure server readings (form-layouts SPEC §6) against the values transcribed in
data/ocr-samples/planilla-valores.csv, on the sample telegrams bundled by
scripts/samples/fetch_ocr_samples.py (git-ignored: they carry personal data).

Usage: python3 server/eval_readings.py
"""
import csv
import json
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "server"))
from readings import read_telegram  # noqa: E402

SAMPLES = ROOT / "ios/CuentaConmigo/Resources/Samples"
SPECIAL = {"VOTOS NULOS": "nulos", "VOTOS RECURRIDOS": "recurridos", "VOTOS EN BLANCO": "blanco",
           "VOTOS DE IDENTIDAD IMPUGNADA": "impugnados"}


def ref_for(template, fila):
    if fila == "electores":
        return "header.electores"
    if fila == "sobres":
        return "header.votantes"
    cat = template["categories"][0]["id"]
    for row in template["rows"]:
        if row["label"].split()[0] == fila.split()[0]:
            return f"cells.{cat}.{row['id']}"
    return f"cells.{cat}.{SPECIAL[fila.upper()]}" if fila.upper() in SPECIAL else None


def main():
    truth = {}
    with open(ROOT / "data/ocr-samples/planilla-valores.csv", encoding="utf-8-sig", newline="") as f:
        for r in csv.DictReader(f, delimiter=";"):
            truth.setdefault(r["archivo"], []).append(r)
    manifest = json.loads((SAMPLES / "samples.json").read_text())["samples"]
    exact = total = confident = confident_ok = 0
    for s in manifest:
        tpath = ROOT / "contracts/templates" / f"{s['election']}.json"
        if not tpath.exists():
            continue
        template = json.loads(tpath.read_text())
        t0 = time.time()
        res = read_telegram((SAMPLES / s["file"]).read_bytes(), template)
        got = {f["ref"]: f for f in res["fields"]}
        print(f"{s['id']} {time.time() - t0:.1f}s layout={res['layoutId']} alignment={res['alignment']}")
        for r in truth.get(s["source"], []):
            ref = ref_for(template, r["fila"])
            if not ref or not r["valor"].strip().isdigit():
                continue
            want, field = int(r["valor"]), got.get(ref, {})
            value, conf = field.get("value"), field.get("confidence", 0)
            total += 1
            exact += value == want
            if conf >= 0.8:
                confident += 1
                confident_ok += value == want
            print(f"   {ref:34} esperado={want:>5} leído={value!s:>5} confianza={conf:.2f}")
    print(f"exactas: {exact}/{total}")
    print(f"calibración: con confianza ≥ 0,8 hubo {confident} lecturas, {confident_ok} correctas")


if __name__ == "__main__":
    main()
