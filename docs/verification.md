# Verification Record

This document records reproducible quality checks for milestone audits. It complements `what_changed.md`; it does not replace CI results.

## Phase 1 audit target

Branch: `audit/phase-1-quality`

Required checks:

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-features

cd apps/unitflow_app
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

## Rules

- A failed command is a failed audit until the defect is fixed and the command is rerun.
- Never convert an unavailable toolchain into a passing result.
- Every behavior bug found by verification should receive regression coverage where practical.
- Build/toolchain limitations belong in `what_changed.md` with exact commands and errors.
- Security and release checks are additive to these core quality gates.
