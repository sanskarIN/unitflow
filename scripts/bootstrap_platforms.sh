#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/apps/unitflow_app"
PLATFORMS=(android ios web windows linux macos)

command -v flutter >/dev/null 2>&1 || {
  echo "flutter is required and was not found on PATH" >&2
  exit 127
}

for platform in "${PLATFORMS[@]}"; do
  if [[ -e "$APP_DIR/$platform" ]]; then
    echo "Refusing to generate platform scaffolding because $APP_DIR/$platform already exists." >&2
    echo "Review existing native projects manually instead of regenerating them blindly." >&2
    exit 2
  fi
done

cd "$APP_DIR"

echo "==> Generating reviewed-target Flutter platform scaffolding"
flutter create \
  --platforms=android,ios,web,windows,linux,macos \
  --org in.sanskar \
  --project-name unitflow \
  .

echo "==> Resolving dependencies and generated localization sources"
flutter pub get
flutter gen-l10n

echo "==> Running Flutter source checks after generation"
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test

cat <<'EOF'

Platform scaffolding was generated locally.

Do not commit it without reviewing:
- application/bundle identifiers;
- minimum/target platform versions;
- Android permissions and signing files;
- Apple entitlements and signing settings;
- desktop runner metadata and icons;
- Web manifest/HTML/CSP assumptions;
- any generated changes outside native platform directories.

Then run the platform-specific release/smoke checks in docs/native-platforms.md.
EOF
