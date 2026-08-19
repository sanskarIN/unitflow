#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR/app"

flutter create . \
  --project-name unitflow \
  --org com.sanskarin \
  --platforms android,ios,web,windows,linux,macos

flutter pub get

echo "UnitFlow Flutter platform folders are ready."
