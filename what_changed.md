# UnitFlow — Canonical Development Handoff

This is the primary continuation and audit checkpoint for UnitFlow. Keep this file current whenever implementation, verification status, migration behavior, release readiness, or known blockers change.

## Repository and active work

- Repository: `https://github.com/sanskarIN/unitflow`
- Visibility: public / open source
- License: MIT
- Default branch: `main`
- Active implementation branch: `audit/phase-1-quality`
- Active pull request: `#2` — **feat: complete UnitFlow application and quality hardening**
- Target preview: `0.1.0-alpha.1`
- Required visible product credit: **Made by the Sanskar**
- Requested maintainer commit email: `sanskarin@outlook.in`

Always read the live PR head before using a SHA as release evidence. The branch advances frequently while hardening is active.

## Source-of-truth rules

Implementation is governed by the UnitFlow master prompt supplied for this repository. Important non-negotiable characteristics retained by the implementation include:

- Rust conversion/domain core plus Flutter UI;
- deterministic high-precision decimal behavior rather than binary floating-point conversion shortcuts;
- explicit rounding behavior;
- broad built-in unit catalog and validated custom affine units;
- offline-first static conversions;
- local-first preferences/history/custom-unit data;
- adaptive and accessible cross-platform UX;
- Android, Windows, Linux, macOS, Web, and iOS-ready targets;
- public MIT-licensed repository with complete support/security/contribution documentation;
- visible **Made by the Sanskar** credit;
- no fabricated build, screenshot, platform, security, or release-completion claims.

## Implementation checkpoint

### Repository foundation and governance

Implemented:

- production README and project positioning;
- MIT license;
- contribution guide;
- code of conduct;
- security policy and private vulnerability-reporting guidance;
- privacy policy;
- support guidance;
- changelog and roadmap;
- issue templates and pull-request template;
- Dependabot configuration;
- Buy Me a Coffee funding metadata;
- architecture/setup/development/testing/troubleshooting/accessibility/performance/release/platform/bridge/branding/data-format/verification documentation;
- ADR structure;
- repository-safe `.env.example` guidance;
- CI, CodeQL, dependency-review, audit-formatting, and release workflows.

### Rust conversion core

`crates/unitflow_core` contains the authoritative domain implementation:

- category model;
- validated unit definitions;
- versioned built-in unit catalog with stable identifiers, symbols, aliases, descriptions, scales, and affine offsets;
- categories covering length, area, volume, mass, speed, pressure, energy, power, angle, data size, frequency, time, and temperature;
- stable-ID lookup index;
- category-scoped catalog access;
- deterministic text search;
- `rust_decimal`-based conversion through base units;
- explicit decimal precision validation;
- explicit rounding modes:
  - nearest-even;
  - half-away-from-zero;
  - toward zero;
  - away from zero;
  - floor;
  - ceiling;
- single conversion;
- ordered batch conversion;
- notation/formatting helpers;
- validation and typed failure handling;
- unit/regression/property-oriented tests;
- fuzz-target support;
- release-mode profiling example for lookup/search/single/batch workloads.

Rust unit-definition matching now includes descriptions as well as IDs, names, symbols, and aliases. A dedicated regression test covers case-insensitive description matching.

### Rust ↔ Flutter bridge

`crates/unitflow_bridge` provides a Flutter Rust Bridge-facing API around the Rust core.

Bridge responsibilities implemented at source level:

- safe DTOs for conversion requests/results;
- decimal values crossing the bridge as strings instead of binary floating point;
- explicit bridge rounding-mode mapping;
- single conversion API;
- batch conversion API;
- unit listing API;
- search API;
- pinned Flutter Rust Bridge dependency/code-generator version `2.12.0`;
- reproducible generation command in `tool/generate_bridge.sh`;
- CI/audit normalization that installs the pinned generator and regenerates bindings.

Important release boundary: generated bindings and native-library packaging/loading still require exact-candidate CI/platform evidence. Binding source code existing in the repository is not the same as proving that every final platform artifact loads the native Rust library correctly.

### Deterministic Dart fallback

Flutter includes an arbitrary-precision base-10 `ExactDecimal` fallback with:

- parsing including scientific notation;
- addition/subtraction/multiplication/division;
- explicit fractional precision;
- six rounding modes matching the Rust-facing behavior;
- canonical/fixed formatting;
- regression tests.

This avoids converting user values through ordinary binary floating point when the native bridge is unavailable, including the web/fallback path.

### Flutter application

The Flutter application currently includes:

- application bootstrap and controller;
- Material 3 light/dark/system themes;
- responsive navigation rail / bottom navigation;
- converter, library, history, settings, About, and onboarding experiences;
- desktop keyboard navigation shortcuts;
- Ctrl/Cmd + K library/search destination shortcut;
- reusable project-authored `UnitFlowMark` identity;
- startup branding;
- visible **Made by the Sanskar** credit;
- locale-aware parsing/formatting foundation;
- generated Flutter localization infrastructure;
- English ARB source catalog;
- deterministic result formatting;
- selectable precision, notation, grouping, and rounding settings;
- explicit reduced-motion preference;
- theme-transition/onboarding reduced-motion behavior;
- platform `disableAnimations` handling during onboarding;
- responsive compact/expanded converter layouts;
- accessible result semantics and major control tooltips;
- source/target swap;
- pin/unpin current pair;
- batch conversion table;
- deterministic CSV copying;
- searchable unit library;
- favorites;
- pinned-pair quick actions;
- recent conversion history;
- undoable history clearing;
- validated custom-unit editor;
- custom-unit deletion with undo;
- file/clipboard backup export/import workflows;
- user-initiated Releases-page access;
- About/support/funding/privacy links.

### Local data and backup format

Current `UserState` persists:

- theme;
- notation;
- rounding mode;
- decimal places;
- digit grouping;
- reduced motion;
- onboarding completion;
- favorite unit IDs;
- pinned pairs;
- bounded recent conversions;
- validated custom units.

Current portable schema is version `2`, documented in:

- `schemas/unitflow-backup-v1.schema.json` — compatibility reference;
- `schemas/unitflow-backup-v2.schema.json` — current schema;
- `docs/data-format.md` — behavior/migration contract.

Migration behavior:

- valid schema-v1 backups migrate to `nearestEven`, which preserves UnitFlow's historical rounding default;
- schema-v1 backups migrate `reduceMotion` to `false`;
- early schema-v2 backups that contain rounding but lack the later optional `reduceMotion` field remain valid and default reduced motion to `false`;
- unknown future schemas are rejected rather than silently reinterpreted;
- import validation occurs before replacing the active state;
- malformed/unsupported imports must not partially overwrite the current profile.

Additional strictness added during the latest hardening pass:

- unknown root and nested fields are rejected to match `additionalProperties: false`;
- pinned unit IDs must match the stable-ID grammar and serialized pin strings are length bounded;
- duplicate favorite IDs, pinned pairs, and custom-unit IDs are rejected;
- oversized pin/recent/custom-unit collections are rejected instead of silently truncating input;
- production and in-memory repositories use the same maximum-size decoder;
- locally created custom units cannot exceed the portable 200-unit limit;
- custom names/symbols/descriptions/aliases are normalized before persistence;
- aliases are case-insensitively deduplicated;
- custom scale/offset values are persisted in canonical exact-decimal form.

### Error handling and diagnostics

Implemented:

- structured app logger with redaction-oriented policy;
- stable user-safe error messages for backup/custom-unit failures;
- raw internal exception text is not intentionally echoed into those UI flows;
- helper `core/errors/user_safe_error.dart` logs exception type metadata while returning a safe localized fallback;
- state-load/save failures use diagnostics without storing conversion values/backup payloads;
- widget/core regression coverage for non-echoing error presentation.

### Search and education

Implemented:

- searchable identifiers, names, symbols, aliases;
- description-aware matching in the deterministic Dart catalog path;
- description-aware matching at the Rust unit-definition layer;
- broad Rust catalog descriptions and aliases;
- category explanations and examples in the converter learning panel;
- custom unit descriptions/aliases;
- regression coverage for descriptive custom-unit search and Rust description matching.

### Accessibility

Implemented source-level foundations:

- semantic labels/tooltips for major converter actions;
- keyboard navigation and adaptive desktop navigation;
- large-text-friendly responsive layouts rather than hard text-scale clamping;
- explicit reduced-motion preference;
- platform/framework animation-disable awareness during onboarding;
- light/dark/system theme support;
- user-safe validation/error text;
- accessibility documentation and release review requirements.

Still required before release-ready status:

- real-device/desktop large-text review;
- keyboard focus review;
- screen-reader-oriented review;
- contrast review on actual rendered builds;
- platform-specific reduced-motion review.

### Branding

Implemented:

- Flutter runtime brand mark at `apps/unitflow_app/lib/app/branding/unitflow_mark.dart`;
- editable source vector at `assets/branding/unitflow-mark.svg`;
- mark used in application shell, startup, and About identity;
- branding/export guidance in `docs/branding.md`.

Still required before release distribution:

- generate final raster launcher/splash assets from the vector source;
- install them into committed platform shells;
- validate actual installed launcher/startup rendering on release targets.

Do not fabricate or substitute fake screenshots as release evidence.

## Testing and quality infrastructure

### Rust

Implemented coverage includes:

- catalog construction/validation;
- category/unit conversion behavior;
- affine temperature behavior;
- precision/rounding behavior;
- batch ordering;
- error cases;
- notation helpers;
- property/regression-oriented invariants;
- description-aware unit-definition matching;
- bridge-input and catalog-search fuzz targets.

### Flutter

Implemented coverage includes:

- exact-decimal arithmetic;
- conversion engine behavior;
- user-state backup round trip;
- schema-v1 → schema-v2 migration;
- early schema-v2 compatibility;
- strict unknown-field rejection;
- persisted stable-ID validation;
- collection-bound validation;
- shared in-memory/production import-size behavior;
- custom-unit normalization and 200-unit limit behavior;
- custom-unit validation;
- app-controller favorites/pins/history/custom units;
- persisted rounding/grouping/precision settings;
- reduced-motion persistence;
- safe user error presentation;
- catalog description search;
- app startup/onboarding;
- converter semantic tooltips;
- Settings reduced-motion interaction;
- primary offline journey covering conversion submission, recent history, pinning, swapping, and reopening a recent pair.

### Repository safety

CI now includes dependency-free repository checks:

- `tool/check_secrets.py` — common committed private-key/token signature scan over tracked text-like files;
- `tool/check_data_files.py` — UTF-8 JSON parsing for tracked JSON/ARB data and duplicate-object-key rejection;
- `tool/check_docs_links.py` — internal Markdown target validation;
- `tool/test_check_data_files.py` — regression tests proving unique objects are accepted and duplicate root/nested keys are rejected.

Repository utility tests are part of CI, `tool/check.sh`, and `tool/verify_release_candidate.sh` so local, pull-request, and strict release verification exercise the same safety helper behavior.

These supplement, not replace, CodeQL, dependency review, compiler/linter/test checks, and GitHub's own repository security features.

### Performance

Implemented:

- `crates/unitflow_core/examples/profile.rs` release-mode profiling smoke harness;
- `tool/profile_core.sh` command;
- workload coverage for stable-ID lookup, category-scoped search, single conversion, and length batch conversion;
- documented rule that raw timing from dissimilar hosts must not be treated as equivalent benchmark evidence.

No release performance number is claimed until output is recorded with machine/toolchain context.

## Developer and release commands

### Development quality

```bash
bash tool/check.sh
```

This covers repository utility regression tests, safety/data/docs checks, and Rust and Flutter gates. It regenerates the bridge only when the generator is installed and warns when that extra check is skipped.

### Bridge generation

```bash
cargo install flutter_rust_bridge_codegen --version 2.12.0 --locked
bash tool/generate_bridge.sh
```

### Strict release candidate

```bash
bash tool/verify_release_candidate.sh
```

The strict verifier requires the pinned bridge generator and runs repository utility regression tests, repository checks, Rust formatting/lint/tests/release build, Flutter localization/format/analyze/tests, bridge regeneration, post-generation analysis/tests, web release build, clean generated-source check, and core profiling harness.

Native platform builds/manual review remain separate platform gates.

## GitHub Actions

Configured workflows include:

- CI:
  - repository safety and repository utility regression tests;
  - Rust quality;
  - Flutter quality;
  - Rust/Flutter bridge generation/check;
- CodeQL;
- dependency review;
- audit-branch generated-source/format normalization;
- multi-platform release workflow.

### Current verification truth

During active development, many workflow runs are cancelled/superseded by later commits because concurrency is configured to keep the latest branch state authoritative. A queued, pending, cancelled, skipped, or older green run is **not** a passing result for the newest head.

The latest exact-candidate workflows must be re-read after this handoff commit. Therefore:

- do **not** claim Rust CI green for the current final head yet;
- do **not** claim Flutter CI green for the current final head yet;
- do **not** claim bridge generation green for the current final head yet;
- do **not** claim CodeQL/dependency review green for the current final head yet;
- do **not** merge PR #2 until the newest head is checked and failures are fixed.

## Commit identity note

Requested commit email: `sanskarin@outlook.in`.

The connected GitHub Contents API used for most atomic file commits does not expose an author/committer-email parameter, so those connector-created commits use identity determined by the authenticated GitHub integration. Do not falsely claim otherwise.

The repository's audit normalization workflow explicitly configures:

```text
user.name = Sanskar
user.email = sanskarin@outlook.in
```

before it creates its own generated-source/formatting normalization commit. Contributor/setup documentation also uses the requested email for local Git configuration.

## Files/directories of special importance

```text
README.md
ROADMAP.md
CHANGELOG.md
what_changed.md
Cargo.toml
crates/unitflow_core/
crates/unitflow_bridge/
apps/unitflow_app/
fuzz/
assets/branding/
schemas/
tool/
docs/
.github/
```

Recent additions/hardening include:

```text
apps/unitflow_app/lib/app/branding/unitflow_mark.dart
apps/unitflow_app/lib/core/errors/user_safe_error.dart
apps/unitflow_app/lib/core/persistence/user_state.dart
apps/unitflow_app/lib/core/persistence/user_state_repository.dart
apps/unitflow_app/lib/features/converter/domain/unit_models.dart
apps/unitflow_app/test/app/custom_unit_limits_test.dart
apps/unitflow_app/test/app/primary_journey_test.dart
apps/unitflow_app/test/core/user_safe_error_test.dart
apps/unitflow_app/test/core/user_state_test.dart
apps/unitflow_app/test/features/unit_catalog_search_test.dart
assets/branding/unitflow-mark.svg
schemas/unitflow-backup-v2.schema.json
tool/check_secrets.py
tool/check_data_files.py
tool/check_docs_links.py
tool/test_check_data_files.py
tool/profile_core.sh
tool/verify_release_candidate.sh
crates/unitflow_core/examples/profile.rs
crates/unitflow_core/tests/unit_definition_search.rs
docs/bridge.md
docs/platform-support.md
docs/branding.md
docs/data-format.md
```

## Latest continuation commits

The latest hardening sequence before this handoff commit is:

- `7edc504d8c69531b88a544802a6110e12be66c1c` — `fix: search Rust unit descriptions`
- `80bdef48ee3e4307a040e31475b08dc30fd82ea4` — `test: cover description-aware unit matching`
- `4eee687a31b4d3fd79433cf92746e0dba6c64d0b` — `fix: validate persisted pinned pair identifiers`
- `14351ac96b0cbe5a05a4a9864302c4e30a25e441` — `fix: enforce backup schema bounds and normalization`
- `6437213e0be07d249b04da14a218cf887e16a356` — `fix: keep local state within backup limits`
- `cbe6c96aff56758430532c9ec2208b53042fe1cf` — `test: cover strict backup validation`
- `4a5d5d0b11d1ca289ddcb3e1c4b287564094b046` — `fix: reject duplicate JSON object keys`
- `0c096dced145eca0c5b6ba184dac09f21232f917` — `refactor: share strict backup decoding`
- `d4d1c0df30dbe32d166049efbda09c994202ddb7` — `docs: document strict backup contract`
- `ce7fc23c85e41e10ff96466efbcb75bac0c08dec` — `docs: record strict backup hardening`
- `e50194988948c308c931a6562adf1747fc7bd6b5` — `test: keep in-memory import limits production-equivalent`
- `f3300fa5f882641032df0677446c16dda5e3c58f` — `test: enforce custom unit collection limit`
- `887cfcd43c8225fcac69422d8f05bf2f81389e5e` — `test: cover duplicate structured data keys`
- `d1765309591d5e612151e89a58655badef0838dd` — `ci: run repository utility regression tests`
- `3d80d009c5e0751f96f5b0627ee52ddaa4cf3940` — `docs: document repository utility tests`
- `5db112ac6e659c6466ca4e79549604af310ea1fd` — `build: include repository utility regression tests`
- `9dd233969e8d59f11b9a36a59a8ba0118689006c` — `build: run utility tests in release verification`
- `a8f511dc58d0c2d04d767c300921443bf8750956` — `docs: include repository utility regression command`
- `ff794c6a4c2baf8def3a46071ec849b5f541ddeb` — `docs: record completed backup hardening gates`

These commits deliberately remain granular rather than combining unrelated fixes.

## Verification performed in the current continuation

Static repository inspection confirmed:

- PR #2 remains open and mergeable;
- there were no open repository issues at the time checked;
- no `TODO`, `FIXME`, `unimplemented`, `panic!`, or production `unwrap()`/`expect()` matches were surfaced by repository search;
- `Cargo.lock` and `apps/unitflow_app/pubspec.lock` were still absent before the newest audit-normalization run; the configured audit workflow is responsible for resolving and committing normalized lock/generated output on this branch;
- the Flutter Rust Bridge generated Rust module is still a placeholder until the pinned generator executes, so native bridge completion must not be claimed before exact workflow evidence exists.

The execution environment used for connector-driven work still does not provide the project Rust/Flutter toolchains locally. Therefore compiler/analyzer/test success is intentionally not fabricated. GitHub Actions on the newest exact head remains the authoritative automated evidence source.

## Remaining release blockers / exact next work

These are not hidden TODOs; they are explicit release gates.

1. Stop source churn long enough for workflows on the newest exact PR head to execute.
2. Inspect latest CI jobs/logs rather than relying on older runs.
3. Fix every formatter/compiler/analyzer/test/repository-safety failure discovered by those workflows.
4. Ensure the audit normalization workflow successfully produces lockfiles, regenerates Flutter localizations, and regenerates FRB bindings using pinned versions.
5. Inspect the generated Dart/Rust bridge API and wire/validate the native runtime adapter without guessing generated API names.
6. Prove native Rust library packaging/loading on Android/Windows/Linux/macOS/iOS-ready builds.
7. Prove deterministic web fallback behavior against representative Rust regression vectors.
8. Run the cross-platform release workflow for an exact release candidate and fix all build issues.
9. Run manual primary user journeys on the advertised release platforms.
10. Complete keyboard/text-scaling/screen-reader/contrast/reduced-motion manual accessibility review.
11. Export and install final launcher/splash assets from the source SVG into real platform shells.
12. Capture real phone/desktop/dark-mode screenshots from validated builds.
13. Record performance profiling output with hardware/toolchain context.
14. Run a documented fuzzing campaign budget for the release candidate.
15. Generate and publish checksum metadata for final downloadable artifacts.
16. Configure signing/notarization/store credentials only in private platform/repository secret facilities, never in source.
17. Run `tool/verify_release_candidate.sh` on the exact release candidate and ensure it leaves no tracked changes.
18. Re-read this file, `ROADMAP.md`, `CHANGELOG.md`, and release docs for stale claims before tagging.
19. Tag/release `0.1.0-alpha.1` only after the applicable automated/manual gates are satisfied.

## Completion policy

UnitFlow source is substantially implemented, but **the project must not be called fully release-complete while the newest exact-candidate CI/platform/manual/release evidence remains incomplete**. Continue from the blockers above, fix evidence-producing failures rather than hiding them, and keep this handoff synchronized with reality.

## Release notes draft — 0.1.0-alpha.1

Planned initial preview includes the high-precision Rust conversion core, deterministic Flutter fallback, adaptive converter/library/history/settings UX, favorites/pins/custom units, batch conversion, local backup/restore, explicit rounding/notation controls, reduced-motion accessibility preference, localization infrastructure, project branding, bridge/release automation, strict bounded backup validation, security/privacy safeguards, and broad automated quality coverage.

Release-note wording must be finalized only after the exact tagged candidate passes the required checks.
