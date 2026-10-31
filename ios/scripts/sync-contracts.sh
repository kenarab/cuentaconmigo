#!/usr/bin/env bash
# Copies shared contract files bundled by the iOS app. Tests fail if they drift.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
cp "$root/contracts/templates/demo-2027.json" "$root/ios/CuentaConmigo/Resources/demo-2027.json"
echo "contracts synced"
