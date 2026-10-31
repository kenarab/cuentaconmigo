#!/usr/bin/env python3
"""Normalize official 2023 general-election results (DINE, provisional count)
into a per-table file for the AMBA simulation.

Input: the untouched DINE zip in data/private/amba-simulation/raw/.
Output: data/private/amba-simulation/mesas_2023_amba.json (derived, reproducible).

Scope (sdd/specs/amba-simulation/SPEC.md): category President (cargo_id 1),
CABA (distrito 1) and the 24 Greater Buenos Aires districts (distrito 2).
Parties are shown as neutral letters ordered by agrupacion_id; the mapping to
real names stays in the file's metadata, never on screen.

Standard library only.
"""
import csv
import hashlib
import io
import json
import sys
import zipfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / "data/private/amba-simulation/raw/2023_generales_1.zip"
MEMBER = "2023_Generales/ResultadoElectorales_2023_Generales.csv"
OUT = ROOT / "data/private/amba-simulation/mesas_2023_amba.json"

CONURBANO_24 = {
    "Almirante Brown", "Avellaneda", "Berazategui", "Esteban Echeverría",
    "Ezeiza", "Florencio Varela", "General San Martín", "Hurlingham",
    "Ituzaingó", "José C. Paz", "La Matanza", "Lanús", "Lomas de Zamora",
    "Malvinas Argentinas", "Merlo", "Moreno", "Morón", "Quilmes",
    "San Fernando", "San Isidro", "San Miguel", "Tigre", "Tres de Febrero",
    "Vicente López",
}
OTHER_TYPES = ["EN BLANCO", "NULO", "IMPUGNADO", "RECURRIDO", "COMANDO"]


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    tables = {}
    parties = {}
    strata = {}
    with zipfile.ZipFile(RAW) as z, z.open(MEMBER) as raw:
        for r in csv.DictReader(io.TextIOWrapper(raw, encoding="utf-8")):
            if r["cargo_id"] != "1":
                continue
            d = r["distrito_id"]
            if d == "1":
                stratum = "CABA · " + r["seccion_nombre"]
            elif d == "2" and r["seccion_nombre"] in CONURBANO_24:
                stratum = r["seccion_nombre"]
            else:
                continue
            key = (d, r["seccion_id"], r["circuito_id"], r["mesa_id"])
            t = tables.get(key)
            if t is None:
                t = tables[key] = {
                    "s": stratum, "c": r["circuito_id"], "m": r["mesa_id"],
                    "e": int(r["mesa_electores"]), "p": {}, "o": [0] * len(OTHER_TYPES),
                }
                strata.setdefault(stratum, {"distrito": d, "seccion_id": int(r["seccion_id"])})
            n = int(r["votos_cantidad"] or 0)
            if r["votos_tipo"] == "POSITIVO":
                pid = int(r["agrupacion_id"])
                parties[pid] = r["agrupacion_nombre"]
                t["p"][pid] = t["p"].get(pid, 0) + n
            else:
                t["o"][OTHER_TYPES.index(r["votos_tipo"])] += n

    pids = sorted(parties)
    letters = [chr(ord("A") + i) for i in range(len(pids))]
    stratum_names = sorted(strata)
    sidx = {s: i for i, s in enumerate(stratum_names)}
    rows = []
    for (d, sec, circ, mesa), t in sorted(tables.items(), key=lambda kv: (kv[0][0], int(kv[0][1]), kv[0][2], int(kv[0][3]))):
        rows.append([sidx[t["s"]], t["c"], int(t["m"]), t["e"]] + [t["p"].get(p, 0) for p in pids] + t["o"])

    out = {
        "source": {
            "dataset": "DINE · Resultados provisorios Elecciones 2023 - Generales",
            "url": "https://www.argentina.gob.ar/sites/default/files/2023_generales_1.zip",
            "member": MEMBER,
            "sha256": sha256(RAW),
            "count": "PROVISORIO",
            "category": "PRESIDENTE Y VICE",
        },
        "lists": [{"letter": l, "agrupacion_id": p, "agrupacion_nombre": parties[p]} for l, p in zip(letters, pids)],
        "strata": [{"name": s, **strata[s]} for s in stratum_names],
        "columns": ["stratum", "circuito", "mesa", "electores"] + letters + [o.lower().replace(" ", "_") for o in OTHER_TYPES],
        "rows": rows,
    }
    OUT.write_text(json.dumps(out, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")

    totals = [sum(r[4 + i] for r in rows) for i in range(len(pids) + len(OTHER_TYPES))]
    print(f"tables={len(rows)} strata={len(stratum_names)} electores={sum(r[3] for r in rows)}", file=sys.stderr)
    for name, v in zip(out["columns"][4:], totals):
        print(f"  {name}: {v}", file=sys.stderr)
    print(f"wrote {OUT} sha256={sha256(OUT)}", file=sys.stderr)


if __name__ == "__main__":
    main()
