#!/usr/bin/env python3
"""Build the stratum polygons for the AMBA simulation.

Inputs (untouched downloads in data/private/amba-simulation/raw/):
- limite-partidos-pba.zip (PBA open data, CC BY 4.0): partidos-pba.geojson
- caba_comunas.geojson (Buenos Aires City open data)

Output: data/private/amba-simulation/strata_2023_amba.geojson, one feature per
stratum named exactly as in mesas_2023_amba.json. Coordinates are rounded to
4 decimals (~10 m) and consecutive duplicates dropped to keep the file small.

Standard library only.
"""
import json
import sys
import zipfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from normalize import CONURBANO_24  # noqa: E402

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data/private/amba-simulation/raw"
OUT = ROOT / "data/private/amba-simulation/strata_2023_amba.geojson"


def simplify_ring(ring):
    out = []
    for x, y in ring:
        p = [round(x, 4), round(y, 4)]
        if not out or out[-1] != p:
            out.append(p)
    if out[0] != out[-1]:
        out.append(out[0])
    return out


def simplify(geom):
    polys = geom["coordinates"] if geom["type"] == "MultiPolygon" else [geom["coordinates"]]
    return {"type": "MultiPolygon", "coordinates": [[simplify_ring(r) for r in poly] for poly in polys]}


def main():
    features = []
    with zipfile.ZipFile(RAW / "limite-partidos-pba.zip") as z:
        pba = json.loads(z.read("partidos-pba.geojson"))
    for f in pba["features"]:
        name = f["properties"]["municipio_nombre"]
        if name in CONURBANO_24:
            features.append({"type": "Feature", "properties": {"name": name}, "geometry": simplify(f["geometry"])})
    caba = json.loads((RAW / "caba_comunas.geojson").read_text(encoding="utf-8"))
    for f in caba["features"]:
        name = f"CABA · Comuna {int(f['properties']['comuna']):02d}"
        features.append({"type": "Feature", "properties": {"name": name}, "geometry": simplify(f["geometry"])})

    names = {f["properties"]["name"] for f in features}
    missing = CONURBANO_24 - names
    if missing or len(features) != 39:
        sys.exit(f"unexpected strata: {len(features)} features, missing {sorted(missing)}")
    OUT.write_text(json.dumps({"type": "FeatureCollection", "features": features}, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"wrote {OUT} ({OUT.stat().st_size} bytes, {len(features)} strata)", file=sys.stderr)


if __name__ == "__main__":
    main()
