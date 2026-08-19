# UnitFlow — Current Development Handoff

_Last updated: 2026-08-19_

This file is the current continuation checkpoint for the active Phase 1/quality-audit branch. The original `what_changed.md` remains in the repository from the bootstrap checkpoint; this document supersedes that checkpoint until the active audit branch is merged and the canonical handoff is refreshed.

## Current milestone

- Product version: `0.1.0-alpha.1`
- Active branch: `audit/phase-1-quality`
- Pull request: `#2 — test: audit phase 1 quality gates`
- Repository: `https://github.com/sanskarIN/unitflow`
- Source model: public / open source / MIT
- Architecture: Rust authoritative domain core + Flutter presentation, with a dedicated `flutter_rust_bridge` boundary and deterministic Dart exact-decimal fallback.
- Required project credit: **Made by the Sanskar**

## Completed repository foundation

- Added MIT license and core repository hygiene:
  - `.gitignore`
  - `.editorconfig`
  - `.gitattributes`
  - `.env.example`
- Added governance and support documentation:
  - `CONTRIBUTING.md`
  - `CODE_OF_CONDUCT.md`
  - `SECURITY.md`
  - `SUPPORT.md`
  - `PRIVACY.md`
  - `CHANGELOG.md`
  - `ROADMAP.md`
- Added architecture/setup/development/testing/release/troubleshooting/accessibility/performance documentation.
- Added ADRs for:
  - Rust-core + Flutter UI architecture;
  - generated Rust–Flutter bridge with deterministic fallback.
- Added GitHub repository operations guidance including branch protection, labels, milestones, Discussions, release, and funding guidance.
- Added editable logo and app-icon SVG artwork under `docs/assets/`.
- Added Buy Me a Coffee funding metadata and visible project support links.
- Added structured GitHub bug/feature templates and pull-request checklist.
- Added Dependabot configuration for Cargo, Pub, and GitHub Actions.

## Rust domain core completed so far

Workspace crate: `crates/unitflow_core`

Implemented:

- strongly typed category model;
- validated immutable unit definitions;
- stable unit identifiers;
- built-in catalog covering more than 100 units across:
  - length;
  - area;
  - volume;
  - mass;
  - speed;
  - pressure;
  - energy;
  - power;
  - angle;
  - data size;
  - frequency;
  - time;
  - temperature;
- exact base-unit affine conversion model:

```text
base = value * scale + offset
output = (base - target.offset) / target.scale
```

- `rust_decimal` high-precision decimal arithmetic;
- checked arithmetic and typed failures;
- explicit rounding modes:
  - nearest-even;
  - half-away-from-zero;
  - toward zero;
  - away from zero;
  - floor;
  - ceiling;
- batch conversion preserving requested target order;
- search by name, stable ID, symbol, and aliases with exact/prefix/substring ranking;
- safe affine custom units with validation;
- plain/scientific/engineering notation formatting without binary floating point;
- crate-level `forbid(unsafe_code)` for the domain core.

## Rust–Flutter bridge completed so far

Workspace crate: `crates/unitflow_bridge`

Implemented:

- thin bridge DTOs;
- decimal values represented as strings at the language boundary;
- bridge endpoints for:
  - version;
  - catalog listing;
  - catalog search;
  - conversion;
  - notation formatting;
- `flutter_rust_bridge` dependency and reproducible bridge-generation script;
- bridge API tests;
- generated FFI code isolated from the unsafe-free domain crate.

The Flutter production adapter that consumes generated Dart bridge bindings remains an exact next task after generator verification passes in CI. Until then Flutter uses the deterministic exact-decimal fallback implementing the same application-facing contract.

## Flutter application completed so far

Application: `apps/unitflow_app`

Implemented architecture/features:

- Material 3 design system with spacing/radius/breakpoint tokens;
- system/light/dark themes;
- adaptive navigation rail / bottom navigation;
- keyboard shortcuts for desktop/web navigation;
- polished first-run onboarding;
- responsive converter screen;
- exact-decimal deterministic Dart fallback engine;
- locale-aware decimal parsing and display formatting;
- scientific and engineering notation preferences;
- configurable decimal places;
- digit grouping preference;
- searchable unit library;
- favorites;
- pinned conversion pairs;
- recent conversion history;
- quick pair reopening;
- safe custom-unit editor using affine scale/offset formulas;
- category explanations and educational examples;
- quick source/target swap;
- batch conversion table;
- direct result copy;
- deterministic batch CSV generation and copy;
- local settings/favorites/history/pins/custom-unit persistence;
- versioned JSON backup schema;
- clipboard backup/restore;
- bounded cross-platform file-picker backup import/export;
- schema validation before replacing local state;
- import-size and UTF-8 validation;
- About screen with:
  - project version;
  - MIT license information;
  - privacy summary;
  - GitHub repository;
  - Buy Me a Coffee;
  - support/business contacts;
  - **Made by the Sanskar**;
- redacting structured diagnostic logger;
- generated localization architecture with external English ARB source;
- offline-first static conversion behavior without forced account/login.

## Local data model

Current backup schema version: `1`

Locally persisted data includes:

- theme/notation/formatting preferences;
- onboarding state;
- favorites;
- pinned pairs;
- bounded recent history;
- validated custom units.

Import validation rejects unsupported schemas and invalid custom-unit data before state replacement.

## Test coverage added

### Rust

- built-in catalog/category coverage;
- search ranking and alias search;
- exact metric conversion;
- international mile conversion;
- Celsius/Fahrenheit affine conversion;
- category mismatch rejection;
- explicit rounding-mode behavior;
- batch ordering;
- precision bounds;
- custom-unit scale/identifier/alias validation;
- scientific/engineering notation;
- bridge endpoint tests;
- property-based tests for:
  - identity conversion;
  - exact metric round trips;
  - batch target ordering.

### Fuzzing

Cargo-fuzz harnesses under `fuzz/` for:

- arbitrary UTF-8 catalog search;
- parsed arbitrary decimal values through notation formatting.

### Flutter

- exact-decimal parser/arithmetic;
- scientific input parsing;
- rounding behavior;
- deterministic conversion engine;
- Celsius/Fahrenheit conversion;
- cross-category rejection;
- batch target ordering;
- versioned backup JSON round-trip;
- invalid schema rejection;
- custom-unit validation;
- batch CSV escaping;
- app launch into converter after onboarding;
- first-run onboarding completion;
- key action tooltip/semantic discoverability.

## Automation and release engineering added

- Primary CI workflow:
  - Rust formatting;
  - Rust Clippy with warnings denied;
  - Rust workspace tests;
  - Flutter dependency resolution;
  - generated localizations;
  - Dart formatting;
  - Flutter analyzer with infos/warnings fatal;
  - Flutter tests;
  - independent Rust–Flutter bridge generation/check job.
- CodeQL workflow for Rust.
- Dependency review workflow.
- Audit-branch normalization workflow that:
  - generates Rust/Flutter lockfiles;
  - runs Rust/Dart formatters;
  - commits normalization using `Sanskar <sanskarin@outlook.in>` when changes exist.
- Tagged release workflow covering:
  - Rust release profile;
  - Flutter Web;
  - Flutter Android unsigned APK;
  - Flutter Linux;
  - Flutter Windows;
  - Flutter macOS;
  - iOS no-codesign validation.
- Reproducible scripts:
  - `tool/check.sh`
  - `tool/generate_bridge.sh`
  - `tool/bootstrap_platforms.sh`

## Verification history

Known executed repository verification:

1. The first CI run on the initial `main` implementation reached Rust formatting and correctly failed because the newly created source files had not yet been normalized by `rustfmt`.
2. A dedicated audit branch and PR were created so CI failures can be fixed before merging into `main`.
3. An audit-only formatter/lockfile workflow was added so formatting and lockfile generation can be performed by an authenticated GitHub runner with the required commit identity.
4. Subsequent branch changes have intentionally restarted/cancelled earlier queued audit runs; the final audit run must be allowed to finish after feature changes stop.

Do not claim the branch is fully verified until the latest head has completed all required CI jobs successfully.

## Known limitations / unfinished verification

These items are still open and must be handled before calling `0.1.0-alpha.1` release-ready:

1. Let the audit normalization workflow finish on the final branch head and commit formatter/lockfile output if required.
2. Inspect the newest Rust/Flutter/bridge CI jobs and fix every compile, format, lint, or test failure.
3. Validate `flutter_rust_bridge_codegen 2.12.0` against the checked-in bridge API and generated Dart/Rust glue.
4. Add the production Rust-backed Flutter `ConversionEngine` adapter after generated bindings are verified; keep the deterministic fallback for web/tests/graceful startup.
5. Run the tagged release workflow or equivalent platform builds on compatible hosts and repair platform-specific packaging issues if discovered.
6. Replace README demo placeholders with real captures after a verified runnable platform build.
7. Remove the temporary audit-only autoformat workflow before stable release if it is no longer useful.
8. Refresh canonical `what_changed.md` after PR merge.
9. Perform the Phase 6 clean-clone, documentation-link, accessibility, dependency/security, and release-candidate audit.

## Exact next tasks

1. Stop feature commits temporarily.
2. Let the latest `audit/phase-1-quality` workflows run.
3. Read failing job steps/logs, if any.
4. Fix failures with regression tests where behavior bugs are found.
5. Regenerate/verify bridge bindings.
6. Run the complete quality suite again.
7. Merge PR #2 with history preserved only when required checks are green or an external repository-setting limitation is explicitly documented.
8. Continue Phase 2/3 platform integration from the merged state instead of rewriting finished domain/UI work.

## Commit strategy

Development has been intentionally split into many small, meaningful Conventional-Commit-style changes across documentation, architecture, domain models, conversion logic, UI features, testing, security, CI, release engineering, accessibility, localization, persistence, and bug fixes.

Do not create empty commits or one-line churn solely to inflate commit count.

## Contact / project identity

- GitHub: `https://github.com/sanskarIN`
- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`
- Buy Me a Coffee: `https://buymeacoffee.com/sanskarIN`

---

**Made by the Sanskar**
