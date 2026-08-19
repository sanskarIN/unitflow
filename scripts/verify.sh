#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_DIR="$ROOT_DIR/apps/unitflow_app"

command -v cargo >/dev/null 2>&1 || { echo "cargo is required" >&2; exit 127; }
command -v flutter >/dev/null 2>&1 || { echo "flutter is required" >&2; exit 127; }
command -v dart >/dev/null 2>&1 || { echo "dart is required" >&2; exit 127; }

cd "$ROOT_DIR"
echo "==> Rust formatting"
cargo fmt --all -- --check

echo "==> Rust lint"
cargo clippy --workspace --all-targets --all-features -- -D warnings

echo "==> Rust tests"
cargo test --workspace --all-features

cd "$FLUTTER_DIR"
echo "==> Flutter dependencies"
flutter pub get

echo "==> Flutter localizations"
flutter gen-l10n

echo "==> Dart formatting"
dart format --output=none --set-exit-if-changed lib test

echo "==> Flutter analysis"
flutter analyze --fatal-infos --fatal-warnings

echo "==> Flutter tests"
flutter test

echo "UnitFlow verification completed successfully."
