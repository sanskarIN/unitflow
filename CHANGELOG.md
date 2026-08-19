# Changelog

All notable changes to UnitFlow are documented here. The format is based on Keep a Changelog and the project intends to follow Semantic Versioning after the first stable release.

## [Unreleased]

### Added

- Initial repository documentation and governance.
- Rust + Flutter architecture baseline.
- Offline-first privacy and security policies.
- High-precision Rust conversion core and deterministic Dart exact-decimal fallback.
- Searchable multi-category unit catalog, favorites, pinned pairs, recents, custom units, and batch conversion export.
- Local JSON backup/restore with clipboard and bounded file import/export flows.
- Explicit user-selectable decimal rounding modes: nearest-even, half-away-from-zero, toward zero, away from zero, floor, and ceiling.
- English localization source and generated-localization workflow.
- Rust–Flutter bridge crate and bridge-generation automation.
- CI, CodeQL, dependency review, Dependabot, and cross-platform release workflows.

### Changed

- Backup schema advanced from version 1 to version 2 to persist the selected decimal rounding mode.
- Valid version 1 backups migrate deterministically to nearest-even rounding and export as version 2.

### Fixed

- Conversion rounding is now applied consistently to primary and batch conversion paths using the persisted user preference.

### Security

- Added responsible disclosure guidance and secret-handling rules.
- Added bounded backup import validation and redacting structured diagnostic logging.

## [0.1.0-alpha.1] - Planned

Initial runnable development preview containing the Rust conversion engine, Flutter converter experience, local preferences/custom units, automated tests, and CI/release foundations.
