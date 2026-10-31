#!/usr/bin/env bash
# Rebuilds the AMBA simulation data on any computer: download + verify the official
# sources, derive per-table results and strata, check hashes and bundle them next to
# the prototype. Usage: scripts/amba-simulation/build.sh
set -euo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
export PYTHONDONTWRITEBYTECODE=1
python3 -I "$here/fetch.py"
python3 -I "$here/normalize.py"
python3 -I "$here/geography.py"
python3 -I "$here/bundle.py"
