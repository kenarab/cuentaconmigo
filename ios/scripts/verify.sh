#!/usr/bin/env bash
# Core contract tests + unsigned iOS build. Does not install anything.
set -euo pipefail
export TMPDIR="$HOME/home.codex/tmp" TMP="$HOME/home.codex/tmp" TEMP="$HOME/home.codex/tmp"
mkdir -p "$TMPDIR"
ios_root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ios_root/TelegramaCore"
swift test --scratch-path "$TMPDIR/cc-swift-build"
cd "$ios_root"
xcodebuild -project CuentaConmigo.xcodeproj -scheme CuentaConmigo -configuration Debug \
  -destination 'generic/platform=iOS' -derivedDataPath "$TMPDIR/cc-derived-data" \
  -clonedSourcePackagesDirPath "$TMPDIR/cc-spm" CODE_SIGNING_ALLOWED=NO build
echo "OK: tests del núcleo y compilación iOS sin firma. Falta la prueba en iPhone real."
