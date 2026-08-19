#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/apps/unitflow_app"
BRIDGE="$ROOT/crates/unitflow_bridge"

if ! command -v flutter_rust_bridge_codegen >/dev/null 2>&1; then
  echo "flutter_rust_bridge_codegen is required (expected 2.12.x)." >&2
  echo "Install it with: cargo install flutter_rust_bridge_codegen --version 2.12.0 --locked" >&2
  exit 1
fi

cd "$APP"
flutter_rust_bridge_codegen generate \
  --rust-root "$BRIDGE" \
  --rust-input crate::api \
  --dart-output lib/src/rust

echo "Rust↔Dart bridge code generated. Run tool/check.sh before committing generated changes."
