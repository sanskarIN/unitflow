# UnitFlow — Development Handoff

This file is the primary continuation checkpoint for future UnitFlow development sessions. Detailed engineering notes live here so chat responses can remain short.

Last updated: **2026-08-19**

Repository: `https://github.com/sanskarIN/unitflow`

Current source version: **`2.0.12`**

Flutter build number: **`12`**

Current branch: **`main`**

## Current release state

UnitFlow source is now aligned to version `2.0.12` across the Rust workspace, Flutter package metadata, About screen, changelog, release documentation, testing documentation, roadmap, and public README.

This is **not yet a verified native release**. Do not create or describe a `v2.0.12` release as completed until the remaining evidence-based blockers in this file and `ROADMAP.md` have been satisfied.

No release tag was created in this continuation.

## Major implementation already present

### Rust core

`crates/unitflow_core` provides:

- validated categories and unit definitions;
- stable unit IDs;
- exact base-10 arithmetic through `rust_decimal`;
- multiplicative and affine conversion;
- explicit rounding modes;
- single and batch conversion;
- searchable built-in catalog;
- custom affine units;
- notation formatting;
- offline educational metadata;
- typed public errors;
- catalog, conversion, custom-unit, education, notation, invariant, and bridge-parity tests;
- dependency-free benchmark example.

### Flutter/Dart application

`apps/unitflow_app` provides:

- adaptive application shell;
- Convert, Batch, Library, History, and Settings workspaces;
- deterministic exact-decimal Dart compatibility engine;
- locale-aware decimal input/display handling;
- favorites, pinned pairs, recents, custom units, settings, onboarding, and local backup/import/reset;
- CSV/TSV/JSON batch export;
- generated Flutter localization architecture with English source ARB;
- keyboard shortcuts and adaptive navigation;
- safe diagnostic logging;
- About/project/support surfaces;
- versioned local persistence with migration from schema 1 to schema 2.

### Repository engineering

The repository includes:

- CI for repository integrity, Rust, and Flutter;
- CodeQL;
- dependency review;
- Dependabot for Cargo, pub, and GitHub Actions;
- generated platform smoke builds for Android, Web, Linux, Windows, macOS, and iOS;
- evidence-based source release workflow;
- exact release-tag/version guard;
- exhaustive tracked-file inventory validation;
- Markdown link validation;
- release/schema/protocol/toolchain consistency validation;
- repository hygiene validation;
- Bash and PowerShell one-command verification;
- extensive maintainer/product/security/release documentation.

## Version 2.0.12 alignment completed

The requested `2.0.12` source version is now present in:

- root `Cargo.toml` workspace package version;
- Flutter `pubspec.yaml` as `2.0.12+12`;
- About screen `appVersion`;
- `CHANGELOG.md`;
- `ROADMAP.md` release target;
- `docs/release.md` tag examples/procedure;
- `docs/testing.md` release-tag example;
- `README.md` public status;
- this handoff.

`scripts/check_release_consistency.py` dynamically verifies Cargo, Flutter, About, changelog, schema, bridge protocol, and documented Rust-minimum declarations so future drift is caught automatically.

## Important defects fixed during the final 2.0.12 audit

### Rust bridge parity compile failure

`crates/unitflow_core/tests/bridge_parity.rs` referenced `result.value`, but `ConversionResult` exposes the converted value as `result.output`.

The test now uses `result.output`.

### Shared parity fixture was not actually shared by Rust

Dart consumed `fixtures/bridge_parity_v1.json`, but Rust duplicated those vectors manually. That allowed the two suites to drift.

Rust now directly deserializes the same fixture used by Dart.

The shared fixture was expanded to cover:

- representative length conversions;
- affine temperature conversion;
- time conversion;
- binary data-size conversion;
- nearest-even rounding;
- half-away-from-zero rounding;
- toward-zero rounding;
- away-from-zero rounding;
- floor rounding;
- ceiling rounding;
- positive and negative cases.

### Rust bridge rounding identifiers disagreed with protocol

Rust `RoundMode` previously used snake_case Serde names while the documented bridge contract and Dart request DTO use camelCase identifiers.

Rust now serializes/deserializes the documented identifiers:

- `nearestEven`;
- `halfAwayFromZero`;
- `towardZero`;
- `awayFromZero`;
- `floor`;
- `ceiling`.

A regression test locks this behavior.

### Rust minimum version declaration was too low

The core uses `Option::is_none_or`, while the workspace previously declared Rust `1.80`.

The workspace minimum is now `1.82`, setup documentation is aligned, README reports `Rust 1.82+`, and release-consistency validation checks that the Cargo minimum and setup documentation stay synchronized.

### Rust formatting/release-quality issues

- notation tests were normalized for `rustfmt`;
- custom-unit tests were normalized for `rustfmt`;
- the intentionally dense built-in unit data table is protected with `#[rustfmt::skip]` so constants remain compact/auditable without excluding executable module logic from formatting checks;
- release packaging no longer uses `cargo package --allow-dirty`; a clean package tree is required.

### Rust custom-unit alias ceiling

Dart already bounded custom-unit aliases at 32 entries; Rust did not.

Rust now rejects more than 32 aliases with a typed `TooManyAliases` error, and regression coverage verifies the bound.

### Native bridge DTO validation

The Flutter-side native bridge boundary previously checked response types/lengths but did not enforce the documented canonical decimal contract.

The bridge now validates before accepting/emitting payloads:

- canonical exact decimal strings;
- stable unit IDs matching lowercase ASCII/digit/underscore/hyphen syntax;
- 1–64-character unit IDs;
- decimal precision in the supported 0–28 range;
- bounded decimal text.

Tests cover malformed requests, malformed responses, noncanonical decimal text, invalid IDs, unsupported precision, and safe bridge-failure stringification.

### Backup import behavior differed between production and tests

`MemoryUserStateRepository` previously bypassed the production repository's 1,000,000-character import ceiling and top-level JSON/string-key validation.

Both repositories now use the same `_decodeUserState` path.

Regression coverage verifies the memory repository rejects oversized backup content too.

### Reset write-order race

Reset is serialized behind pending state saves so an older queued save cannot repopulate state after reset.

The reset operation clears storage and persists a clean baseline after pending writes complete.

### Reset failure UX

A storage reset failure previously only reached logging and could also allow an uncaught Future path from Settings.

The controller now exposes a safe warning message through the existing warning banner, and Settings does not show the success Snackbar when reset fails.

A regression test covers the safe warning path.

### Recent-history validation

Recent conversion persistence now rejects:

- unknown unit IDs;
- cross-category source/target pairs;
- blank input;
- oversized input.

Imported recent history also rejects whitespace-only input.

Valid locale-formatted original input text is retained instead of being forced through a non-locale parser at persistence time.

### Locale grouping was not genuinely locale-aware

Displayed plain-decimal grouping previously always split the integer part into groups of three.

The formatter now derives primary/secondary grouping sizes from the locale decimal pattern while keeping the value as an exact decimal string.

Regression coverage includes:

- `en_US` Western grouping;
- `en_IN` Indian grouping;
- `de_DE` localized grouping/decimal parsing.

No binary floating-point conversion was introduced to implement grouping.

## Repository integrity and release hardening completed

### Dependabot

`.github/dependabot.yml` schedules weekly dependency update discovery for:

- Cargo;
- Flutter/Dart pub packages;
- GitHub Actions.

### Repository validators

The dependency-free Python validator suite covers:

- exhaustive `git ls-files` versus `docs/repository-inventory.md` parity;
- repository-local Markdown targets;
- Cargo/Flutter/About version parity;
- changelog coverage for the current version;
- Cargo minimum-Rust-version versus setup-documentation parity;
- local state schema versus data-format documentation;
- bridge fixture protocol versus bridge-protocol documentation;
- critical repository file presence;
- tracked secret/signing/build/generated-file hygiene;
- exact `v<workspace-version>` release tag validation.

Validator helper/tag behavior has standard-library `unittest` regression coverage.

### Verification scripts

`scripts/verify.sh` and `scripts/verify.ps1` run:

1. Python validator regression tests;
2. exhaustive repository inventory validation;
3. Markdown link validation;
4. release/toolchain/schema/protocol consistency validation;
5. repository hygiene validation;
6. Rust formatting;
7. Rust Clippy with warnings denied;
8. Rust workspace tests;
9. Flutter dependency resolution;
10. Flutter localization generation;
11. Dart formatting;
12. Flutter analysis with fatal infos/warnings;
13. Flutter tests.

### Dart formatting policy

The repository keeps strict analyzer/lint rules and now declares an explicit 120-column formatter page width in `analysis_options.yaml` to make formatting behavior project-wide and deterministic.

### CI

Main CI contains a dedicated repository-integrity job plus Rust and Flutter source-quality jobs.

### Release workflow

The release workflow:

- runs validator tests;
- runs inventory/link/release/hygiene checks;
- rejects a mismatched tag;
- reruns Rust formatting/Clippy/tests;
- reruns Flutter dependency/localization/format/analysis/tests;
- requires a clean Rust package tree;
- packages Rust source crate and Flutter source archive;
- creates SHA-256 checksums;
- uploads verification artifacts;
- creates a GitHub release only from a real tag ref.

Source packaging is not native binary verification.

## Generated platform smoke matrix

The generated-scaffold compatibility workflow currently defines jobs for:

- Web release build on Ubuntu;
- Android debug APK on Ubuntu;
- Linux debug desktop build on Ubuntu;
- Windows debug desktop build on Windows;
- macOS debug desktop build on macOS;
- iOS simulator debug build on macOS.

Each job generates temporary Flutter platform scaffolding in the runner.

These checks are preliminary source/toolchain compatibility evidence only. They do not replace reviewed/committed native platform projects or release-candidate testing.

## Documentation state

Documentation currently covers:

- public project status/features/platform targets;
- architecture and ADRs;
- unit model;
- bridge direction/protocol/parity;
- local state data format/migration/import/reset behavior;
- setup prerequisites including Python and Rust 1.82 minimum;
- development workflow;
- testing/regression strategy;
- performance policy;
- accessibility requirements;
- localization;
- keyboard shortcuts;
- diagnostics;
- dependencies/Dependabot;
- platform support terminology;
- native platform completion requirements;
- generated platform-smoke evidence boundary;
- security policy and threat model;
- release procedure/checklist;
- GitHub repository maintenance;
- troubleshooting;
- exhaustive repository inventory;
- changelog and roadmap;
- this continuation handoff.

## Verification status — do not overclaim

### Repository inspection

The live `main` branch was repeatedly read through the authenticated GitHub integration during the final audit before source/documentation changes were written.

### Local execution limitation

The available execution environment has Git and Python, but does not provide the Rust/Cargo, Flutter, Dart, or native-platform toolchains required for the complete project verification.

Direct cloning from the execution container was also unavailable because external DNS/network access from that container was not available.

Therefore this continuation does **not** claim successful local output for:

- `cargo fmt`;
- `cargo clippy`;
- Rust tests;
- Flutter localization generation;
- Dart formatting;
- Flutter analysis;
- Flutter tests;
- Android/Web/Linux/Windows/macOS/iOS builds.

### GitHub Actions evidence

The GitHub combined-status lookup for the latest inspected pre-handoff commit returned no status contexts. A green final CI matrix has therefore not been established from this continuation.

Do not convert roadmap/checklist items to passed merely because the workflow definitions exist.

## Current blockers before a real 2.0.12 native release

1. **Run/review final CI** — repository integrity, Rust, Flutter, security/dependency, and generated-platform workflows must execute successfully on the final candidate commit, with every real failure fixed.
2. **Production Rust↔Flutter bridge** — implement generated native bindings and package/load the Rust core on native targets where Rust authority is claimed.
3. **Reviewed native platform projects** — generate, review, commit, and maintain Android/Windows/Linux/macOS/Web/iOS projects deliberately rather than relying on temporary CI scaffolds.
4. **Native integration/E2E** — execute primary offline conversion, persistence, backup/import, restart, custom-unit, history, and clipboard journeys against committed native projects.
5. **Accessibility manual review** — screen reader, keyboard/focus, large text, contrast, reduced-motion, and touch-target checks.
6. **Performance evidence** — record search/batch/native profiling baselines on documented hardware where release decisions require them.
7. **Real release media/assets** — icon/splash/platform assets and screenshots/demo media from verified builds.
8. **Native packaging/signing/store verification** — installers/bundles/signing/notarization/store requirements without committing credentials.
9. **Clean-clone/release-candidate verification** — run the full release checklist and smoke-test downloaded artifacts.
10. **Tag only after evidence exists** — validate `v2.0.12` with `scripts/check_release_tag.py` and create the tag only for the exact audited release commit.

## Exact next priority if another continuation is needed

Use this order:

1. Inspect GitHub Actions for the newest commit and fix all actual failures.
2. Run `scripts/verify.sh` or `scripts/verify.ps1` on a machine with the complete Rust/Flutter/Dart toolchain.
3. Address any formatter/Clippy/analyzer/test failures found by real execution.
4. Implement the production Rust↔Flutter generated binding layer against `docs/bridge-protocol.md`.
5. Generate/review/commit native projects one target at a time and update `docs/repository-inventory.md` in the same changes.
6. Switch target CI jobs from temporary generated scaffolds to committed project builds as each platform project becomes authoritative.
7. Add native integration/E2E tests.
8. Perform accessibility/performance/manual platform verification.
9. Produce real artwork/screenshots and native packages from verified builds.
10. Complete `docs/release-checklist.md` and only then tag `v2.0.12`.

## Commit identity note

Requested local Git commit email: `sanskarin@outlook.in`.

The connected GitHub contents/write API used in these sessions does not expose a per-write `author.email`/`committer.email` field. Connector-created commit identity is controlled by the authenticated GitHub integration.

Contributor/setup guidance keeps the requested local identity:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

Do not claim connector-created commits used a configurable email when the connector did not expose that option.

## Recent meaningful 2.0.12 commits

The final audit intentionally used many small, focused commits. Recent examples include:

- `d6aa4097` — `release: bump Rust workspace to 2.0.12`
- `59cc3696` — `release: bump Flutter app to 2.0.12`
- `c0997473` — `release: show version 2.0.12 in About`
- `941b1a9e` — `docs: publish 2.0.12 changelog snapshot`
- `466153da` — `docs: retarget roadmap release milestone to 2.0.12`
- `2fb8dca8` — `docs: align release guide with version 2.0.12`
- `26bf25cb` — `fix: use conversion output in Rust parity test`
- `b39a440e` — `style: normalize Rust notation tests for rustfmt`
- `f05a65e3` — `style: preserve auditable Rust catalog table`
- `c37c5314` — `fix: align Rust rounding identifiers with bridge protocol`
- `a8aa11d9` — `test: lock Rust bridge rounding identifiers`
- `156005aa` — `build: align Rust MSRV with used standard library APIs`
- `5e6d00ed` — `fix: enforce canonical native bridge payloads`
- `430d7e2f` — `test: cover native bridge payload validation`
- `7e0b7443` — `feat: add explicit Rust custom alias count error`
- `b486996e` — `fix: bound Rust custom aliases and normalize formatting`
- `74fa7863` — `test: cover Rust custom alias count limit`
- `382e9058` — `style: normalize Rust custom unit regression test`
- `3499ee9d` — `test: consume shared bridge fixture from Rust`
- `7df22406` — `test: expand shared bridge rounding parity vectors`
- `685648a7` — `ci: require clean Rust packaging for releases`
- `564492a0` — `docs: document Rust 1.82 minimum for 2.0.12`
- `f16978ac` — `style: define repository wide Dart formatter width`
- `4e4089c2` — `fix: surface local reset persistence failures safely`
- `25cf000a` — `test: cover safe local reset failure warning`
- `b2acef9d` — `docs: record final 2.0.12 hardening fixes`
- `e1b57359` — `build: validate documented Rust minimum version`
- `8436d086` — `fix: avoid false success after local reset failure`
- `8e6dd01a` — `docs: publish UnitFlow 2.0.12 source status`
- `72b3bdae` — `docs: update 2.0.12 verification and parity strategy`
- `6100b37e` — `fix: honor locale specific decimal grouping patterns`
- `c45efd64` — `test: cover locale specific exact decimal grouping`
- `54ab7d0e` — `fix: keep locale grouping indices strongly typed`

Earlier final-hardening commits also added Dependabot, repository validators/tests, exhaustive inventory enforcement, backup-import consistency, reset ordering, recent-history validation, security/release hardening, and the six-platform generated smoke matrix.

## Handoff rule

Before changing this file in another continuation:

1. inspect the latest repository state rather than trusting this handoff blindly;
2. prefer actual compiler/test/workflow evidence over assumptions;
3. keep `2.0.12` version declarations synchronized unless the user explicitly requests another version;
4. update this file after meaningful new work;
5. keep commits focused and descriptive.
