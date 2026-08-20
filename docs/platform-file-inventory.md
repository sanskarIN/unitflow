# Generated Flutter platform file inventory

This file is machine-maintained by `scripts/update_platform_inventory.py` for the generated section below.

It lists Flutter-generated platform scaffold files that are intentionally committed under `apps/unitflow_app`, plus the small set of platform-materialization infrastructure files that own this generated inventory. The broader human-oriented role descriptions remain in `docs/repository-inventory.md`.

Do not edit the generated platform-file list by hand. After adding, removing, or regenerating a platform project, stage the intended platform files and run:

```bash
python3 scripts/update_platform_inventory.py
```

The main repository inventory validator combines this file with `docs/repository-inventory.md` and still requires every tracked file to be documented exactly once.

## Platform support infrastructure

- `docs/platform-file-inventory.md` — machine-maintained inventory for committed Flutter platform scaffold files.
- `scripts/update_platform_inventory.py` — regenerates the platform scaffold inventory from the staged/tracked Git index.
- `scripts/check_platform_support.py` — validates the six-target generation/build contract, partial-scaffold state, and Web-safe shared Dart imports.
- `.github/workflows/materialize-platforms.yml` — generates, validates, inventories, and commits all six Flutter platform projects using stable Flutter.

## Tracked generated platform files

<!-- UNITFLOW_PLATFORM_FILES_START -->

No Flutter platform scaffold files are committed yet.

<!-- UNITFLOW_PLATFORM_FILES_END -->
