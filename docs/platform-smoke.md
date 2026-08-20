# Cross-platform release build matrix

`.github/workflows/platform-smoke.yml` retains its historical filename, but it is no longer limited to debug generated-scaffold smoke checks. It now provides a six-target **release-mode build matrix** for Android, iOS, Web, Windows, Linux, and macOS.

The workflow follows a committed-first policy: when a target platform project exists in `apps/unitflow_app`, CI builds that committed project. If the target directory is absent, CI can regenerate that target with Flutter so shared-source compatibility is still exercised instead of silently skipping the platform.

## Current build matrix

The workflow builds and uploads:

- Web: `flutter build web --release` → Web release bundle;
- Android: `flutter build appbundle --release` → Android App Bundle;
- Linux: `flutter build linux --release` → Linux desktop bundle;
- Windows: `flutter build windows --release` → Windows desktop release directory;
- macOS: `flutter build macos --release` → macOS `.app` bundle;
- iOS: `flutter build ios --release --no-codesign` → release iOS `.app` compiled without distribution signing.

Each job resolves Flutter dependencies and generates localization sources before building. Desktop jobs explicitly enable their Flutter desktop target where appropriate.

## Why generation fallback remains

UnitFlow now has a deterministic platform-materialization workflow, but a checkout may still be evaluated before generated platform projects are committed. Generation fallback keeps cross-platform source compatibility testable during that transition.

The fallback is not allowed to hide partial project state. `scripts/check_platform_support.py` rejects repositories where only some of the six platform directories are committed.

Once all six generated platform projects are committed, the same build workflow automatically prefers and compiles those exact committed projects without changing the job definitions.

## What a passing release build proves

A passing target job is useful evidence that, for the workflow's Flutter and platform toolchain versions:

- the shared Dart application compiles for that target;
- required Flutter plugins resolve for that target;
- generated localization participates in the target build;
- the target's Flutter project/toolchain reaches its release compilation step;
- the expected build artifact is produced and can be uploaded by CI.

When the corresponding platform project is committed, a passing job additionally verifies the exact checked-in runner/project configuration used by that commit.

## What it does not prove

A release-mode CI build is still **not the same thing as a store-ready release**. It does not by itself prove that:

- production application identifiers, minimum OS versions, permissions, and entitlements have received final manual review;
- Android production signing or Apple signing/provisioning/notarization is configured;
- installer/store metadata is final;
- clipboard, persistence, external links, keyboard behavior, or accessibility work correctly on representative physical hardware;
- the production Rust native library is packaged and loaded through generated Flutter bindings;
- a distributed artifact installs and behaves correctly on every supported OS/device version;
- store submission requirements are satisfied.

Those checks remain in `docs/native-platforms.md` and `docs/release-checklist.md`.

## Relationship to platform materialization

`.github/workflows/materialize-platforms.yml` owns deterministic generation and commit preparation for all six Flutter platform projects. Its generated-file list is maintained in `docs/platform-file-inventory.md` through `scripts/update_platform_inventory.py`.

The intended flow is:

1. generate all six projects together with Flutter;
2. reject partial platform states;
3. stage only intended generated platform files;
4. regenerate the platform inventory;
5. run inventory, platform-contract, release-consistency, and hygiene checks;
6. commit the generated projects when execution is available;
7. run this release-build matrix against the committed result.

## Failure triage

If a platform job fails:

1. determine whether the failure is in shared Dart code, a plugin, the committed/generated platform project, Flutter itself, or the runner toolchain;
2. reproduce with the same Flutter stable release when possible;
3. do not weaken another target's source contract merely to hide the failure;
4. document a genuine upstream/toolchain limitation if no project fix is appropriate;
5. keep that target release-unverified until the failing path is resolved and rerun.

A passing source/widget test suite must not be used to dismiss a failing platform release build.
