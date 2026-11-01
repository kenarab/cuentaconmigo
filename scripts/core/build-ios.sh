#!/usr/bin/env bash
# Builds the shared Rust core as an XCFramework and its Swift bindings (run on the Mac).
# Needs: rustup targets aarch64-apple-ios aarch64-apple-ios-sim.
set -euo pipefail
root="$(cd "$(dirname "$0")/../.." && pwd)"
export CARGO_TARGET_DIR="${CARGO_TARGET_DIR:-$HOME/home.codex/tmp/cc-core-target}"
out="$root/ios/CCCore"
cd "$root/core"
for t in aarch64-apple-ios aarch64-apple-ios-sim; do cargo build --release --lib --target "$t"; done
cargo build --release --lib
rm -rf "$out" && mkdir -p "$out/headers" "$out/Sources"
cargo run --release --bin uniffi-bindgen generate --library "$CARGO_TARGET_DIR/release/libcc_core.dylib" \
  --language swift --out-dir "$out/gen" --no-format
mv "$out/gen/cc_coreFFI.h" "$out/headers/" && mv "$out/gen/cc_coreFFI.modulemap" "$out/headers/module.modulemap"
mv "$out/gen/cc_core.swift" "$out/Sources/" && rm -rf "$out/gen"
xcodebuild -create-xcframework \
  -library "$CARGO_TARGET_DIR/aarch64-apple-ios/release/libcc_core.a" -headers "$out/headers" \
  -library "$CARGO_TARGET_DIR/aarch64-apple-ios-sim/release/libcc_core.a" -headers "$out/headers" \
  -output "$out/CCCoreFFI.xcframework"
echo "core built: $out (add CCCoreFFI.xcframework and Sources/cc_core.swift to the app)"
