> Automatic English translation of [`data/amba-simulation/README.md`](../../../../data/amba-simulation/README.md)
> at commit `fbe960d`. The Spanish original prevails.

# Sources for the AMBA simulation

`manifest.json` records each file downloaded for
[amba-simulation](../../sdd/specs/amba-simulation/SPEC.md): URL, license, download
date, size and SHA-256, plus the derived files with the script that generates them.

The files are in `data/private/amba-simulation/` (outside Git, due to size).
To reproduce: download each URL into `raw/`, verify the SHA-256 and run
`scripts/amba-simulation/normalize.py` and `geography.py`. The per-polling-table (mesa)
results contain no personal data.
