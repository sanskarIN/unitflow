#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FLUTTER_DIR="$ROOT_DIR/apps/unitflow_app"

for command in git python3 cargo flutter dart; do
  command -v "$command" >/dev/null 2>&1 || { echo "$command is required" >&2; exit 127; }
done

cd "$ROOT_DIR"
echo "==> Repository validator tests"
python3 -m unittest discover -s scripts/tests -p 'test_*.py'

echo "==> Markdown links"
python3 scripts/check_markdown_links.py

echo "==> Release consistency"
python3 scripts/check_release_consistency.py

echo "==> Repository hygiene"
python3 scripts/check_repository_hygiene.py

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
