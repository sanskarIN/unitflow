# UnitFlow Roadmap

The roadmap is milestone-oriented. Items may move when testing reveals higher-priority reliability or accessibility work.

## Phase 0 — Repository foundation

- [x] Repository identity and README.
- [x] License, support, privacy, security, conduct, and contribution policies.
- [ ] Architecture/setup/testing/release documentation.
- [ ] GitHub issue/PR templates.
- [ ] CI, CodeQL, Dependabot, funding metadata.

## Phase 1 — Conversion MVP

- [ ] Rust workspace and `unitflow_core` crate.
- [ ] Unit/category definitions and validation.
- [ ] High-precision decimal converter.
- [ ] Static catalog covering major categories.
- [ ] Search, aliases, quick swap, notation formatting.
- [ ] Custom affine units.
- [ ] Unit and property-oriented regression tests.
- [ ] Flutter application shell and converter screen.
- [ ] Adaptive theming and accessible interaction basics.

## Phase 2 — Product completion

- [ ] Favorites, recents, pinned pairs.
- [ ] Settings and onboarding.
- [ ] Custom-unit editor.
- [ ] Batch conversion table.
- [ ] Copy/export workflows.
- [ ] Import/export backup with schema validation.
- [ ] Educational category explanations and examples.
- [ ] Locale-aware parsing/formatting.

## Phase 3 — Platform polish

- [ ] Rust↔Flutter production bridge and generated bindings workflow.
- [ ] Android, Windows, Linux, macOS, Web validation.
- [ ] iOS-ready project configuration.
- [ ] Keyboard shortcuts and desktop navigation.
- [ ] Reduced-motion and large-text review.
- [ ] Performance profiling and large-catalog virtualization where needed.

## Phase 4 — Quality hardening

- [ ] Comprehensive widget/integration tests.
- [ ] End-to-end primary journeys.
- [ ] Rust fuzz/property tests for conversion invariants and parsers.
- [ ] Benchmarks for catalog lookup and batch conversion.
- [ ] Dependency/security audit.
- [ ] Regression fixes from CI/platform testing.

## Phase 5 — Release engineering

- [ ] Real screenshots and demo media.
- [ ] App icon/splash source artwork.
- [ ] Reproducible release workflow.
- [ ] Platform packaging guidance/artifacts.
- [ ] Release notes and migration notes.

## Phase 6 — Final audit

- [ ] Clean-clone setup verification.
- [ ] Full CI matrix passes.
- [ ] Documentation-link audit.
- [ ] Accessibility manual review.
- [ ] Secret scan and dependency audit.
- [ ] Release-candidate verification.

## Post-1.0 ideas

- Optional currency conversion provider behind an explicit online-data boundary.
- Community unit packs with signed/validated metadata.
- Shareable deep links for conversion pairs where platforms allow it.
- Additional locales and educational content.
