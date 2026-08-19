# Changelog

All notable changes to UnitFlow are documented here. The format is based on Keep a Changelog and the project intends to follow Semantic Versioning after the first stable release.

## [Unreleased]

### Added

- Initial repository documentation, governance, support, privacy, security, and contribution policies.
- Rust + Flutter architecture with authoritative `unitflow_core`, FRB bridge crate, and deterministic Dart exact-decimal fallback.
- Searchable multi-category unit catalog, favorites, pinned pairs, recent conversions, custom affine units, and batch conversion/CSV workflows.
- Local JSON backup/restore with clipboard and bounded file import/export flows.
- Explicit user-selectable decimal rounding modes: nearest-even, half-away-from-zero, toward zero, away from zero, floor, and ceiling.
- Reduced-motion accessibility preference with platform animation-preference handling during onboarding.
- English localization source and generated-localization workflow.
- User-initiated official Releases link without background update tracking.
- Reusable UnitFlow in-app brand mark and editable `assets/branding/unitflow-mark.svg` source.
- Undoable history clearing and full custom-unit restoration including related favorite, pin, and recent-history state.
- Rust–Flutter bridge crate, API DTOs, bridge-generation automation, and reproducible Cargokit native integration scaffolding for Android, iOS, Linux, macOS, and Windows.
- CI, CodeQL, dependency review, Dependabot, and cross-platform release workflow foundations.
- Repository safety checks for tracked-file patterns, JSON/ARB syntax, internal Markdown links, and developer utility syntax.
- User-safe error-presentation helper backed by redacting structured diagnostics.
- Core lookup/search/conversion profiling harness and strict release-candidate verification script.
- Widget/controller regression coverage plus a primary offline conversion journey test.
- Rust fuzz targets for catalog search and decimal bridge inputs.
- Bridge, platform-support, branding, accessibility, performance, data-format, and release verification documentation.

### Changed

- Backup schema advanced from version 1 to version 2 to persist the selected decimal rounding mode.
- Valid version 1 backups migrate deterministically to nearest-even rounding and export as version 2.
- Early version 2 backups remain compatible when the later optional `reduceMotion` preference is absent; it defaults to `false`.
- Primary library/custom-unit/settings interface strings increasingly use generated localization resources instead of embedded labels.
- Catalog matching now includes unit descriptions in the deterministic Dart catalog search path.
- Developer verification now checks repository safety/data/docs before Rust and Flutter quality gates.
- Audit-branch normalization bootstraps platform shells, regenerates native bridge scaffolding/localizations/bindings, and uses `sanskarin@outlook.in` for its automated normalization commit identity.
- Loaded/imported convenience state is normalized against the rebuilt catalog so stale favorites, pins, and recent-history references cannot survive catalog/custom-unit changes.
- Local persistence writes are serialized and handled as user-visible non-fatal warnings if the storage backend fails.

### Fixed

- Conversion rounding is applied consistently to primary and batch conversion paths using the persisted user preference.
- Backup/custom-unit failures no longer echo raw internal exception text into the user interface.
- History can be cleared without making the action immediately irreversible because the UI provides an undo snapshot.
- Removing a custom unit now removes dependent favorite, pinned-pair, and recent-history references instead of leaving inaccessible local state.
- Undoing custom-unit removal restores the definition together with its captured favorite, pin, and history relationships when the stable ID is still available.
- Invalid/stale unit references are pruned after load/import while valid custom-unit definitions remain strict validation failures rather than being silently discarded.
- Local save/clear failures no longer escape unawaited UI callbacks; session state is preserved and users receive a recovery-oriented warning.

### Security

- Added responsible disclosure guidance and safe configuration rules.
- Added bounded backup import validation and redacting structured diagnostic logging.
- Added tracked-file safety scanning as a dependency-free CI check.
- Added safe failure presentation that records only exception type metadata rather than potentially sensitive exception text.
- Referential-normalization diagnostics record aggregate removal counts only, not conversion values or user backup content.

## [0.1.0-alpha.1] - Planned

Initial runnable development preview containing the Rust conversion engine, adaptive Flutter converter/library/history/settings experience, local data/custom units, explicit precision/rounding, accessibility foundations, bridge/release automation, tests, and repository hardening.

This version remains planned until the exact candidate passes automated quality/security checks plus the required native/web build and manual release validation described in `docs/release.md`.
