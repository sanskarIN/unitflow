# Changelog

All notable changes to UnitFlow are documented here. The format is based on Keep a Changelog and the project intends to follow Semantic Versioning after the first stable release.

## [Unreleased]

No additional changes are queued beyond the `2.0.12` development snapshot documented below.

## [2.0.12] - 2026-08-19

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
- Shared Rust/Dart bridge-parity fixture coverage, including all supported rounding modes.
- Dependency-free Rust conversion micro-benchmark.
- CI, CodeQL, dependency-review, and verified source-release workflows.
- Generated-scaffold compatibility builds for Android, Web, Linux, Windows, macOS, and iOS; these remain preliminary evidence rather than reviewed native release verification.
- Dependabot update discovery for Cargo, Flutter/Dart, and GitHub Actions dependencies.
- Dependency-free Python validators for repository-local Markdown targets, release/version/schema/protocol consistency, tracked-file hygiene, exact release-tag/version matching, and exhaustive tracked-file documentation inventory parity.
- `docs/repository-inventory.md`, documenting every tracked first-party file and enforced against `git ls-files` in local verification, CI, and release packaging.
- Standard-library regression tests for the repository validators.
- Structured bug/feature issue templates, pull-request quality checklist, CODEOWNERS, funding metadata, and security/support issue routing.
- Cross-platform verification scripts for Bash and PowerShell.
- Documentation for architecture decisions, bridge contract, data schema, unit model, threat model, platform support, native platform completion, generated platform smoke builds, dependency maintenance, localization, keyboard shortcuts, testing, performance, releases, and GitHub maintenance.
- `.env.example` documenting that core UnitFlow features require no secrets or online configuration.

### Changed

- Rust workspace, Flutter package metadata, and About screen version are aligned at `2.0.12` (Flutter build number `12`).
- Rust minimum supported version is aligned at `1.82` with the standard-library APIs used by the core.
- Rust bridge rounding-mode serialization now uses the documented camelCase identifiers such as `nearestEven` and `halfAwayFromZero`.
- Rust bridge parity tests now deserialize the same versioned fixture consumed by Dart instead of maintaining a copied vector list.
- Main conversion and batch flows now use the persisted user-selected rounding strategy.
- App navigation expanded with dedicated Batch and History workspaces and desktop shortcuts.
- Custom-unit deletion now removes dangling favorites, pins, and history references.
- Rust and Dart custom-unit boundaries enforce a maximum of 32 aliases.
- Backup/custom-unit error surfaces now avoid displaying raw internal exception text.
- Production and in-memory state repositories now share the same bounded JSON decoder so tests cannot rely on weaker backup-import validation.
- Recent-history persistence now validates nonblank/bounded input plus existing same-category unit references while preserving locale-formatted original input text.
- Native bridge request/response DTO validation now enforces canonical decimal strings, stable unit-ID syntax, and supported precision before data crosses the future generated binding boundary.
- Plain decimal display grouping now follows locale decimal-pattern primary/secondary grouping sizes while preserving exact decimal strings.
- Normal Bash/PowerShell verification, CI, and release packaging now execute repository-integrity validators before language/toolchain checks.
- Flutter CI/release verification runs localization generation explicitly.
- Dart formatting uses an explicit repository-wide 120-column page width while retaining strict analyzer/lint rules.
- Rust release packaging no longer permits a dirty working tree.
- Release documentation and roadmap now distinguish generated scaffold compatibility from reviewed native project/build evidence.
- Security/threat documentation now covers persistence ordering, import atomicity, repository hygiene, release-tag validation, and native-platform trust boundaries.

### Fixed

- Corrected invalid Dart test fixture construction for long strings.
- Corrected dependency-review workflow permissions required for pull-request summaries.
- Fixed a Rust bridge-parity compile failure caused by referencing the removed/nonexistent `ConversionResult.value` field instead of `ConversionResult.output`.
- Normalized Rust notation/custom-unit tests and protected the intentionally dense catalog data table from accidental formatter churn.
- Hardened history symbol preview so it does not depend on an additional characters package.
- Ensured JSON batch export is represented correctly in copy feedback.
- Fixed a persistence race where a queued pre-reset save could repopulate local data after reset; reset now serializes behind pending writes, clears storage, and persists a clean baseline.
- Fixed local reset persistence failures being logged without a safe user-visible warning state.
- Fixed Settings showing a successful reset message after a failed storage clear.
- Fixed `recordRecent` accepting unknown or cross-category units and oversized/blank input.
- Fixed imported conversion history accepting whitespace-only input.
- Fixed in-memory backup imports bypassing the production 1,000,000-character payload and JSON-object/string-key boundary.
- Fixed locale display grouping being hard-coded to groups of three, which produced incorrect grouping for locales with a different secondary group size.
- Fixed the generated platform-smoke workflow/documentation mismatch by implementing the previously documented Linux, Windows, macOS, and iOS jobs in addition to Web and Android.

### Security

- Added responsible disclosure guidance and secret-handling rules.
- Added CodeQL analysis, pull-request dependency review, import size/schema validation, safe debug logging, and a project threat model.
- Repository hygiene now rejects nested tracked `.env` variants, common signing credentials, generated localization output, and build artifacts in addition to checking the complete critical project/documentation set.
- Tagged release packaging now rejects a `v*` tag unless it exactly equals `v` plus the Cargo workspace package version.
- Native bridge payload validation rejects malformed/non-canonical decimal text and invalid stable unit identifiers before accepting generated-binding data.
- Public issue intake instructs reporters to remove secrets and sensitive personal data.

## [0.1.0-alpha.1] - Historical planning baseline

The repository began with a planned first runnable development preview at `0.1.0-alpha.1`. That planning baseline was superseded by the requested `2.0.12` development version. Native release verification requirements remain evidence-based and are not implied by the version number alone.
