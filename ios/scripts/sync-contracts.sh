#!/usr/bin/env bash
# Copies shared contract files bundled by the iOS app. Tests fail if they drift.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
cp "$root/contracts/templates/generales-2023.json" "$root/ios/CuentaConmigo/Resources/generales-2023.json"
# Form of the 2015 runoff: the sample telegrams are from that election.
cp "$root/contracts/templates/balotaje-2015.json" "$root/ios/CuentaConmigo/Resources/balotaje-2015.json"
cp "$root/data/establecimientos/nomina-2025.json" "$root/ios/CuentaConmigo/Resources/nomina-2025.json"
# Commit shown in the app next to the version (git-ignored, regenerated on every build).
commit="$(git -C "$root" rev-parse --short HEAD 2>/dev/null || echo unknown)"
git -C "$root" diff --quiet HEAD -- ios contracts 2>/dev/null || commit="$commit+cambios"
printf '{"commit": "%s"}\n' "$commit" > "$root/ios/CuentaConmigo/Resources/build-info.json"
echo "contracts synced"
