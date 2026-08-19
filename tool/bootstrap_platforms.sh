#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP="$ROOT/apps/unitflow_app"

cd "$APP"
flutter create \
  --platforms=android,web,windows,linux,macos,ios \
  --project-name unitflow \
  --org in.sanskar.unitflow \
  .

flutter pub get

echo "Flutter platform shells are ready. Run ../../tool/check.sh before committing generated changes."
