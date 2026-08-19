# UnitFlow Roadmap

The roadmap is milestone-oriented. Items are checked only when repository evidence supports them; portable source code alone does not count as a verified native platform release.

## Phase 0 — Repository foundation

- [x] Repository identity and README.
- [x] License, support, privacy, security, conduct, and contribution policies.
- [x] Architecture/setup/testing/release documentation.
- [x] GitHub issue/PR templates.
- [x] CI, CodeQL, funding metadata, dependency-review workflow.
- [ ] Automated dependency update configuration (connector creation was blocked; repository settings/tooling still need completion).

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
- [ ] Commit reviewed Web project and validate a production web build.
- [ ] Commit iOS-ready native project and validate with macOS/Xcode tooling.
- [x] Keyboard shortcuts and adaptive desktop navigation.
- [ ] Reduced-motion, large-text, high-contrast, and screen-reader manual review.
- [ ] Native performance profiling and large-catalog virtualization review where measured data requires it.

## Phase 4 — Quality hardening

- [x] Core Flutter unit/widget smoke tests for converter-adjacent state, navigation, backup, batch export, and safe logging.
- [ ] Full integration tests for persisted primary journeys.
- [ ] Native end-to-end primary journeys.
- [x] Deterministic property-style tests for exact-decimal behavior plus catalog-wide Rust invariants.
- [ ] Long-running Rust/Dart fuzz targets for parsers and conversion invariants.
- [x] Developer conversion micro-benchmark.
- [ ] Catalog-search and batch-conversion benchmark baselines on documented hardware.
- [x] CodeQL/dependency-review/security design hardening in source control.
- [ ] Resolve every issue surfaced by actual clean CI/platform execution.

## Phase 5 — Release engineering

- [ ] Real screenshots and demo media from verified builds.
- [ ] Final app icon/splash source artwork and generated platform assets.
- [x] Reproducible source verification/release workflow with SHA-256 checksums.
- [ ] Native platform packaging guidance and binary artifacts validated per platform.
- [x] Release checklist, changelog, data-migration notes, and platform-support documentation baseline.
- [ ] Tag and verify `0.1.0-alpha.1` only after the blocking items below pass.

## Phase 6 — Final audit

- [ ] Clean-clone setup verification with Rust/Flutter installed.
- [ ] Full CI/check matrix passes on the release commit.
- [ ] Documentation-link audit.
- [ ] Accessibility manual review.
- [ ] Secret scan and dependency audit results reviewed.
- [ ] Release-candidate verification on every platform claimed as supported.

## Current release blockers

1. Native Flutter platform directories are not yet generated, reviewed, committed, and release-tested.
2. The production Rust↔Flutter bridge and native/Dart parity suite are not yet implemented.
3. This execution environment does not contain Rust, Flutter, or Dart, so the repository changes in this continuation have not been locally compiled or tested here.
4. GitHub combined commit status currently exposes no status contexts for the latest inspected commit, so remote workflow success has not been proven from this session.
5. Automated dependency-update configuration still needs to be added/confirmed after the connected write path blocked creation of `.github/dependabot.yml`.
6. Native integration/E2E, accessibility, and release-candidate manual checks remain open.

## Post-1.0 ideas

- Optional currency conversion provider behind an explicit online-data boundary.
- Community unit packs with signed/validated metadata.
- Shareable deep links for conversion pairs where platforms allow it.
- Additional reviewed locales and expanded educational content.
