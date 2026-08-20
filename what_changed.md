# UnitFlow — Development Handoff

This file is the primary continuation checkpoint for future UnitFlow development sessions so chat responses can remain short.

Last updated: **2026-08-20**

Repository: `https://github.com/sanskarIN/unitflow`

Branch: **`main`**

Current source version: **`2.0.12`**

Flutter build number: **`12`**

Latest inspected pre-handoff commit: **`5abbbdf46c5215be50c8001a7ad6ffd3e79f424f`** (`docs: update cross-platform build evidence`)

## Current release state

UnitFlow is now engineered as a six-target Flutter application for:

- Android;
- iOS;
- Web;
- Windows;
- Linux;
- macOS.

The repository has deterministic generation for all six targets, automated platform materialization, release-mode build jobs for all six targets, artifact upload, generated-platform inventory support, and a repository validator that prevents the six-target contract from silently drifting.

**Do not call `v2.0.12` a fully verified store/native release yet.** The currently inspected `main` tree still does not contain the generated Android/iOS/Web/Windows/Linux/macOS project directories, and this continuation does not have successful GitHub Actions execution evidence for the new build matrix. Production Rust↔Flutter generated bindings, real runtime E2E evidence, accessibility/performance review, and production signing/notarization also remain separate release-hardening work.

No `v2.0.12` tag was created.

## Cross-platform continuation completed

The user requested that UnitFlow become fully cross-platform supportable rather than merely list six intended targets. This continuation therefore hardened the repository around a concrete six-platform contract.

### Six-platform generation already available

The existing generation entry points cover all six targets:

- `scripts/bootstrap_platforms.sh`;
- `scripts/bootstrap_platforms.ps1`.

Both generate:

```text
android,ios,web,windows,linux,macos
```

using Flutter itself with:

```text
--org in.sanskar --project-name unitflow
```

They also run dependency resolution, localization generation, Dart formatting checks, Flutter analysis, and Flutter tests after generation.

This deliberately avoids hand-copying Flutter native templates that could become stale relative to the installed stable SDK.

### Automated platform materialization added

New workflow:

- `.github/workflows/materialize-platforms.yml`

It performs an all-or-nothing materialization process:

1. installs Java 17 and stable Flutter;
2. inspects the six platform directories;
3. rejects unsafe partial states where only some platform directories exist;
4. generates all six platform projects together when absent;
5. runs the existing Flutter bootstrap/source checks;
6. stages only `.metadata` plus Android/iOS/Web/Windows/Linux/macOS project trees;
7. regenerates the generated platform inventory;
8. validates inventory, cross-platform support, release consistency, and repository hygiene;
9. commits generated platform projects when changes exist;
10. dispatches the cross-platform release-build workflow for the committed result.

The workflow is triggerable manually and is also configured for relevant `main` changes, including Flutter app changes and platform-support/bootstrap infrastructure changes.

The workflow commit identity is configured as:

```text
Sanskar <sanskarin@outlook.in>
```

### Generated platform inventory support added

New documentation:

- `docs/platform-file-inventory.md`

New generator:

- `scripts/update_platform_inventory.py`

The main repository inventory validator now combines:

- `docs/repository-inventory.md` for human-maintained first-party files;
- `docs/platform-file-inventory.md` for machine-maintained Flutter-generated platform files.

This preserves exact `git ls-files` coverage without requiring maintainers to manually describe every generated Xcode, Gradle, CMake, runner, icon, manifest, and platform project file.

The platform inventory generator reads the staged/tracked Git index, so ignored build outputs and transient generated files are not accidentally documented as intended source files.

### Six-platform release build matrix implemented

`.github/workflows/platform-smoke.yml` retains its historical filename for continuity, but its behavior was promoted from debug scaffold smoke testing to a release-mode cross-platform build matrix.

Current target builds:

- Web: `flutter build web --release`;
- Android: `flutter build appbundle --release`;
- Linux: `flutter build linux --release`;
- Windows: `flutter build windows --release`;
- macOS: `flutter build macos --release`;
- iOS: `flutter build ios --release --no-codesign`.

Each target uploads its resulting build artifact through `actions/upload-artifact@v4`.

The workflow is committed-first: if a platform directory exists, it builds that checked-in project. If the directory is absent, it regenerates that one target before compiling it so platform compatibility is not silently skipped during the transition to committed projects.

The iOS job deliberately uses `--no-codesign`; Apple signing/provisioning credentials are distribution secrets and are not required to prove that the iOS source compiles in release mode.

### Cross-platform support validator added

New file:

- `scripts/check_platform_support.py`

The validator treats the six-platform contract as an executable repository invariant.

It requires:

- exactly the six intended target identifiers;
- a build job for every target in `.github/workflows/platform-smoke.yml`;
- the expected release build command for every target;
- all six targets to be referenced by the platform materialization workflow;
- all six targets to be referenced by both Bash and PowerShell bootstrap scripts;
- committed platform projects to be either all present or all absent, never partially committed;
- shared Flutter libraries to avoid a plain unconditional `import 'dart:io';` that would make that library unavailable on Web.

The validator reports the platform state as either:

- `materialized` — all six generated platform projects are present;
- `generation-ready` — none are committed yet but the six-target generation/build contract is intact.

### Cross-platform validator wired everywhere

`scripts/check_platform_support.py` is now executed from:

- `scripts/verify.sh`;
- `scripts/verify.ps1`;
- `.github/workflows/ci.yml` repository-integrity job;
- `.github/workflows/release.yml`;
- `.github/workflows/materialize-platforms.yml` after generated projects are staged.

Therefore a later edit cannot silently remove one supported target without breaking normal verification/release gates.

### Cross-platform validator regression coverage added

`scripts/tests/test_repository_validators.py` now checks:

- the platform inventory infrastructure is documented;
- generated platform inventory lines use the expected inventory format;
- all six target prefixes are owned by the generated inventory tool;
- `scripts/check_platform_support.py` exposes exactly Android/iOS/Web/Windows/Linux/macOS;
- every platform has a release build command;
- every build command is release-mode;
- the current repository satisfies the cross-platform contract.

### Repository hygiene hardened

`scripts/check_repository_hygiene.py` now requires the new cross-platform infrastructure to remain present:

- `.github/workflows/materialize-platforms.yml`;
- `docs/platform-file-inventory.md`;
- `scripts/check_platform_support.py`;
- `scripts/update_platform_inventory.py`.

Signing credentials such as `.jks`, `.keystore`, `.p12`, and `.mobileprovision` remain forbidden from tracked source.

### Documentation refreshed

Updated documentation includes:

- `README.md` — publishes the enforced six-platform target matrix, release build paths, generation commands, and distinction between compilation and production signing;
- `docs/platform-support.md` — defines the supported targets, cross-platform repository contract, materialization workflow, build-versus-distribution boundary, and shared acceptance criteria;
- `docs/platform-smoke.md` — rewritten around the release-mode cross-platform build matrix while retaining the historical workflow filename;
- `ROADMAP.md` — records six-platform generation/materialization/build-contract automation as complete while keeping committed-project execution and release-candidate evidence open;
- `CHANGELOG.md` — records the 2.0.12 six-platform hardening work;
- this handoff.

## Previous 2.0.12 hardening retained

Before this cross-platform continuation, the same 2.0.12 development cycle had already added or fixed:

- Rust authoritative exact-decimal conversion domain;
- versioned Rust bridge source service and safe bridge DTO/error contract;
- shared Rust/Dart parity fixture consumption;
- bridge protocol version drift validation across Rust source, fixture, and documentation;
- rounding-mode serialization parity;
- Rust 1.82 minimum alignment;
- custom-unit alias bounds;
- deterministic Dart exact-decimal compatibility engine;
- locale-aware parsing and Indian/Western grouping support;
- persistence schema migration and bounded backup import;
- persistence write/reset race protection;
- safe reset-failure UX;
- recent-history reference/input validation;
- persisted primary controller/repository journey tests;
- repository inventory/link/release/hygiene validators;
- CI, CodeQL, dependency review, Dependabot, and source release automation.

## Current platform support interpretation

### Source-supported targets

All six are now first-class enforced targets:

1. Android
2. iOS
3. Web
4. Windows
5. Linux
6. macOS

### Build automation

The repository contains release-mode build definitions for every target and build artifact upload definitions for every target.

### Platform project directories

At the latest inspected live tree in this continuation, the six generated platform directories were still absent from `apps/unitflow_app`.

The repository now contains the workflow and inventory machinery to materialize them safely, but the current execution environment cannot run Flutter and connected repository writes did not produce an observable materialization commit during this continuation.

Do not claim the platform directories are committed until live `main` actually contains all six.

## Verification evidence and limitations

### Authenticated GitHub inspection

The GitHub integration was used repeatedly to inspect and modify live `main`, including workflows, validators, docs, roadmap, changelog, scripts, tests, and recursive tree state.

### Local toolchain limitation

The available execution container reports Git and Python, but does not have:

- Flutter;
- Dart;
- Cargo/Rust;
- native Android/iOS/Windows/macOS/Linux build toolchains.

A direct clone attempt also failed because the container could not resolve `github.com` through DNS.

Therefore this continuation does **not** claim local successful output for:

- `flutter create`;
- Flutter release builds;
- `flutter analyze`;
- `flutter test`;
- Cargo formatting/Clippy/tests;
- native platform execution.

### GitHub Actions evidence

No generated-platform materialization commit named `build: materialize six Flutter platform projects` was observed during this continuation, and no final green six-platform Actions matrix was established through the available connected workflow-status tools.

Workflow definitions are implementation evidence, not proof that a runner execution passed.

## Remaining blockers before calling `v2.0.12` fully release-verified

1. Materialize/review/commit all six Flutter platform directories and `.metadata` on live `main`.
2. Run and review the six-platform release build matrix against those committed projects.
3. Fix any real target-specific build failures surfaced by execution.
4. Implement generated Rust↔Flutter native bindings and startup protocol negotiation.
5. Package/load the Rust native library on every native target where Rust authority is claimed.
6. Add rendered UI integration and native E2E journeys across representative targets.
7. Perform accessibility review: screen reader, keyboard/focus, large text, contrast, reduced motion, and touch targets.
8. Record performance/search/batch/native profiling baselines where release decisions need them.
9. Produce final app icons/splash assets/screenshots/demo media from verified builds.
10. Validate Android production signing and Apple signing/provisioning/notarization without committing credentials.
11. Complete clean-clone and downloaded-artifact release-candidate verification.
12. Complete `docs/release-checklist.md`.
13. Only then create and verify the exact `v2.0.12` tag.

## Exact next continuation priority

1. Inspect live `main` first for all six generated platform directories.
2. Inspect the latest cross-platform GitHub Actions results.
3. If platform directories are still absent, execute `.github/workflows/materialize-platforms.yml` from a GitHub Actions-capable context or run `scripts/bootstrap_platforms.sh`/`.ps1` with Flutter installed, then commit the generated result and refreshed platform inventory.
4. Fix every actual six-platform build failure before moving on.
5. Continue with generated Rust↔Flutter bindings and native packaging.
6. Add native E2E/accessibility/performance/release-candidate evidence.

## Cross-platform continuation commits

Meaningful commits created during this continuation include:

- `3aa557ac` — `docs: add generated platform file inventory`
- `96cb801f` — `build: add platform inventory generator`
- `2e865223` — `build: support generated platform inventory`
- `62992005` — `ci: add automatic Flutter platform materialization`
- `d080e182` — `ci: promote six-platform release build matrix`
- `5a731a8d` — `docs: inventory platform materialization infrastructure`
- `ec5c9e9b` — `test: cover cross-platform inventory infrastructure`
- `a3732759` — `build: enforce six-platform support contract`
- `bf535fff` — `docs: inventory cross-platform validator`
- `ac58550f` — `build: verify cross-platform support in Bash`
- `395d5935` — `build: verify cross-platform support in PowerShell`
- `8698e530` — `ci: enforce cross-platform support contract`
- `1c6beb92` — `release: require cross-platform support validation`
- `89f6f4ac` — `docs: define enforced six-platform support`
- `3539d20f` — `docs: advance six-platform roadmap`
- `2837f463` — `build: require cross-platform support infrastructure`
- `5f74273b` — `ci: harden platform materialization trigger`
- `125e27bf` — `test: cover six-platform support validator`
- `b93f3db7` — `docs: publish enforced six-platform support`
- `33817d29` — `docs: record six-platform hardening`
- `5abbbdf4` — `docs: update cross-platform build evidence`

This handoff update follows those commits.

## Commit identity note

Requested local identity remains:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

GitHub connector-created commits do not expose a per-write author/committer email override. The materialization workflow itself explicitly configures the requested identity before its generated-platform commit.

## Handoff rules

For future continuation work:

1. inspect live `main` before trusting this file;
2. prefer compiler/test/workflow evidence over workflow definitions;
3. keep all six platform targets synchronized;
4. never accept a partially committed platform-project set;
5. regenerate `docs/platform-file-inventory.md` whenever generated platform files change;
6. keep production signing credentials out of source control;
7. update this file after meaningful work;
8. do not tag or call `v2.0.12` release-verified while evidence blockers remain open.
