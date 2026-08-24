# UnitFlow Roadmap

The roadmap is milestone-oriented. Items are checked only when repository evidence supports them; portable source code or generated temporary scaffolding alone does not count as a verified native platform release.

## Phase 0 — Repository foundation

- [x] Repository identity and README.
- [x] License, support, privacy, security, conduct, and contribution policies.
- [x] Architecture/setup/testing/release documentation.
- [x] GitHub issue/PR templates and code ownership.
- [x] CI, CodeQL, funding metadata, and dependency-review workflow.
- [x] Automated Dependabot configuration for Cargo, Flutter/Dart, and GitHub Actions.
- [x] Repository-local Markdown, release-consistency, hygiene, release-tag, inventory, six-platform support, accessibility, and conversion-session source validators with regression tests.

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

- [x] Versioned Rust source bridge service/DTO layer matching bridge protocol v1.
- [x] Source-level Rust/Flutter startup protocol + capability negotiation contract with fail-closed compatibility checks.
- [x] Source-level bounded native batch bridge contract with a shared 256-target limit and stable unit-ID validation.
- [x] Source-level one-shot native loader/session-selection seam with immutable backend choice, adapter-error containment, response validation, and no mid-session fallback.
- [x] Source-level stale asynchronous conversion result suppression gate.
- [x] Generator-agnostic app-facing adapter boundary implementing `NativeConversionBridge`/catalog synchronization over a future generated API.
- [ ] Generate the concrete Rust↔Flutter FFI/binding implementation behind `GeneratedNativeBridgeApi`.
- [ ] Implement real platform native-library loading/packaging and connect it to `ConversionSession.bootstrap()`.
- [x] Migrate Converter and Batch presentation/controller flows to the selected asynchronous `ConversionSession` while preserving immediate deterministic Dart previews.
- [x] Define and implement bounded atomic native custom-unit/catalog snapshot synchronization so Rust and Flutter cannot diverge after user catalog changes.
- [x] App-owned session refresh invalidates stale catalog sessions and suppresses late asynchronous refresh results.
- [x] App-controller initialization/disposal lifecycle suppresses late native-loader completions and coalesces concurrent initialization.
- [x] Six-target Flutter generation contract for Android, iOS, Web, Windows, Linux, and macOS.
- [x] Automated all-or-nothing platform materialization workflow with generated-file inventory support.
- [x] Committed-first six-platform release build matrix with uploaded build artifacts and generation fallback.
- [x] Repository validator that prevents platform-matrix drift, partial platform commits, and unconditional shared `dart:io` imports.
- [ ] Commit reviewed Android native Flutter project and validate a release build from the committed project.
- [ ] Commit reviewed Windows native Flutter project and validate a release build from the committed project.
- [ ] Commit reviewed Linux native Flutter project and validate a release build from the committed project.
- [ ] Commit reviewed macOS native Flutter project and validate a release build from the committed project.
- [ ] Commit reviewed Web project and validate a production Web build from the committed project.
- [ ] Commit iOS-ready native project and validate with macOS/Xcode tooling from the committed project.
- [x] Keyboard shortcuts and adaptive desktop navigation.
- [x] Source-level reduced-motion policy, converter/batch semantic-state safeguards, and representative compact 200% large-text widget smoke coverage.
- [ ] Reduced-motion, large-text, high-contrast, and screen-reader manual review on real release-candidate platforms.
- [ ] Native performance profiling and large-catalog virtualization review where measured data requires it.

## Phase 4 — Quality hardening

- [x] Core Flutter unit/widget smoke tests for converter-adjacent state, navigation, backup, batch export, safe logging, and accessibility behavior.
- [x] Persistence race/reference/import-bound regression tests for identified state defects.
- [x] Controller/repository persisted-journey coverage across restart, settings, favorites, pins, history, custom units, backup/import, conversion reuse, and reset.
- [x] Repository validation locks bridge protocol, required capabilities, native batch bounds, and native custom-unit snapshot bounds across docs/Rust/Flutter.
- [x] Repository validation locks one-shot native loading, sticky backend selection, adapter-error containment, response validation/identity/order, no runtime fallback, stale async result suppression, controller integration, and verification wiring.
- [x] Repository validation locks reduced-motion, converter/batch semantic context, and representative large-text accessibility smoke coverage.
- [x] Generated-adapter boundary tests cover startup metadata caching, request forwarding, catalog forwarding, response parsing, and malformed generated payload rejection.
- [ ] Generated-boundary Rust↔Dart parity tests through the concrete production FFI implementation, including startup failures and stale async completion behavior.
- [ ] Full integration tests for persisted primary UI journeys.
- [ ] Native end-to-end primary journeys.
- [x] Deterministic property-style tests for exact-decimal behavior plus catalog-wide Rust invariants.
- [ ] Long-running Rust/Dart fuzz targets for parsers and conversion invariants.
- [x] Developer conversion micro-benchmark.
- [ ] Catalog-search and batch-conversion benchmark baselines on documented hardware.
- [x] CodeQL/dependency-review/security design hardening in source control.
- [x] Normal CI and release workflows enforce repository-integrity and six-platform contract validation before language/package gates.
- [ ] Resolve every issue surfaced by actual clean CI/platform execution.

## Phase 5 — Release engineering

- [ ] Real screenshots and demo media from verified builds.
- [ ] Final app icon/splash source artwork and generated platform assets.
- [x] Reproducible source verification/release workflow with SHA-256 checksums.
- [x] Release workflow rejects a `v*` tag that does not exactly match the Cargo workspace version.
- [ ] Native platform packaging guidance and binary artifacts validated per platform.
- [x] Release checklist, changelog, data-migration notes, and platform-support documentation baseline.
- [ ] Tag and verify `2.18.12` only after the blocking items below pass.

## Phase 6 — Final audit

- [ ] Clean-clone setup verification with required Python/Rust/Flutter/native toolchains installed.
- [ ] Full CI/check matrix passes on the release commit.
- [ ] Six-platform release-build matrix passes on the final committed platform projects.
- [ ] Documentation-link audit result reviewed on the release commit (automated checker is implemented and wired to CI).
- [ ] Accessibility manual review.
- [ ] Secret scan and dependency/security findings reviewed.
- [ ] Release-candidate verification on every platform claimed as supported.

## Current `2.18.12` release blockers

1. The repository has deterministic six-platform generation, materialization automation, release-build jobs, artifact upload, and cross-platform contract validation. However, the generated Android/iOS/Web/Windows/Linux/macOS directories are still absent from the currently inspected `main` tree, so committed-project build evidence is required before native projects can be called release-verified.
2. The source-level app now owns a sticky `ConversionSession`, routes Converter/Batch through it, synchronizes custom-unit snapshots, suppresses stale async results, and exposes a generator-agnostic `GeneratedNativeConversionBridge`. The concrete generated Rust↔Flutter API implementation, real native library loader, native packaging, and generated-boundary parity execution remain incomplete.
3. The current execution environment does not provide the Rust/Flutter/Dart/native toolchains needed to compile all current repository changes locally. No local full verification result is claimed for this checkpoint.
4. A successful full GitHub Actions and six-platform release-build matrix for the final candidate commit has not yet been established and reviewed.
5. Automated source/widget accessibility safeguards cover reduced motion, converter pin state, converter and batch selector semantic context, and representative compact 200% text-scaling smoke checks. Real-platform large-text rendering, contrast, screen-reader behavior, keyboard/focus traversal, touch targets, and modal focus/dismissal still require manual release-candidate review.
6. Real release media/assets, production signing/notarization, and store-ready distributable artifacts remain intentionally deferred until verified native builds exist.

## Next patch target — `2.18.13`

`2.18.13` is the next hardening target after `2.18.12` is verified/tagged. Do not bump package metadata early; the active source version stays `2.18.12` until its release evidence is complete.

Planned `2.18.13` scope:

- Complete or harden the concrete generated native binding/API implementation once the binding toolchain is selected and executable.
- Add platform-native loader implementations with explicit Web fallback behavior and no silent runtime backend switching.
- Add generated-boundary parity tests for single conversion, batch conversion, custom units, malformed payloads, startup negotiation, and rounding modes.
- Add controller/session lifecycle stress tests for disposal, overlapping catalog refreshes, and persistence/native-loader races.
- Review and fix every issue surfaced by clean GitHub Actions and the six-platform release matrix.
- Improve release diagnostics so backend selection/fallback reasons can be inspected safely without exposing raw native errors.
- Continue accessibility, performance, packaging, and release-documentation hardening based on real platform evidence.

## Post-1.0 ideas

- Optional currency conversion provider behind an explicit online-data boundary.
- Community unit packs with signed/validated metadata.
- Shareable deep links for conversion pairs where platforms allow it.
- Additional reviewed locales and expanded educational content.
