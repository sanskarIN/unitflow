# Generated platform smoke builds

UnitFlow keeps reviewed native Flutter projects as an explicit release milestone. Until those platform directories are committed, `.github/workflows/platform-smoke.yml` performs a second, narrower kind of check: it generates a temporary platform scaffold in a clean runner and verifies that the shared Flutter source can be compiled by that target toolchain.

## Current smoke matrix

The workflow contains generated-scaffold build jobs for:

- Web release build on Ubuntu;
- Android debug APK on Ubuntu;
- Linux debug desktop bundle on Ubuntu;
- Windows debug desktop bundle on `windows-latest`;
- macOS debug desktop app on `macos-latest`;
- iOS debug simulator app on `macos-latest`.

Each job starts from a fresh checkout and runs `flutter create --platforms=<target> --org in.sanskar --project-name unitflow .` inside `apps/unitflow_app`. The generated native files exist only in that workflow runner unless deliberately reviewed and committed later.

## What a passing smoke build proves

A passing job is useful evidence that, for the workflow's Flutter/toolchain version:

- shared Dart source compiles for the target;
- required Flutter plugins can be resolved for the target;
- generated localization code participates in the build;
- the generated default runner can reach the final debug/release build step used by the job.

## What it does not prove

A generated-scaffold smoke build is **not** release verification. It does not prove that:

- UnitFlow's final package/bundle/application identifiers have been reviewed;
- native permissions and entitlements are minimal;
- app icons, splash resources, signing, notarization, installer metadata, or store configuration are complete;
- clipboard, persistence, external links, keyboard behavior, or accessibility work correctly at runtime;
- the production Rust native library is packaged and loaded;
- a distributed artifact installs on representative user hardware;
- store submission requirements are satisfied.

Those checks remain in `docs/native-platforms.md` and `docs/release-checklist.md`.

## Why the workflow generates scaffolding

This separation keeps two facts clear during alpha development:

1. portable Flutter source can be compiled against multiple platform toolchains as early as possible;
2. committing native projects is a deliberate review step rather than an accidental side effect of running `flutter create` with an arbitrary local SDK.

When reviewed platform directories are committed, the workflow should be changed to build those committed projects directly. At that point the scaffold-generation step should be removed for the corresponding target so CI verifies the exact files intended for release.

## Failure triage

If a generated-platform job fails:

1. determine whether the failure is in shared Dart code, a plugin, Flutter scaffold generation, or the runner toolchain;
2. reproduce with the same Flutter stable release when possible;
3. do not weaken another platform's source contract merely to hide the failure;
4. document a genuine upstream/toolchain limitation if no project fix is appropriate;
5. keep the platform unverified until the failing path is resolved and rerun.

A passing source/widget test suite must not be used to dismiss a failing platform smoke build.
