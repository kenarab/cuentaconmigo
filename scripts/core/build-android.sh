#!/usr/bin/env bash
# Builds the shared Rust core for Android and regenerates its Kotlin bindings.
# Needs: Android NDK in $ANDROID_HOME/ndk, rustup targets aarch64/x86_64-linux-android, cargo-ndk.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export ANDROID_NDK_HOME="${ANDROID_NDK_HOME:-$(ls -d "$ANDROID_HOME"/ndk/* | sort -V | tail -1)}"
export CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-$HOME/home.codex/tmp/cc-core-target}"
app="$root/android/app/src/main"
cd "$root/core"
cargo ndk -t arm64-v8a -t x86_64 -o "$app/jniLibs" build --release --lib
# Bindings come from the host build of the same sources (UniFFI library mode).
cargo build --release --lib
cargo run --release --bin uniffi-bindgen generate --library "$CARGO_TARGET_DIR/release/libcc_core.so" \
  --language kotlin --out-dir "$app/java" --no-format
# Official sample telegrams (git-ignored, personal data): reuse the iOS copy or fetch them.
samples="$root/ios/CuentaConmigo/Resources/Samples"
[ -d "$samples" ] || python3 "$root/scripts/samples/fetch_ocr_samples.py" || true
if [ -d "$samples" ]; then mkdir -p "$app/assets/samples" && cp "$samples"/* "$app/assets/samples/"; fi
echo "core built: $app/jniLibs, bindings in $app/java/uniffi/cc_core"
