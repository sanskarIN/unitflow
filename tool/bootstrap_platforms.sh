#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/apps/unitflow_app"
PLATFORMS="${1:-android,web,windows,linux,macos,ios}"

cd "$APP"
flutter create \
  --platforms="$PLATFORMS" \
  --project-name unitflow \
  --org in.sanskar.unitflow \
  .

flutter pub get

echo "Flutter platform shells are ready for: $PLATFORMS"
echo "Run ../../tool/check.sh before committing generated changes."
