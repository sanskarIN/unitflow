#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

python3 tool/check_secrets.py
python3 tool/check_data_files.py
python3 tool/check_docs_links.py

cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-features

cd "$ROOT/apps/unitflow_app"
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test

cd "$ROOT"
if command -v flutter_rust_bridge_codegen >/dev/null 2>&1; then
  bash tool/generate_bridge.sh
  cargo check --workspace --all-features
  cd "$ROOT/apps/unitflow_app"
  flutter analyze --fatal-infos --fatal-warnings
else
  echo "flutter_rust_bridge_codegen not found; bridge regeneration check skipped." >&2
  echo "Install the pinned generator before release-candidate verification." >&2
fi
