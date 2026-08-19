#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter_rust_bridge_codegen >/dev/null 2>&1; then
  echo "Release verification requires flutter_rust_bridge_codegen 2.12.0." >&2
  echo "Install it with: cargo install flutter_rust_bridge_codegen --version 2.12.0 --locked" >&2
  exit 1
fi

python3 -m py_compile tool/*.py
(
  cd tool
  python3 -m unittest discover -p 'test_*.py'
)
python3 tool/check_secrets.py
python3 tool/check_data_files.py
python3 tool/check_docs_links.py

cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-features
cargo build --workspace --all-features --release

cd "$ROOT/apps/unitflow_app"
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test

cd "$ROOT"
bash tool/generate_bridge.sh
cargo fmt --all -- --check
cargo check --workspace --all-features

cd "$ROOT/apps/unitflow_app"
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test
flutter build web --release

cd "$ROOT"
if [[ -n "$(git status --porcelain --untracked-files=all)" ]]; then
  echo "Release verification changed or created repository files." >&2
  echo "Regenerate/format sources and commit the result before releasing." >&2
  git status --short >&2
  exit 1
fi

bash tool/profile_core.sh

echo "Host-independent UnitFlow release-candidate checks passed."
echo "Native platform builds, installed-app journeys, accessibility review, branding, signing, and screenshots remain platform-specific release gates."
