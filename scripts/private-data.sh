#!/usr/bin/env bash
# Rebuilds every git-ignored data structure the project uses, from public sources
# listed in manifests, on a fresh computer. Each step verifies SHA-256 hashes.
# Usage: scripts/private-data.sh
set -uo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
export PYTHONDONTWRITEBYTECODE=1
status=0
step() { echo "== $1"; shift; "$@" || { echo "FALLÓ: $*" >&2; status=1; }; }
step "Simulación AMBA (data/private/amba-simulation/)" "$root/scripts/amba-simulation/build.sh"
step "Telegramas de ejemplo (data/private/ocr-samples/, ios/…/Samples/)" python3 -I "$root/scripts/samples/fetch_ocr_samples.py"
step "Archivos de la app iOS (nómina, plantilla, build-info)" "$root/ios/scripts/sync-contracts.sh"
exit $status
