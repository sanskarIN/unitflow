# Release checklist

Use this checklist for every tagged UnitFlow release. A checked item should represent an observed result, not an assumption based only on source code or generated temporary scaffolding.

## Source and versioning

- [ ] Working tree is clean and expected commits are on `main`.
- [ ] Release version is consistent in Cargo workspace, Flutter package metadata, About UI, and changelog.
- [ ] Intended tag passes `python3 scripts/check_release_tag.py <tag>`.
- [ ] `CHANGELOG.md` includes user-visible changes and known limitations.
- [ ] `ROADMAP.md` accurately distinguishes completed work from release blockers.
- [ ] `what_changed.md` contains a current continuation checkpoint.
- [ ] `docs/repository-inventory.md` documents every tracked file exactly once.
- [ ] No temporary debugging code, generated secrets, local paths, `.env` files, or signing material are committed.

## Repository integrity gates

- [ ] `python3 -m unittest discover -s scripts/tests -p 'test_*.py'` passes.
- [ ] `python3 scripts/check_repository_inventory.py` passes.
- [ ] `python3 scripts/check_markdown_links.py` passes.
- [ ] `python3 scripts/check_release_consistency.py` passes.
- [ ] `python3 scripts/check_repository_hygiene.py` passes.
- [ ] Dependabot configuration exists for Cargo, Flutter/Dart packages, and GitHub Actions.

## Rust quality gates

- [ ] `cargo fmt --all -- --check` passes.
- [ ] `cargo clippy --workspace --all-targets --all-features -- -D warnings` passes.
- [ ] `cargo test --workspace --all-features` passes.
- [ ] Catalog invariants pass for every category and built-in unit.
- [ ] Security/dependency review has no unresolved release-blocking finding.

## Flutter quality gates

Run from `apps/unitflow_app`:

- [ ] `flutter pub get` succeeds.
- [ ] `flutter gen-l10n` succeeds.
- [ ] `dart format --output=none --set-exit-if-changed lib test` passes.
- [ ] `flutter analyze --fatal-infos --fatal-warnings` passes.
- [ ] `flutter test` passes.
- [ ] Main converter, batch, library, history, settings, onboarding, and custom-unit flows receive smoke coverage.

## Data compatibility

- [ ] Existing schema-version-1 backup imports successfully.
- [ ] Invalid/oversized backups are rejected without replacing active data.
- [ ] Production and memory/test repositories enforce the same import-size/object/key validation boundary.
- [ ] Pending writes cannot repopulate pre-reset data after a completed reset.
- [ ] Recent-history records reject invalid references/bounds while preserving valid locale-formatted original text.
- [ ] Custom-unit deletion removes dangling favorites, pins, and recents.
- [ ] Exported backup can be imported into a clean installation.
- [ ] Stable built-in IDs were not changed without an explicit migration.

## Bridge validation

- [ ] Documented bridge protocol version matches the shared parity fixture.
- [ ] Dart and Rust parity vectors pass.
- [ ] Production native Rust↔Flutter bindings are generated/reviewed for every native platform claimed by the release.
- [ ] Native packaging loads the intended Rust library rather than silently relying on the Dart fallback where Rust is claimed authoritative.

## Platform validation

Generated scaffold smoke jobs are useful preliminary evidence but do not satisfy the following release checks.

For every platform advertised as supported in this release:

- [ ] Reviewed native platform project is committed.
- [ ] Committed native project builds in the intended release configuration.
- [ ] App launches offline on representative hardware/simulator/browser.
- [ ] Representative conversions are correct.
- [ ] Persistence survives restart.
- [ ] Backup/import interaction works with platform file/clipboard UX.
- [ ] Keyboard navigation is checked where relevant.
- [ ] Screen-reader labels and large text are manually reviewed.
- [ ] Reduced-motion/high-contrast behavior is reviewed where supported.
- [ ] No unnecessary runtime permission, entitlement, or network dependency is introduced.

## Release artifact checks

- [ ] Tag points at the exact intended audited commit.
- [ ] Tag exactly equals `v` plus the repository package version.
- [ ] Tag-triggered release workflow reruns repository, Rust, and Flutter quality gates successfully.
- [ ] Source packages are produced.
- [ ] SHA-256 checksum file matches uploaded source artifacts.
- [ ] Native binary/installable artifacts, when published, are built from the audited committed platform projects.
- [ ] Release notes identify every unverified platform or known limitation.
- [ ] Downloaded release artifact is smoke-tested independently from the development tree.

## Post-release

- [ ] GitHub release page is complete.
- [ ] Roadmap is updated for the next milestone.
- [ ] Any deferred bugs have issues with reproducible acceptance criteria.
- [ ] Security contact and support documentation remain accurate.
- [ ] Dependency-update PRs continue to be reviewed rather than auto-merged without tests.
