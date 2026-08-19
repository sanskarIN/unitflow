# Changelog

All notable changes to UnitFlow are documented here. The format is based on Keep a Changelog and the project intends to follow Semantic Versioning after the first stable release.

## [Unreleased]

### Added

- Rust `unitflow_core` domain crate with validated categories/units, exact decimal conversion, explicit rounding modes, catalog search, custom units, notation formatting, and educational category metadata.
- Broad built-in unit catalog covering length, area, volume, mass, speed, pressure, energy, power, angle, data size, frequency, time, and temperature.
- Flutter application shell with adaptive Convert, Batch, Library, History, and Settings destinations.
- Deterministic pure-Dart exact-decimal compatibility engine for Flutter/Web development and parity work.
- Favorites, pinned pairs, recent conversions, custom units, onboarding, local settings, and versioned backup/import state.
- Schema-version-2 persistence with migration from version 1 and explicit persisted rounding mode.
- Batch table export as CSV, TSV, and JSON using canonical decimal strings.
- Local conversion history with restore and clear actions.
- Localized presentation architecture using Flutter generated ARB resources, including converter education, navigation, batch, history, library, settings, onboarding, custom-unit, and About surfaces.
- User-initiated GitHub Releases access without automatic update checks.
- Structured debug logging with sensitive-key redaction and bounded metadata.
- Rust catalog/conversion invariant tests, Flutter persistence/export/navigation tests, and deterministic exact-decimal property checks.
- Dependency-free Rust conversion micro-benchmark.
- CI, CodeQL, dependency-review, and verified source-release workflows.
- Structured bug/feature issue templates, pull-request quality checklist, CODEOWNERS, funding metadata, and security/support issue routing.
- Cross-platform verification scripts for Bash and PowerShell.
- Documentation for architecture decisions, bridge contract, data schema, unit model, threat model, platform support, native platform completion, localization, keyboard shortcuts, testing, performance, releases, and GitHub maintenance.
- `.env.example` documenting that core UnitFlow features require no secrets or online configuration.

### Changed

- Flutter package version aligned with the Rust workspace at `0.1.0-alpha.1`.
- Main conversion and batch flows now use the persisted user-selected rounding strategy.
- App navigation expanded with dedicated Batch and History workspaces and desktop shortcuts.
- Custom-unit deletion now removes dangling favorites, pins, and history references.
- Backup/custom-unit error surfaces now avoid displaying raw internal exception text.
- Flutter CI/release verification now runs localization generation explicitly.

### Fixed

- Corrected invalid Dart test fixture construction for long strings.
- Corrected dependency-review workflow permissions required for pull-request summaries.
- Hardened history symbol preview so it does not depend on an additional characters package.
- Ensured JSON batch export is represented correctly in copy feedback.

### Security

- Added responsible disclosure guidance and secret-handling rules.
- Added CodeQL analysis, pull-request dependency review, import size/schema validation, safe debug logging, and a project threat model.
- Public issue intake instructs reporters to remove secrets and sensitive personal data.

## [0.1.0-alpha.1] - Planned

Planned first runnable development preview. It is not considered release-ready until clean-clone verification, the native Flutter platform projects, Rust↔Flutter bridge integration, required platform builds, and release-candidate checks are completed.
