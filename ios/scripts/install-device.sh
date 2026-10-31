#!/usr/bin/env bash
# Builds a signed Debug app and installs it on a connected, unlocked iPhone.
# Usage: ios/scripts/install-device.sh [device-udid]   (default: first available iPhone)
set -euo pipefail
export TMPDIR="$HOME/home.codex/tmp" TMP="$HOME/home.codex/tmp" TEMP="$HOME/home.codex/tmp"
ios_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ios_root"
derived="$TMPDIR/cc-derived-data-signed"
xcodebuild -project CuentaConmigo.xcodeproj -scheme CuentaConmigo -configuration Debug \
  -destination 'generic/platform=iOS' -derivedDataPath "$derived" \
  -clonedSourcePackagesDirPath "$TMPDIR/cc-spm" -allowProvisioningUpdates build
app="$derived/Build/Products/Debug-iphoneos/CuentaConmigo.app"
device="${1:-$(xcrun devicectl list devices 2>/dev/null | awk '/iPhone/ && /available/ && !/unavailable/ {print $3; exit}')}"
if [ -z "$device" ]; then
  echo "No hay un iPhone disponible. Conectalo por cable o Wi-Fi, desbloquealo y confiá en esta Mac." >&2
  echo "App compilada en: $app" >&2
  exit 1
fi
xcrun devicectl device install app --device "$device" "$app"
xcrun devicectl device process launch --device "$device" com.kenarab.CuentaConmigo || true
