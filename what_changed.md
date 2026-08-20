# UnitFlow — Development Handoff

This is the primary continuation checkpoint for future UnitFlow development sessions. Detailed engineering notes live here so chat replies can remain short.

Last updated: **2026-08-20**

Repository: `https://github.com/sanskarIN/unitflow`

Branch: **`main`**

Current source version: **`2.0.12`**

Flutter build number: **`12`**

Latest inspected continuation commit before this handoff update: **`fb07432b71e7f7cea1f6a5f6cddf950acb21996e`**

## Release state

UnitFlow remains source-aligned to `2.0.12` across the Rust workspace, Flutter package metadata, About surface, changelog, roadmap, testing/release/setup documentation, repository inventory, and consistency validators.

**Do not describe `2.0.12` as a verified native release yet.** No `v2.0.12` tag was created. Generated native bindings, reviewed committed platform projects, native packaging/build evidence, full CI evidence, accessibility/performance review, and release-candidate checks remain open.

## 2026-08-20 continuation completed

This continuation started from the previous `2.0.12` final-handoff commit `0a6791373ad21a875872e61ffffb1aa296f06cae` and audited the roadmap rather than assuming the repository was fully finished.

The audit confirmed that substantial source functionality was already complete, but the production Rust↔Flutter bridge path and deeper persisted-journey coverage still had meaningful source-level work available.

### Rust source bridge service added

New file: `crates/unitflow_core/src/bridge.rs`.

The Rust core now exposes a generator-friendly bridge protocol service below the future native binding layer:

- protocol version constant `BRIDGE_PROTOCOL_VERSION = 1`;
- diagnostic backend identifier `rust-core`;
- `BridgeConversionRequest`;
- `BridgeConversionResponse`;
- `BridgeBatchConversionRequest`;
- `BridgeFailure` with owned binding-friendly strings;
- long-lived `BridgeService` wrapping a validated `Converter`;
- single conversion through canonical base-10 decimal strings;
- ordered batch conversion;
- decimal payload length ceiling aligned to the Dart boundary;
- canonical decimal validation using Rust decimal parsing/normalization;
- safe domain-error to stable bridge-code mapping;
- no raw unknown-unit identifiers echoed into bridge error messages.

Stable source-service error mappings include:

- `invalid_decimal`;
- `unknown_unit`;
- `category_mismatch`;
- `invalid_precision`;
- `catalog_invalid`;
- `conversion_failed`.

Invalid rounding identifiers remain a typed DTO deserialization/binding-layer concern and must be normalized to the documented `invalid_rounding_mode` code by the generated adapter.

`crates/unitflow_core/src/lib.rs` now exports the bridge module, service, DTOs, failure type, protocol version, and backend identifier.

This closes the missing **Rust source protocol-service layer**, but it does **not** close the production bridge milestone. Generated Rust↔Flutter bindings, startup negotiation, native library loading, packaging, and platform execution are still required.

### Rust bridge-service regression coverage added

New file: `crates/unitflow_core/tests/bridge_service.rs`.

Coverage includes:

- protocol version/backend metadata;
- canonical decimal string conversion;
- rejection of noncanonical decimal input such as trailing-zero representations;
- safe unknown-unit failures that do not echo untrusted identifiers;
- category-mismatch code mapping;
- invalid-precision code mapping;
- ordered batch conversion results;
- camelCase serialized bridge fields;
- documented `nearestEven` rounding serialization.

A follow-up compile-risk cleanup changed JSON assertions to explicit `.as_str()` comparisons.

### Persisted primary journey coverage added

New file: `apps/unitflow_app/test/persisted_primary_journey_test.dart`.

The test covers a broader controller/repository workflow across controller restart:

- theme persistence;
- notation persistence;
- rounding-mode persistence;
- decimal-place persistence;
- grouping preference persistence;
- onboarding completion;
- favorites;
- pinned pairs;
- recent history;
- custom-unit persistence;
- custom-unit reuse after restart;
- conversion using restored settings/catalog;
- backup export/import;
- restart after import;
- local reset;
- clean baseline persistence after reset.

A follow-up fix corrected the conversion API parameter from the initially written `roundingMode` name to the actual `rounding` parameter.

This is meaningful integration-style source coverage, but it is **not native E2E evidence** and does not replace rendered-UI integration tests.

### Documentation and inventory refreshed

The following existing documents were updated to describe the new state accurately:

- `docs/repository-inventory.md` — inventories the three new tracked source/test files so exact `git ls-files` parity can remain enforceable;
- `docs/bridge.md` — records the implemented Rust source service and explicitly separates it from generated/native integration;
- `docs/bridge-protocol.md` — links both Flutter and Rust source contracts and documents the typed-rounding/deserialization boundary;
- `docs/testing.md` — documents bridge-service tests and persisted-journey coverage while preserving the native-E2E evidence boundary;
- `ROADMAP.md` — marks the versioned Rust source bridge/DTO layer complete and the controller/repository persisted journey complete, while leaving generated bindings/full UI integration/native E2E open;
- `CHANGELOG.md` — refreshed the active `2.0.12` development snapshot to 2026-08-20 with the bridge and persistence hardening work;
- this handoff.

## Current implementation summary

### Rust core

`crates/unitflow_core` includes:

- validated categories and unit definitions with stable IDs;
- exact decimal arithmetic through `rust_decimal`;
- multiplicative and affine conversion;
- explicit rounding modes;
- single and batch conversion;
- searchable built-in catalog;
- validated custom affine units;
- notation formatting;
- educational category metadata;
- typed public errors;
- versioned source bridge protocol service;
- catalog/conversion/custom-unit/notation/education/invariant/shared-parity/bridge-service tests;
- dependency-free conversion micro-benchmark.

### Flutter/Dart application

`apps/unitflow_app` includes:

- adaptive Convert, Batch, Library, History, and Settings workspaces;
- deterministic exact-decimal Dart compatibility engine;
- locale-aware parsing and locale-pattern-aware grouping;
- favorites, pinned pairs, recents, custom units, settings, onboarding;
- versioned local persistence with schema-1 → schema-2 migration;
- backup/import/reset with bounded validation;
- serialized reset ordering and safe persistence-failure UX;
- CSV/TSV/JSON batch export;
- generated English localization architecture;
- keyboard/adaptive navigation;
- safe structured diagnostics;
- About/support/project surfaces;
- Flutter-side native bridge DTO/interface validation;
- controller/repository persisted-journey tests.

### Repository engineering

The repository includes:

- repository-integrity, Rust, and Flutter CI definitions;
- CodeQL;
- dependency review;
- Dependabot for Cargo, pub, and GitHub Actions;
- generated-scaffold smoke builds for Android, Web, Linux, Windows, macOS, and iOS;
- evidence-based release workflow with source packages/checksums;
- exact release-tag/version guard;
- exhaustive tracked-file inventory validation;
- Markdown-link validation;
- version/Rust-minimum/schema/protocol consistency validation;
- repository hygiene validation;
- Bash and PowerShell full-verification entry points;
- deep architecture/setup/testing/security/platform/release/maintenance documentation.

## Important 2.0.12 defects already fixed before this continuation

Earlier `2.0.12` hardening already fixed or added regression coverage for:

- Rust bridge-parity use of the wrong `ConversionResult` field;
- Rust/Dart parity fixture drift by making both consume the same versioned fixture;
- snake_case versus camelCase Rust rounding identifiers;
- Rust minimum-version mismatch, now Rust `1.82+`;
- Rust formatting/package cleanliness issues;
- Rust custom-unit alias count parity with Dart;
- Flutter native bridge canonical decimal/unit-ID/precision validation;
- production/test backup-import boundary inconsistency;
- queued-save versus reset persistence race;
- safe reset failure warning and no false success Snackbar;
- unknown/cross-category/blank/oversized recent-history validation;
- locale-specific primary/secondary decimal grouping;
- release workflow and repository validator hardening.

## Verification status — do not overclaim

### GitHub repository evidence

The authenticated GitHub integration was used to inspect live `main`, roadmap blockers, source contracts, tests, documentation, repository inventory, and recent commits before and after changes.

The latest inspected pre-handoff HEAD was `fb07432b71e7f7cea1f6a5f6cddf950acb21996e` (`docs: document bridge and persisted journey coverage`).

Workflow-run lookup for that commit returned **no workflow runs**. A successful final CI matrix is therefore **not established** by this continuation.

### Local execution evidence

No local Cargo/Rust, Flutter/Dart, or native-platform compile/test result was produced for the new continuation commits. Do not infer successful formatting, compilation, analyzer, test, or platform-build results from source inspection alone.

The repository's intended verification entry points remain:

```bash
bash scripts/verify.sh
```

or:

```powershell
./scripts/verify.ps1
```

on a machine with the documented toolchains.

## Remaining blockers before a real `v2.0.12` native release

1. Obtain and review a complete green repository/Rust/Flutter/platform GitHub Actions matrix for the final candidate commit.
2. Run full local clean-clone verification with the documented Python/Rust/Flutter/native toolchains.
3. Generate and review the Rust↔Flutter binding layer on top of the new Rust `BridgeService`.
4. Add Flutter startup protocol negotiation and a stable session-level native engine selection policy.
5. Package/load the Rust library for every native target where Rust authority is claimed.
6. Generate, review, commit, and validate authoritative Android, Windows, Linux, macOS, Web, and iOS projects as appropriate.
7. Replace generated-scaffold-only evidence with committed-project build evidence target by target.
8. Add rendered primary-UI integration tests and native E2E journeys, including conversion, restart persistence, custom units, backup/import, history, and clipboard/batch workflows.
9. Perform screen-reader, keyboard/focus, large-text, contrast, reduced-motion, and touch-target manual accessibility review.
10. Record catalog-search, batch-conversion, and native profiling baselines on documented hardware where needed.
11. Produce final icon/splash assets, screenshots, demo media, native packages, signing/notarization/store validation from verified builds without committing credentials.
12. Complete the release checklist and downloaded-artifact/release-candidate verification.
13. Only then validate and create the exact `v2.0.12` tag on the audited release commit.

## Exact next priority for a future continuation

1. Inspect the newest live `main` and GitHub Actions state first.
2. Fix any actual formatter/Clippy/analyzer/test failures reported by execution.
3. Implement generated native bindings against `crates/unitflow_core/src/bridge.rs` and `docs/bridge-protocol.md`.
4. Add Flutter protocol negotiation/engine wiring with no silent mid-session fallback.
5. Commit reviewed platform projects one target at a time and update `docs/repository-inventory.md` in the same changes.
6. Add UI integration/native E2E/accessibility/performance evidence.
7. Generate release media and binary packages only after verified builds exist.
8. Complete `docs/release-checklist.md`, then tag `v2.0.12` only when all evidence blockers are closed.

## Commits created in the 2026-08-20 continuation

- `3a36c594` — `feat: add versioned Rust bridge service contract`
- `d0ca30d9` — `feat: export Rust bridge protocol surface`
- `5f769a06` — `fix: keep bridge failures binding-friendly`
- `9781b7ba` — `test: cover Rust bridge service contract`
- `83d5abdb` — `test: cover persisted primary app journey`
- `30551728` — `fix: use conversion engine rounding parameter`
- `29603ff4` — `test: make bridge serde assertions explicit`
- `7e164fd0` — `docs: inventory bridge service and journey tests`
- `24fde373` — `docs: record Rust bridge service progress`
- `78632951` — `docs: link protocol to Rust bridge service`
- `11e48bda` — `docs: record 2.0.12 bridge and persistence hardening`
- `2a861a22` — `docs: refine 2.0.12 remaining bridge and journey work`
- `fb07432b` — `docs: document bridge and persisted journey coverage`

This handoff update itself follows those commits.

## Commit identity note

Requested local commit identity remains:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

The connected GitHub contents API used for these writes does not expose per-write author/committer email fields, so do not claim connector-created commits used a configurable local email value.

## Handoff rules

For any future continuation:

1. inspect live `main` before relying on this file;
2. prefer compiler/test/workflow evidence over assumptions;
3. keep `2.0.12` declarations synchronized unless a different version is explicitly requested;
4. update this file after meaningful work;
5. keep commits focused and descriptive;
6. update the exhaustive repository inventory whenever tracked paths change;
7. never tag or call the release verified while evidence blockers remain open.
