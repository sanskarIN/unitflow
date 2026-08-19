# Release checklist

Use this checklist for every tagged UnitFlow release. A checked item should represent an observed result, not an assumption based only on source code.

## Source and versioning

- [ ] Working tree is clean and expected commits are on `main`.
- [ ] Release version is consistent in Cargo workspace and Flutter package metadata.
- [ ] `CHANGELOG.md` includes user-visible changes and known limitations.
- [ ] `what_changed.md` contains a current continuation checkpoint.
- [ ] No temporary debugging code, generated secrets, or local paths are committed.

## Rust quality gates

- [ ] `cargo fmt --all -- --check` passes.
- [ ] `cargo clippy --workspace --all-targets --all-features -- -D warnings` passes.
- [ ] `cargo test --workspace --all-features` passes.
- [ ] Catalog invariants pass for every category and built-in unit.
- [ ] Security/dependency review has no unresolved release-blocking finding.

## Flutter quality gates

Run from `apps/unitflow_app`:

- [ ] `flutter pub get` succeeds.
- [ ] `dart format --output=none --set-exit-if-changed lib test` passes.
- [ ] `flutter analyze --fatal-infos --fatal-warnings` passes.
- [ ] `flutter test` passes.
- [ ] Main converter, batch, library, history, settings, onboarding, and custom-unit flows receive smoke coverage.

## Data compatibility

- [ ] Existing schema-version-1 backup imports successfully.
- [ ] Invalid/oversized backups are rejected without replacing active data.
- [ ] Custom-unit deletion removes dangling favorites, pins, and recents.
- [ ] Exported backup can be imported into a clean installation.
- [ ] Stable built-in IDs were not changed without an explicit migration.

## Platform validation

For every platform advertised as supported in this release:

- [ ] Native project builds in release configuration.
- [ ] App launches offline.
- [ ] Representative conversions are correct.
- [ ] Persistence survives restart.
- [ ] Backup/import interaction works with platform file/clipboard UX.
- [ ] Keyboard navigation is checked where relevant.
- [ ] Screen-reader labels and large text are manually reviewed.
- [ ] No unnecessary runtime permission is requested.

## Release artifact checks

- [ ] Tag points at the intended commit.
- [ ] Release workflow reruns quality gates successfully.
- [ ] Source packages are produced.
- [ ] SHA-256 checksum file matches uploaded artifacts.
- [ ] Release notes identify any unverified platform or known limitation.
- [ ] Downloaded release artifact is smoke-tested independently from the development tree.

## Post-release

- [ ] GitHub release page is complete.
- [ ] Roadmap is updated for the next milestone.
- [ ] Any deferred bugs have issues with reproducible acceptance criteria.
- [ ] Security contact and support documentation remain accurate.
