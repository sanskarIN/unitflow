# Verification Record

This document defines reproducible quality evidence for milestone and release-candidate audits. It complements `what_changed.md`; it does not replace GitHub Actions results or manual platform evidence.

## Active audit target

Branch: `audit/phase-1-quality`

Pull request: `#2`

The exact head SHA changes while defects/features are being committed. Therefore results are valid only for the commit SHA recorded by the workflow or manual verification session.

## Repository safety checks

```bash
python3 -m py_compile tool/*.py
(cd tool && python3 -m unittest discover -p 'test_*.py')
python3 tool/check_secrets.py
python3 tool/check_data_files.py
python3 tool/check_docs_links.py
```

These checks cover repository utility regressions, common credential signatures, JSON/ARB syntax and duplicate-key rejection, and internal Markdown target existence. They supplement CodeQL/dependency review rather than replacing them.

## Rust quality checks

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-features
cargo build --workspace --all-features --release
```

## Flutter quality checks

```bash
cd apps/unitflow_app
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

## Bridge reproducibility

With `flutter_rust_bridge_codegen` version `2.12.0` installed:

```bash
bash tool/generate_bridge.sh
cargo check --workspace --all-features
cd apps/unitflow_app
flutter analyze --fatal-infos --fatal-warnings
cd ../..
git status --short
```

Generated Flutter Rust Bridge sources are intentionally tracked. A release candidate must prove that bridge/platform generation leaves **no modified or untracked repository files**. `git diff --exit-code` alone is insufficient because it does not report untracked generated files; CI and release verification therefore use `git status --porcelain --untracked-files=all` for the cleanliness gate.

## Strict release-candidate command

```bash
bash tool/verify_release_candidate.sh
```

This combines repository checks, Rust/Flutter verification, bridge regeneration, release builds available on the current host, generated-source cleanliness including untracked files, and the core profiling harness. It still cannot substitute for native builds/manual journeys on other operating systems.

## GitHub-required checks

For the exact PR head, inspect and record:

- CI / Repository safety;
- CI / Rust quality;
- CI / Flutter quality;
- CI / Rust Flutter bridge;
- CodeQL;
- Dependency review;
- audit-branch generated-source/format normalization.

A queued, pending, cancelled, skipped, or superseded run is not a passing result.

## Platform/manual evidence

Release readiness additionally requires evidence described in `docs/platform-support.md` and `docs/release.md`, including:

- native/web release builds;
- installed/served primary conversion journey;
- native bridge loading where applicable;
- backup/settings behavior;
- launcher/splash branding;
- keyboard/touch/text-scaling/screen-reader-oriented accessibility review;
- real screenshots from validated builds;
- signing/provisioning where distribution requires it.

## Performance evidence

Run:

```bash
bash tool/profile_core.sh
```

Record OS, CPU, Rust toolchain, build profile, commit SHA, and output when making a release-level performance statement. Do not compare raw timing from materially different hosts as if it were a regression benchmark.

## Rules

- A failed command is a failed audit until the defect is fixed and the exact check is rerun.
- Never convert an unavailable toolchain into a passing result.
- Never treat an older green workflow as evidence for a newer commit.
- Every confirmed behavior defect should receive regression coverage when practical.
- Build/toolchain limitations belong in `what_changed.md` with exact scope.
- Generated sources are derived but must still be deterministic, reviewed through CI, tracked where required, and leave no modified/untracked drift for release.
- Security/release/accessibility/platform checks are additive to core compiler/test success.
