#!/usr/bin/env python3
"""Build the public polling-place list used by the cascading table pickers (F-16).

Input (untouched download in data/private/establecimientos/):
  elecciones_legislativas_2025.zip (Ministerio del Interior, datos abiertos):
  localesDeVotacionyMesas.csv (polling places and their tables) and
  resultados2025.csv (only to map each table to its circuit).
Output: data/establecimientos/nomina-2025.json, nested
  distrito -> sección -> establecimiento -> table ranges [first, last, circuito].
Public data, no personal information. Standard library only.
"""
import csv
import hashlib
import io
import json
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data/private/establecimientos/elecciones_legislativas_2025.zip"
OUT = ROOT / "data/establecimientos/nomina-2025.json"


def rows(z, name):
    with z.open(name) as f:
        yield from csv.DictReader(io.TextIOWrapper(f, encoding="utf-8"))


def main():
    with zipfile.ZipFile(RAW) as z:
        circuit = {}
        for r in rows(z, "resultados2025.csv"):
            key = (int(r["distrito_id"]), int(r["seccion_id"]), int(r["mesa_id"]))
            circuit.setdefault(key, r["circuito_id"])
        tree, names = {}, {}
        for r in rows(z, "localesDeVotacionyMesas.csv"):
            d, s, m = int(r["distrito_id"]), int(r["seccion_id"]), int(r["mesa_id"])
            names[d] = r["distrito_nombre"]
            sec = tree.setdefault(d, {}).setdefault(s, {"nombre": r["seccion_nombre"], "locales": {}})
            loc = sec["locales"].setdefault(r["localvotacion_codigo"], {
                "codigo": r["localvotacion_codigo"], "nombre": r["localvotacion_nombre"],
                "direccion": r["localvotacion_direccion"], "localidad": r["localvotacion_localidad"],
                "mesas": []})
            loc["mesas"].append((m, circuit.get((d, s, m), "")))

    missing = 0
    distritos = []
    for d in sorted(tree):
        secciones = []
        for s in sorted(tree[d]):
            sec = tree[d][s]
            locales = []
            for loc in sorted(sec["locales"].values(), key=lambda l: l["nombre"]):
                ranges = []
                for m, c in sorted(set(loc["mesas"])):
                    missing += not c
                    if ranges and ranges[-1][1] == m - 1 and ranges[-1][2] == c:
                        ranges[-1][1] = m
                    else:
                        ranges.append([m, m, c])
                locales.append({**{k: loc[k] for k in ("codigo", "nombre", "direccion", "localidad")}, "mesas": ranges})
            secciones.append({"id": f"{s:03d}", "nombre": sec["nombre"], "locales": locales})
        distritos.append({"id": f"{d:02d}", "nombre": names[d], "secciones": secciones})

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps({
        "source": {"dataset": "Elecciones legislativas 2025 · locales de votación y mesas (Ministerio del Interior)",
                   "url": "http://datos.mininterior.gob.ar/dataset/947e871a-650e-4b63-8939-ecb29acb717c/resource/a24110fb-bfcf-47a6-8aa7-2e53dab9caf5/download/elecciones_legislativas_2025.zip",
                   "sha256": hashlib.sha256(RAW.read_bytes()).hexdigest(), "downloaded": "2026-10-31"},
        "note": "Mesas como rangos [desde, hasta, circuito]. Sin coordenadas en la fuente.",
        "distritos": distritos}, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    n_loc = sum(len(s["locales"]) for d in distritos for s in d["secciones"])
    print(f"{len(distritos)} distritos, {n_loc} establecimientos, mesas sin circuito: {missing}; "
          f"{OUT} ({OUT.stat().st_size} bytes)", file=sys.stderr)


if __name__ == "__main__":
    main()
