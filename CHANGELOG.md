# Changelog

All notable changes to UnitFlow are documented here. The format is based on Keep a Changelog and the project intends to follow Semantic Versioning after the first stable release.

## [Unreleased]

No changes are queued beyond the active `2.0.12` development snapshot documented below.

## [2.0.12] - 2026-08-20

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
- Versioned Rust bridge service source layer with canonical decimal-string DTOs, ordered batch conversion, stable protocol metadata, and safe failure-code mapping for future generated bindings.
- Source-level native startup negotiation metadata with stable bridge capabilities for single conversion, ordered batch conversion, and canonical decimal text.
- Flutter `NativeBridgeInfo` compatibility validation with fail-closed protocol/capability mismatch handling before future native engine selection.
- Shared 256-target native/fallback batch-conversion ceiling with Rust bridge input bounds, Flutter bridge DTO bounds, and deterministic Dart fallback enforcement.
- Rust bridge-service regression tests covering canonical payloads, error codes, protocol/capability metadata, bounded batches, unit-ID validation, batch ordering, and camelCase serialization.
- Flutter regression tests covering bridge metadata compatibility, malformed startup payloads, bounded batch requests, and fallback batch-limit parity.
- Persisted primary-journey regression coverage across controller restart, settings, favorites, pins, history, custom units, backup/import, conversion reuse, and reset.
- Dependency-free Rust conversion micro-benchmark.
- CI, CodeQL, dependency-review, and verified source-release workflows.
- Deterministic six-platform Flutter generation for Android, iOS, Web, Windows, Linux, and macOS through matching Bash/PowerShell bootstrap scripts.
- Automated all-or-nothing platform materialization workflow that stages intended generated projects, regenerates a machine-maintained platform-file inventory, validates repository state, and commits generated platform projects when execution is available.
- Release-mode cross-platform build jobs for Android, iOS, Web, Windows, Linux, and macOS with uploaded build artifacts; iOS release compilation deliberately uses `--no-codesign` so signing secrets remain outside source control.
- `scripts/check_platform_support.py`, enforcing the six-target build/generation contract, rejecting partial committed platform sets, and guarding shared Flutter libraries from unconditional `dart:io` imports that would break Web.
- `docs/platform-file-inventory.md` plus `scripts/update_platform_inventory.py` so generated platform trees can remain exhaustively inventoried without hand-maintaining hundreds of repetitive entries.
- Dependabot update discovery for Cargo, Flutter/Dart, and GitHub Actions dependencies.
- Dependency-free Python validators for repository-local Markdown targets, release/version/schema/protocol consistency, tracked-file hygiene, exact release-tag/version matching, exhaustive tracked-file documentation inventory parity, and cross-platform support.
- `docs/repository-inventory.md`, documenting first-party repository files and combined with the generated platform inventory for exact `git ls-files` enforcement.
- Standard-library regression tests for the repository validators, including six-platform support, generated-inventory behavior, bridge protocol/capability parity, and shared batch bounds.
- Structured bug/feature issue templates, pull-request quality checklist, CODEOWNERS, funding metadata, and security/support issue routing.
- Cross-platform verification scripts for Bash and PowerShell.
- Documentation for architecture decisions, bridge contract, data schema, unit model, threat model, platform support, native platform completion, generated platform builds, dependency maintenance, localization, keyboard shortcuts, testing, performance, releases, and GitHub maintenance.
- `.env.example` documenting that core UnitFlow features require no secrets or online configuration.

### Changed

- Rust workspace, Flutter package metadata, and About screen version are aligned at `2.0.12` (Flutter build number `12`).
- Rust minimum supported version is aligned at `1.82` with the standard-library APIs used by the core.
- Rust bridge rounding-mode serialization now uses the documented camelCase identifiers such as `nearestEven` and `halfAwayFromZero`.
- Rust bridge parity tests now deserialize the same versioned fixture consumed by Dart instead of maintaining a copied vector list.
- Bridge documentation now distinguishes the implemented source-level protocol/capability negotiation contract from still-pending generated native bindings, runtime engine selection, and per-platform packaging.
- Repository release-consistency validation now locks the bridge protocol number, required capability set, and 256-target batch ceiling across Rust source, Flutter bridge source, deterministic fallback source, fixtures, and documentation.
- Deterministic Dart batch conversion now bounds iterable consumption to one item beyond the documented limit before rejecting oversized work, preventing an unbounded iterable from being fully materialized.
- Main conversion and batch flows now use the persisted user-selected rounding strategy.
- App navigation expanded with dedicated Batch and History workspaces and desktop shortcuts.
- Custom-unit deletion now removes dangling favorites, pins, and history references.
- Rust and Dart custom-unit boundaries enforce a maximum of 32 aliases.
- Backup/custom-unit error surfaces now avoid displaying raw internal exception text.
- Production and in-memory state repositories now share the same bounded JSON decoder so tests cannot rely on weaker backup-import validation.
- Recent-history persistence now validates nonblank/bounded input plus existing same-category unit references while preserving locale-formatted original input text.
- Native bridge request/response DTO validation now enforces canonical decimal strings, stable unit-ID syntax, supported precision, startup metadata bounds, and batch target limits before data crosses the future generated binding boundary.
- Plain decimal display grouping now follows locale decimal-pattern primary/secondary grouping sizes while preserving exact decimal strings.
- The historical generated-platform smoke workflow is now a committed-first six-platform **release build matrix** with generation fallback and artifact upload instead of debug-only compatibility checks.
- Normal Bash/PowerShell verification, CI, platform materialization, and release packaging now execute the cross-platform support validator in addition to repository-integrity validators.
- Repository hygiene treats the platform materializer, generated platform inventory, and platform-support validator as required project infrastructure.
- Flutter CI/release verification runs localization generation explicitly.
- Dart formatting uses an explicit repository-wide 120-column page width while retaining strict analyzer/lint rules.
- Rust release packaging no longer permits a dirty working tree.
- Platform-support documentation now distinguishes release-mode compilation from production signing, notarization, installer creation, and store submission.
- Security/threat documentation covers persistence ordering, import atomicity, repository hygiene, release-tag validation, and native-platform trust boundaries.

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
- Fixed the earlier platform-workflow/documentation mismatch by making all six targets first-class release-build jobs and by enforcing that the generation/build matrix cannot silently lose a target.
- Fixed the source-level batch capability mismatch where Flutter required `batchConvert` during negotiation without exposing a corresponding bridge batch method.
- Fixed native-versus-fallback batch behavior divergence by applying the same documented target ceiling to both paths.

### Security

- Added responsible disclosure guidance and secret-handling rules.
- Added CodeQL analysis, pull-request dependency review, import size/schema validation, safe debug logging, and a project threat model.
- Repository hygiene rejects nested tracked `.env` variants, common signing credentials, generated localization output, and build artifacts in addition to checking the complete critical project/documentation set.
- Tagged release packaging rejects a `v*` tag unless it exactly equals `v` plus the Cargo workspace package version.
- Native bridge payload validation rejects malformed/non-canonical decimal text and invalid stable unit identifiers before accepting generated-binding data.
- Native startup negotiation fails closed on unsupported protocol versions and missing required capabilities instead of silently selecting an incompatible backend.
- Native bridge batch requests are resource-bounded before conversion work, and oversized requests return a stable safe `invalid_batch` failure.
- Rust bridge failures expose stable safe codes/messages rather than raw domain internals or untrusted unit identifiers.
- Platform release workflows deliberately avoid committing or embedding production signing credentials; Android production keystores and Apple signing/provisioning/notarization remain secure release-infrastructure inputs.
- Public issue intake instructs reporters to remove secrets and sensitive personal data.

## [0.1.0-alpha.1] - Historical planning baseline

The repository began with a planned first runnable development preview at `0.1.0-alpha.1`. That planning baseline was superseded by the requested `2.0.12` development version. Native release verification requirements remain evidence-based and are not implied by the version number alone.
