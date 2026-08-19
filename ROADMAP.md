# UnitFlow Roadmap

The roadmap is milestone-oriented. Items are checked only when repository evidence supports them; portable source code or generated temporary scaffolding alone does not count as a verified native platform release.

## Phase 0 — Repository foundation

- [x] Repository identity and README.
- [x] License, support, privacy, security, conduct, and contribution policies.
- [x] Architecture/setup/testing/release documentation.
- [x] GitHub issue/PR templates and code ownership.
- [x] CI, CodeQL, funding metadata, and dependency-review workflow.
- [x] Automated Dependabot configuration for Cargo, Flutter/Dart, and GitHub Actions.
- [x] Repository-local Markdown, release-consistency, hygiene, and release-tag validators with regression tests.

## Phase 1 — Conversion MVP

- [x] Rust workspace and `unitflow_core` crate.
- [x] Unit/category definitions and validation.
- [x] High-precision decimal converter.
- [x] Static catalog covering major categories.
- [x] Search, aliases, quick swap, notation formatting.
- [x] Custom affine units.
- [x] Unit and property-oriented regression tests.
- [x] Flutter application shell and converter screen.
- [x] Adaptive theming and accessible interaction basics.

## Phase 2 — Product completion

- [x] Favorites, recents, pinned pairs.
- [x] Settings and onboarding.
- [x] Custom-unit editor.
- [x] Dedicated batch conversion table.
- [x] CSV, TSV, JSON, clipboard copy, and local-state backup/import workflows.
- [x] Import/export backup with schema validation and version-1 → version-2 migration.
- [x] Consistent production/test import bounds and atomic state replacement.
- [x] Serialized reset behavior that cannot be overwritten by older queued saves.
- [x] Recent-history reference/category/input-bound validation.
- [x] Educational category explanations and examples.
- [x] Locale-aware parsing/formatting architecture.
- [x] English generated localization resource catalog for primary user-facing flows.
- [x] User-selected explicit rounding mode persisted and applied to conversions.

## Phase 3 — Platform polish

- [ ] Rust↔Flutter production bridge and generated bindings workflow.
- [ ] Commit reviewed Android native Flutter project and validate a release build.
- [ ] Commit reviewed Windows native Flutter project and validate a release build.
- [ ] Commit reviewed Linux native Flutter project and validate a release build.
- [ ] Commit reviewed macOS native Flutter project and validate a release build.
- [ ] Commit reviewed Web project and validate a production Web build.
- [ ] Commit iOS-ready native project and validate with macOS/Xcode tooling.
- [x] Generated-scaffold smoke jobs for Android, Web, Linux, Windows, macOS, and iOS as preliminary compatibility evidence.
- [x] Keyboard shortcuts and adaptive desktop navigation.
- [ ] Reduced-motion, large-text, high-contrast, and screen-reader manual review.
- [ ] Native performance profiling and large-catalog virtualization review where measured data requires it.

## Phase 4 — Quality hardening

- [x] Core Flutter unit/widget smoke tests for converter-adjacent state, navigation, backup, batch export, and safe logging.
- [x] Persistence race/reference/import-bound regression tests for identified state defects.
- [ ] Full integration tests for persisted primary journeys.
- [ ] Native end-to-end primary journeys.
- [x] Deterministic property-style tests for exact-decimal behavior plus catalog-wide Rust invariants.
- [ ] Long-running Rust/Dart fuzz targets for parsers and conversion invariants.
- [x] Developer conversion micro-benchmark.
- [ ] Catalog-search and batch-conversion benchmark baselines on documented hardware.
- [x] CodeQL/dependency-review/security design hardening in source control.
- [x] Normal CI and release workflows enforce repository-integrity validation before language/package gates.
- [ ] Resolve every issue surfaced by actual clean CI/platform execution.

## Phase 5 — Release engineering

- [ ] Real screenshots and demo media from verified builds.
- [ ] Final app icon/splash source artwork and generated platform assets.
- [x] Reproducible source verification/release workflow with SHA-256 checksums.
- [x] Release workflow rejects a `v*` tag that does not exactly match the Cargo workspace version.
- [ ] Native platform packaging guidance and binary artifacts validated per platform.
- [x] Release checklist, changelog, data-migration notes, and platform-support documentation baseline.
- [ ] Tag and verify `2.0.12` only after the blocking items below pass.

## Phase 6 — Final audit

- [ ] Clean-clone setup verification with required Python/Rust/Flutter/native toolchains installed.
- [ ] Full CI/check matrix passes on the release commit.
- [ ] Documentation-link audit result reviewed on the release commit (automated checker is implemented and wired to CI).
- [ ] Accessibility manual review.
- [ ] Secret scan and dependency/security findings reviewed.
- [ ] Release-candidate verification on every platform claimed as supported.

## Current release blockers

1. Reviewed native Flutter platform directories are not yet committed and release-tested. The generated-scaffold workflow is preliminary compatibility evidence only.
2. The production Rust↔Flutter bridge/generated binding workflow and native packaging are not yet implemented; Dart/native parity fixtures do not substitute for a production bridge.
3. This execution environment does not provide the Rust/Flutter/Dart/native toolchains needed to compile the current repository changes locally, so no local full verification result is claimed for this checkpoint.
4. A successful full GitHub Actions check matrix for the final release commit has not yet been established/reviewed in this continuation.
5. Native integration/E2E journeys, accessibility review, performance baselines, and release-candidate manual checks remain open where listed above.
6. Real release media/assets and platform-native distributable artifacts remain intentionally deferred until verified native builds exist.

## Post-1.0 ideas

- Optional currency conversion provider behind an explicit online-data boundary.
- Community unit packs with signed/validated metadata.
- Shareable deep links for conversion pairs where platforms allow it.
- Additional reviewed locales and expanded educational content.
