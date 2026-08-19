# UnitFlow Roadmap

The roadmap is milestone-oriented. A checked source-level item means the implementation exists on the active development branch; it does **not** imply that every release/platform gate has passed. Platform/manual/release checks stay open until concrete evidence exists for the exact release candidate.

## Phase 0 — Repository foundation

- [x] Repository identity and README.
- [x] MIT license, support, privacy, security, conduct, and contribution policies.
- [x] Architecture/setup/testing/release/troubleshooting documentation.
- [x] GitHub issue/PR templates.
- [x] CI, CodeQL, dependency review, Dependabot, funding metadata.
- [x] Internal documentation-link, structured-data, and common secret-pattern checks.
- [x] Canonical development handoff workflow through `what_changed.md`.

## Phase 1 — Conversion MVP

- [x] Rust workspace and `unitflow_core` crate.
- [x] Unit/category definitions and validation.
- [x] High-precision decimal converter.
- [x] Explicit rounding modes and precision validation.
- [x] Static catalog covering major categories.
- [x] Search, aliases, descriptions, quick swap, notation formatting.
- [x] Custom affine units.
- [x] Unit/property/regression test coverage foundations.
- [x] Flutter application shell and converter screen.
- [x] Adaptive theming and accessible interaction foundations.
- [x] Deterministic exact-decimal Dart fallback.

## Phase 2 — Product completion

- [x] Favorites, recents, pinned pairs.
- [x] Settings and onboarding.
- [x] Custom-unit editor with validated formulas.
- [x] Batch conversion table and deterministic CSV copying.
- [x] File/clipboard backup and restore with bounded validation.
- [x] Versioned backup schema and v1 → v2 migration.
- [x] Strict backup property/identifier/collection validation aligned with checked-in schemas.
- [x] Shared production/test backup decoding and canonical custom-unit persistence.
- [x] Educational category explanations and examples.
- [x] Locale-aware parsing/formatting foundations.
- [x] Generated localization infrastructure and English source catalog.
- [x] Clear-history/undo and custom-unit removal/undo flows.
- [x] User-safe error presentation backed by redacting diagnostics.
- [x] User-initiated official release-page access without background update tracking.

## Phase 3 — Platform polish

- [x] Rust↔Flutter bridge crate/API and generated-bindings workflow scaffolding.
- [x] Android/Windows/Linux/macOS/Web/iOS build targets represented in release automation.
- [x] Keyboard shortcuts and adaptive desktop navigation.
- [x] Explicit reduced-motion setting and platform animation preference handling.
- [x] Project-authored reusable UnitFlow mark and editable vector source.
- [x] Platform support/branding/bridge documentation.
- [x] Core performance profiling harness.
- [ ] Generated bridge sources validated and normalized for the final candidate.
- [ ] Native Rust library packaging/loading proven on each advertised native target.
- [ ] Android primary journey manually validated on a release build.
- [ ] Windows primary journey manually validated on a release build.
- [ ] Linux primary journey manually validated on a release build.
- [ ] macOS primary journey manually validated on a release build.
- [ ] Web primary journey manually validated with the deterministic fallback.
- [ ] iOS signed-device/App Store readiness validated where distribution is intended.
- [ ] Final launcher/splash assets installed in every committed platform shell.
- [ ] Large-text, screen-reader, contrast, and keyboard accessibility review completed on real targets.

## Phase 4 — Quality hardening

- [x] Flutter unit/controller/widget regression tests.
- [x] Primary offline conversion journey widget test.
- [x] Rust conversion regression/property-oriented tests.
- [x] Rust fuzz targets for catalog/decimal bridge inputs.
- [x] Core profiling workload for lookup/search/single/batch conversion.
- [x] Repository secret-pattern, JSON/ARB, and Markdown-link checks.
- [x] Repository utility regression tests, including duplicate JSON-key detection.
- [x] Backup corruption/version/migration regression coverage.
- [x] Strict backup unknown-field, stable-ID, collection-bound, and custom-unit normalization coverage.
- [x] Safe error-presentation regression coverage.
- [ ] Latest exact-candidate Rust fmt/clippy/tests green in CI.
- [ ] Latest exact-candidate Flutter gen-l10n/format/analyze/tests green in CI.
- [ ] Latest exact-candidate bridge generation/check green in CI.
- [ ] Latest exact-candidate CodeQL and dependency review green.
- [ ] Fuzzing campaign run for a documented time budget on the release candidate.
- [ ] Measured performance output recorded for release-candidate hardware/toolchain context.
- [ ] Regression fixes from all platform/manual testing completed.

## Phase 5 — Release engineering

- [x] Cross-platform GitHub Actions release workflow foundation.
- [x] Strict host-independent release-candidate verification script.
- [x] Versioning, migration, bridge, platform, and branding release guidance.
- [x] Changelog structure and release-note foundation.
- [ ] Real phone screenshot captured from validated build.
- [ ] Real desktop screenshot captured from validated build.
- [ ] Real dark-mode screenshot captured from validated build.
- [ ] Final launcher/splash raster exports generated from the vector source and wired into platform shells.
- [ ] Release artifacts produced from exact audited tag.
- [ ] Checksum manifest produced for downloadable artifacts.
- [ ] Signing/notarization/store credentials configured outside the repository where required.
- [ ] `0.1.0-alpha.1` release candidate approved after all required gates.

## Phase 6 — Final audit

- [ ] Clean-clone setup verification on documented toolchains.
- [ ] Full CI/security/dependency matrix passes for the exact release candidate.
- [ ] Strict `tool/verify_release_candidate.sh` passes without modifying tracked sources.
- [ ] Documentation-link/data/secret checks pass for the exact release candidate.
- [ ] Accessibility manual review evidence recorded.
- [ ] Native bridge packaging and installed-app evidence recorded.
- [ ] Release artifacts/checksums/screenshots match the audited commit.
- [ ] `what_changed.md` contains no stale completion claims or unresolved hidden blockers.
- [ ] Release-candidate verification completed and tagged.

## Post-1.0 ideas

- Optional currency conversion provider behind an explicit online-data boundary.
- Community unit packs with signed/validated metadata.
- Shareable deep links for conversion pairs where platforms allow it.
- Additional locales and localized educational content.
- Statistically rigorous long-running performance benchmark suite if profiling identifies regressions.
