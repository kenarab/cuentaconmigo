#!/usr/bin/env bash
# Copies shared contract files bundled by the iOS app. Tests fail if they drift.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
cp "$root/contracts/templates/generales-2023.json" "$root/ios/CuentaConmigo/Resources/generales-2023.json"
echo "contracts synced"
