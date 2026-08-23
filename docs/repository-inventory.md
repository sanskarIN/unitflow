# Repository inventory

This inventory documents every tracked first-party file in UnitFlow and its role. It is intentionally exhaustive: when a tracked file is added, moved, or removed, update this document in the same change. `scripts/check_repository_inventory.py` compares the machine-readable path list below with `git ls-files` so the inventory cannot silently drift.

## Root configuration and project policy

- `.editorconfig` — cross-editor whitespace, indentation, and newline defaults.
- `.env.example` — documents the offline/default environment boundary without storing secrets.
- `.gitattributes` — repository text/binary and line-ending attributes.
- `.gitignore` — excludes local environments, generated output, build products, signing material, and IDE state.
- `Cargo.toml` — Rust workspace membership plus shared `2.0.12` package metadata and Rust `1.82` minimum.
- `rust-toolchain.toml` — Rust toolchain/channel and component expectations.
- `README.md` — public project overview, current `2.0.12` source status, quick start, architecture, quality, and support entry point.
- `ROADMAP.md` — evidence-based milestone status and current `2.0.12` release blockers.
- `CHANGELOG.md` — user/maintainer-visible change history including the `2.0.12` development snapshot.
- `what_changed.md` — current continuation handoff and exact development checkpoint.
- `LICENSE` — MIT license text.
- `CONTRIBUTING.md` — contribution workflow and quality expectations.
- `CODE_OF_CONDUCT.md` — community participation standards.
- `SECURITY.md` — vulnerability reporting and security-handling guidance.
- `PRIVACY.md` — local-first data/privacy behavior.
- `SUPPORT.md` — supported help/reporting channels.

## GitHub governance and automation

- `.github/CODEOWNERS` — ownership/review hints for sensitive repository areas.
- `.github/FUNDING.yml` — GitHub funding metadata.
- `.github/dependabot.yml` — scheduled Cargo, Flutter/Dart, and GitHub Actions dependency update discovery.
- `.github/pull_request_template.md` — pull-request verification/documentation checklist.
- `.github/ISSUE_TEMPLATE/bug_report.yml` — structured defect report form.
- `.github/ISSUE_TEMPLATE/feature_request.yml` — structured enhancement request form.
- `.github/ISSUE_TEMPLATE/config.yml` — issue-template routing and contact configuration.
- `.github/workflows/ci.yml` — repository-integrity, Rust, and Flutter source quality gates.
- `.github/workflows/codeql.yml` — CodeQL static security analysis.
- `.github/workflows/dependency-review.yml` — pull-request dependency risk review.
- `.github/workflows/materialize-platforms.yml` — all-or-nothing generation, validation, inventory refresh, commit, and release-build dispatch for the six Flutter platform projects.
- `.github/workflows/platform-smoke.yml` — committed-first release-mode Android/iOS/Web/Windows/Linux/macOS build matrix with generation fallback and artifact upload.
- `.github/workflows/release.yml` — source verification, exact tag guard, clean Rust packaging, checksums, and GitHub release creation.

## Flutter application configuration

- `apps/unitflow_app/analysis_options.yaml` — Dart/Flutter analyzer/lint configuration plus repository-wide formatter width.
- `apps/unitflow_app/pubspec.yaml` — Flutter application package metadata, `2.0.12+12` version, and dependencies.
- `apps/unitflow_app/l10n.yaml` — Flutter localization generation configuration.
- `apps/unitflow_app/lib/l10n/app_en.arb` — English source localization resource catalog.

## Flutter application shell

- `apps/unitflow_app/lib/main.dart` — application process entry point and initial repository/controller wiring.
- `apps/unitflow_app/lib/app/unitflow_app.dart` — top-level Material application, theme, localization, and onboarding/shell routing.
- `apps/unitflow_app/lib/app/app_controller.dart` — application state, serialized persistence, custom-unit lifecycle, favorites/pins/history, import/reset behavior, and safe reset-failure warning state.
- `apps/unitflow_app/lib/app/app_shell.dart` — adaptive main navigation, destination coordination, and warning banner presentation.
- `apps/unitflow_app/lib/app/theme/app_theme.dart` — centralized light/dark theme definitions, design tokens, and reduced-motion policy.

## Flutter core services

- `apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart` — native-conversion bridge contract plus canonical decimal/unit-ID/precision validation boundary and structurally revalidated startup metadata.
- `apps/unitflow_app/lib/core/format/decimal_format.dart` — locale-aware exact-decimal input parsing and locale-pattern-aware presentation grouping/formatting.
- `apps/unitflow_app/lib/core/logging/app_log.dart` — bounded structured diagnostic logging with sensitive-key redaction.
- `apps/unitflow_app/lib/core/math/exact_decimal.dart` — deterministic exact base-10 decimal value, parsing, arithmetic, comparison, and rounding logic.
- `apps/unitflow_app/lib/core/persistence/user_state.dart` — versioned persisted state model, migration, item validation, and import ceilings.
- `apps/unitflow_app/lib/core/persistence/user_state_repository.dart` — production/in-memory persistence adapters and shared bounded backup decoder.

## Flutter conversion feature

- `apps/unitflow_app/lib/features/converter/data/unit_catalog.dart` — deterministic Dart compatibility catalog used until native bridge authority is complete.
- `apps/unitflow_app/lib/features/converter/domain/unit_models.dart` — Dart category/unit/pin/conversion domain models.
- `apps/unitflow_app/lib/features/converter/domain/conversion_engine.dart` — exact Dart compatibility conversion/search/batch engine.
- `apps/unitflow_app/lib/features/converter/domain/conversion_session.dart` — sticky Rust-versus-Dart conversion-session router with one-shot native loading, fail-closed startup negotiation, adapter-error containment, and native response validation.
- `apps/unitflow_app/lib/features/converter/domain/latest_conversion_request.dart` — generation-token gate that suppresses stale asynchronous conversion success/failure publication and invalidates pending work on lifecycle changes.
- `apps/unitflow_app/lib/features/converter/domain/batch_export.dart` — CSV/TSV/JSON batch serialization and escaping.
- `apps/unitflow_app/lib/features/converter/presentation/category_localizations.dart` — localized category labels/descriptions/examples mapping.
- `apps/unitflow_app/lib/features/converter/presentation/converter_controller.dart` — converter interaction state, locale parsing, selection, batch/history coordination.
- `apps/unitflow_app/lib/features/converter/presentation/converter_screen.dart` — primary single-conversion user interface and semantic result/control handling.
- `apps/unitflow_app/lib/features/converter/presentation/batch_screen.dart` — multi-target batch conversion/export interface.

## Flutter supporting features

- `apps/unitflow_app/lib/features/history/presentation/history_screen.dart` — local conversion history list, restore, clear interface, and reduced-motion confirmation dialog.
- `apps/unitflow_app/lib/features/library/presentation/library_screen.dart` — searchable unit library, favorites, pins, and custom-unit management surface.
- `apps/unitflow_app/lib/features/library/presentation/custom_unit_dialog.dart` — validated custom affine-unit editor with reduced-motion dialog presentation.
- `apps/unitflow_app/lib/features/onboarding/presentation/onboarding_screen.dart` — first-run offline/privacy/product onboarding.
- `apps/unitflow_app/lib/features/settings/presentation/settings_screen.dart` — theme, notation, rounding, backup/reset, safe reset-failure handling, reduced-motion reset dialog, and related settings UI.
- `apps/unitflow_app/lib/features/settings/presentation/about_screen.dart` — `2.0.12` version, project links, license/support, and project-credit UI.

## Flutter tests

- `apps/unitflow_app/test/accessibility_smoke_test.dart` — reduced-motion policy and converter semantic-state regression coverage.
- `apps/unitflow_app/test/app_controller_reference_validation_test.dart` — imported favorite/pin/recent reference and category validation.
- `apps/unitflow_app/test/app_controller_test.dart` — collection cleanup and custom-unit reference lifecycle behavior.
- `apps/unitflow_app/test/backup_atomicity_test.dart` — rejected-import atomicity and duplicate custom-ID protection.
- `apps/unitflow_app/test/batch_export_test.dart` — CSV/TSV/JSON escaping and export behavior.
- `apps/unitflow_app/test/bridge_parity_vectors_test.dart` — Dart execution of shared Rust↔Dart parity fixture vectors.
- `apps/unitflow_app/test/converter_controller_test.dart` — default conversion, swap, validation, category, and batch-controller behavior.
- `apps/unitflow_app/test/custom_unit_integration_test.dart` — custom-unit creation/use/persistence integration behavior.
- `apps/unitflow_app/test/localization_smoke_test.dart` — generated localization availability/smoke behavior.
- `apps/unitflow_app/test/navigation_smoke_test.dart` — adaptive shell destination reachability.
- `apps/unitflow_app/test/persisted_primary_journey_test.dart` — controller/repository restart, backup/import, custom-unit, settings, and reset persistence journey coverage.
- `apps/unitflow_app/test/recent_validation_test.dart` — recent-history unit/category/input bounds and locale-text preservation.
- `apps/unitflow_app/test/reset_persistence_test.dart` — local reset persistence, queued-write ordering, and safe reset-failure warning regression coverage.
- `apps/unitflow_app/test/core/app_log_test.dart` — structured log redaction behavior.
- `apps/unitflow_app/test/core/conversion_session_error_boundary_test.dart` — startup, single-conversion, and batch-conversion adapter `Error` containment regression coverage.
- `apps/unitflow_app/test/core/conversion_session_test.dart` — sticky backend selection, one-shot loading, exact request forwarding, no mid-session fallback, native response classification/identity, batch ordering, and shared batch-limit coverage.
- `apps/unitflow_app/test/core/latest_conversion_request_test.dart` — deterministic stale-success/stale-failure suppression, callback-boundary, invalidation, disposal, and generation-token coverage.
- `apps/unitflow_app/test/core/exact_decimal_properties_test.dart` — deterministic generated/property-style exact-decimal invariants.
- `apps/unitflow_app/test/core/exact_decimal_test.dart` — exact-decimal parser/arithmetic/rounding plus locale-specific grouping/parsing examples and edge cases.
- `apps/unitflow_app/test/core/native_conversion_bridge_test.dart` — canonical bridge request/response boundary validation, deterministic startup metadata serialization, and safe failure behavior.
- `apps/unitflow_app/test/core/user_state_reference_bounds_test.dart` — persisted identifier/history boundary validation.
- `apps/unitflow_app/test/core/user_state_test.dart` — state schema migration, round-trip, import ceilings, and custom-unit validation.
- `apps/unitflow_app/test/features/conversion_engine_test.dart` — Dart compatibility conversion engine correctness.

## Rust core crate

- `crates/unitflow_core/Cargo.toml` — Rust core crate metadata and dependencies inherited from the workspace.
- `crates/unitflow_core/src/lib.rs` — public module/re-export surface for the core crate.
- `crates/unitflow_core/src/bridge.rs` — versioned generator-friendly Rust bridge service, canonical decimal-string DTOs, batch conversion, protocol metadata, and stable safe error mapping.
- `crates/unitflow_core/src/model.rs` — validated Rust category/unit definitions, stable domain models, and bounded alias normalization.
- `crates/unitflow_core/src/catalog.rs` — built-in unit catalog, lookup, category filtering, and search behavior.
- `crates/unitflow_core/src/converter.rs` — checked exact-decimal single/batch conversion, explicit rounding strategies, and camelCase bridge serialization identifiers.
- `crates/unitflow_core/src/custom_unit.rs` — custom affine-unit construction/validation helpers.
- `crates/unitflow_core/src/notation.rs` — plain/scientific/engineering notation formatting.
- `crates/unitflow_core/src/education.rs` — offline educational category metadata.
- `crates/unitflow_core/src/error.rs` — typed public domain/conversion errors including custom-alias count bounds.
- `crates/unitflow_core/examples/benchmark.rs` — dependency-free conversion micro-benchmark entry point.

## Rust tests

- `crates/unitflow_core/tests/catalog.rs` — catalog contents, lookup, aliases, and search ranking coverage.
- `crates/unitflow_core/tests/conversion.rs` — multiplicative/affine conversion, rounding, batch, error, and bridge-rounding serialization regression tests.
- `crates/unitflow_core/tests/custom_units.rs` — custom-unit validation/conversion and alias-ceiling tests.
- `crates/unitflow_core/tests/education.rs` — educational metadata integrity checks.
- `crates/unitflow_core/tests/invariants.rs` — catalog-wide identity/round-trip/domain invariants.
- `crates/unitflow_core/tests/notation.rs` — notation-formatting behavior.
- `crates/unitflow_core/tests/bridge_parity.rs` — Rust deserialization/execution of the shared Rust↔Dart parity fixture.
- `crates/unitflow_core/tests/bridge_service.rs` — Rust bridge protocol metadata, canonical DTO, stable failure-code, batch ordering, and serde contract tests.

## Shared fixtures

- `fixtures/bridge_parity_v1.json` — versioned exact-decimal conversion and all-rounding-mode vectors shared directly by Rust and Dart parity tests.

## Documentation index and engineering guides

- `docs/README.md` — documentation navigation/index and repository validation entry point.
- `docs/architecture.md` — component ownership, data flow, and architectural boundaries.
- `docs/unit-model.md` — unit/category/base-unit/stable-ID and affine-conversion model.
- `docs/bridge.md` — Rust↔Flutter integration direction and authority boundary.
- `docs/bridge-protocol.md` — versioned decimal-string bridge contract and parity rules.
- `docs/data-format.md` — local backup schema, migration, import bounds, and reset semantics.
- `docs/setup.md` — Git/Python/Rust 1.82+/Flutter/native setup and troubleshooting prerequisites.
- `docs/development.md` — contributor implementation conventions and verification workflow.
- `docs/testing.md` — repository, Rust, Flutter, bridge parity, accessibility, integration, property, platform, and regression testing strategy.
- `docs/performance.md` — benchmark/profiling policy and measurement evidence rules.
- `docs/accessibility.md` — semantics, keyboard, large-text/contrast/motion review requirements and automated safeguard boundaries.
- `docs/localization.md` — ARB/gen-l10n workflow and locale acceptance policy.
- `docs/keyboard-shortcuts.md` — desktop/Web navigation shortcut behavior and accessibility expectations.
- `docs/diagnostics.md` — privacy-preserving structured diagnostic logging contract.
- `docs/dependencies.md` — dependency selection, Dependabot, review, and update policy.
- `docs/threat-model.md` — trust boundaries, threats, mitigations, and security assumptions.
- `docs/platform-support.md` — target/support/release-verification terminology.
- `docs/native-platforms.md` — required reviewed native project work and target-specific release checks.
- `docs/platform-smoke.md` — six-platform release-build evidence and its limits.
- `docs/release.md` — `2.0.12` version/tag/source/native release procedure.
- `docs/release-checklist.md` — auditable release-candidate checklist.
- `docs/github-maintenance.md` — branch protection, security settings, labels, workflows, and repository administration.
- `docs/troubleshooting.md` — common development/build/runtime troubleshooting guidance.
- `docs/repository-inventory.md` — this exhaustive tracked-file ownership/purpose inventory.

## Architecture decision records

- `docs/adr/0001-rust-core-flutter-ui.md` — decision to separate authoritative Rust domain logic from Flutter presentation.
- `docs/adr/0002-exact-decimal-arithmetic.md` — decision to avoid binary floating-point for conversion-domain values.
- `docs/adr/0003-local-first-persistence.md` — decision for offline/local-first user state.
- `docs/adr/0004-deterministic-dart-fallback.md` — temporary deterministic Dart compatibility engine and bridge transition constraints.

## Repository scripts and validator tests

- `scripts/bootstrap_platforms.sh` — Bash helper for deliberate Flutter native-platform scaffold generation/review.
- `scripts/bootstrap_platforms.ps1` — PowerShell equivalent for native-platform scaffold generation/review.
- `scripts/check_accessibility_contract.py` — source-level reduced-motion, modal-surface, converter semantics, smoke-test, and verification-wiring contract validator.
- `scripts/check_conversion_session_contract.py` — source-level one-shot native loading, sticky backend selection, adapter-error containment, response identity/order, runtime no-fallback, and asynchronous stale-result suppression contract validator.
- `scripts/check_markdown_links.py` — repository-local Markdown target validator.
- `scripts/check_platform_support.py` — six-target generation/build/project-set/Web-compatibility support validator.
- `scripts/check_release_consistency.py` — package/version/changelog/Rust-minimum/schema/bridge-protocol/capability/batch-limit declaration consistency validator.
- `scripts/check_release_tag.py` — exact `v<workspace-version>` release tag validator.
- `scripts/check_repository_hygiene.py` — critical-file presence and tracked secret/build/generated-artifact guard.
- `scripts/check_repository_inventory.py` — exact tracked-file versus documented-inventory drift validator.
- `scripts/update_platform_inventory.py` — regenerates the machine-maintained inventory for tracked Flutter-generated platform files.
- `scripts/verify.sh` — full Bash repository/source verification entry point.
- `scripts/verify.ps1` — full PowerShell repository/source verification entry point.
- `scripts/tests/test_conversion_session_contract.py` — standard-library regression checks for one-shot loading, sticky native bridge assignment, adapter-error/failure classification, latest-request race suppression, and validator acceptance.
- `scripts/tests/test_repository_validators.py` — standard-library regression tests for repository validators, release-tag behavior, platform support, bridge parity, and accessibility source safeguards.

## Inventory maintenance rule

The bullet paths in this document are the machine-readable inventory. Keep each tracked path in backticks and document it exactly once. Directories themselves are not tracked entries and therefore are not listed separately. Generated/untracked files are documented by policy where relevant but are not inventory entries.
