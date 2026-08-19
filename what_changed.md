# UnitFlow — Development Handoff

This is the primary continuation checkpoint for future UnitFlow development sessions. Detailed engineering notes live here so chat replies can remain short.

Last updated: **2026-08-19**

Repository: `https://github.com/sanskarIN/unitflow`

Branch: **`main`**

Current source version: **`2.0.12`**

Flutter build number: **`12`**

Latest inspected pre-handoff commit: **`89fb99647ea8209a4336dcd7202d55a86507f9a2`**

## Release state

UnitFlow source is aligned to `2.0.12` across Cargo, Flutter metadata, About, README, changelog, roadmap, release/testing/setup documentation, release validators, and this handoff.

**Do not call `2.0.12` a verified native release yet.** No `v2.0.12` tag was created in this continuation. The version number identifies the current source target; native release evidence remains blocked by the items later in this file.

## Main implementation already present

### Rust core

`crates/unitflow_core` includes:

- validated category/unit models and stable IDs;
- exact decimal conversions using `rust_decimal`;
- multiplicative and affine conversions;
- explicit rounding modes;
- single and batch conversion;
- searchable built-in catalog;
- validated custom affine units;
- notation formatting;
- educational metadata;
- typed public errors;
- unit/catalog/conversion/custom-unit/notation/education/invariant/bridge-parity tests;
- dependency-free conversion benchmark.

Rust remains the intended native domain authority, but native Flutter builds must not claim Rust authority until the production generated bridge is integrated and packaged.

### Flutter/Dart application

`apps/unitflow_app` includes:

- adaptive application shell;
- Convert, Batch, Library, History, and Settings workspaces;
- deterministic exact-decimal Dart compatibility engine;
- locale-aware decimal parsing/display;
- favorites, pinned pairs, recents, custom units, settings, onboarding;
- local backup/import/reset;
- CSV/TSV/JSON batch export;
- generated localization architecture with English ARB source;
- keyboard/adaptive navigation;
- structured safe diagnostics;
- About/support/project links;
- versioned local persistence with schema-1 → schema-2 migration.

### Repository engineering

The repository includes:

- main CI for repository integrity, Rust, and Flutter;
- CodeQL;
- dependency review;
- Dependabot for Cargo, pub, and GitHub Actions;
- generated Android/Web/Linux/Windows/macOS/iOS smoke builds;
- release workflow with checksums;
- exact release-tag/version guard;
- exhaustive tracked-file inventory validation;
- Markdown link validation;
- release/schema/protocol/Rust-minimum consistency validation;
- repository hygiene validation;
- Bash and PowerShell full-verification entry points;
- deep setup/testing/security/release/platform/maintenance documentation.

## `2.0.12` alignment completed

The requested source version is synchronized in:

- root `Cargo.toml` → `2.0.12`;
- Flutter `pubspec.yaml` → `2.0.12+12`;
- About screen → `2.0.12`;
- `README.md` source-status section;
- `CHANGELOG.md`;
- `ROADMAP.md`;
- `docs/release.md`;
- `docs/testing.md`;
- `docs/setup.md`;
- `docs/repository-inventory.md`;
- this file.

`scripts/check_release_consistency.py` verifies Cargo/Flutter/About/changelog/schema/bridge-protocol/Rust-minimum documentation parity so future edits cannot silently drift.

## Defects fixed during the final 2.0.12 audit

### Rust bridge parity compile failure

`crates/unitflow_core/tests/bridge_parity.rs` used `result.value`, but `ConversionResult` exposes the converted result as `result.output`.

Fixed to use `result.output`.

### Shared fixture drift risk

Dart consumed `fixtures/bridge_parity_v1.json`, while Rust previously duplicated equivalent vectors manually.

Rust now deserializes the same versioned fixture directly.

The fixture now exercises representative length, affine-temperature, time, and binary-data conversions plus every supported rounding mode:

- `nearestEven`;
- `halfAwayFromZero`;
- `towardZero`;
- `awayFromZero`;
- `floor`;
- `ceiling`.

### Rust bridge rounding identifiers

Rust previously serialized `RoundMode` with snake_case identifiers while the documented bridge/Dart contract uses camelCase.

Rust now uses the documented camelCase values. A Serde regression test locks the contract.

### Rust minimum version mismatch

The core uses `Option::is_none_or`, while the workspace previously declared Rust `1.80`.

The workspace minimum is now **Rust `1.82`**. README/setup documentation is aligned and the consistency validator checks the documented minimum against Cargo metadata.

### Rust formatter/package hardening

- notation tests normalized for `rustfmt`;
- custom-unit tests normalized for `rustfmt`;
- dense catalog constant table deliberately protected with `#[rustfmt::skip]` while normal module logic remains formatted;
- release workflow no longer uses `cargo package --allow-dirty`.

### Rust custom-unit alias ceiling

Dart already bounded custom aliases at 32 entries; Rust did not.

Rust now has a typed `TooManyAliases` error and a 32-entry ceiling with regression coverage.

### Native bridge DTO validation

Flutter native-bridge request/response DTOs now validate:

- canonical exact-decimal text;
- bounded decimal text;
- stable lowercase/digit/underscore/hyphen unit IDs;
- 1–64-character unit IDs;
- decimal precision 0–28.

Tests cover malformed request/response payloads, invalid IDs, noncanonical decimals, invalid precision, and safe failure stringification.

### Backup import inconsistency

Production Shared Preferences imports and `MemoryUserStateRepository` imports previously did not enforce the same outer bounds.

Both now share `_decodeUserState`, including:

- 1,000,000-character maximum;
- top-level JSON-object requirement;
- string-key requirement;
- normal schema/model validation afterward.

Regression coverage verifies the memory adapter cannot bypass the production ceiling.

### Persistence reset ordering

Reset is serialized behind pending writes so an earlier queued save cannot repopulate state after a reset.

The reset path:

1. switches visible state to a clean baseline;
2. waits behind pending writes;
3. clears repository storage;
4. persists the baseline.

### Reset failure UX

Reset persistence failures now:

- produce the existing safe warning-banner state;
- avoid exposing raw storage exception details;
- do not display the Settings success Snackbar after failure.

Regression coverage exercises the warning path.

### Recent-history validation

Recent persistence rejects:

- unknown source/target IDs;
- cross-category pairs;
- blank input;
- oversized input.

Imported recents reject whitespace-only input.

Valid locale-formatted original input text is preserved rather than being forced through a non-locale persistence parser.

### Locale-aware decimal grouping

Plain-decimal display previously always grouped the integer portion in groups of three.

The formatter now derives primary and secondary grouping sizes from the locale decimal pattern while preserving exact decimal strings.

Regression coverage includes:

- `en_US` Western grouping;
- `en_IN` Indian grouping;
- `de_DE` localized separators/parsing.

No binary floating-point conversion was added for grouping.

## Repository automation hardening completed

### Dependabot

Weekly update discovery is configured for:

- Cargo;
- Flutter/Dart pub dependencies;
- GitHub Actions.

### Repository validators

Dependency-free Python checks cover:

- exact tracked-file inventory parity;
- local Markdown targets;
- Cargo/Flutter/About version alignment;
- changelog coverage;
- Cargo minimum Rust versus setup docs;
- persisted schema versus data-format docs;
- bridge fixture protocol versus bridge-protocol docs;
- critical project/documentation/config files;
- tracked `.env`, signing, generated, and build artifacts;
- exact `v<workspace-version>` release tags.

The validator helpers and release-tag logic have standard-library regression tests.

### Verification entry points

`scripts/verify.sh` and `scripts/verify.ps1` run:

1. validator tests;
2. repository inventory check;
3. Markdown links;
4. release/toolchain/schema/protocol consistency;
5. repository hygiene;
6. Rust formatting;
7. Rust Clippy with warnings denied;
8. Rust tests;
9. Flutter dependency resolution;
10. localization generation;
11. Dart formatting;
12. Flutter analysis with fatal infos/warnings;
13. Flutter tests.

### CI and release

Main CI has separate repository-integrity, Rust, and Flutter quality jobs.

Release automation:

- reruns validator tests and repository checks;
- verifies exact tag/version equality;
- reruns Rust and Flutter source gates;
- requires clean Rust packaging;
- packages Rust and Flutter source artifacts;
- writes SHA-256 checksums;
- creates a GitHub Release only on an actual tag ref.

Source packages are not native installers/bundles.

### Generated platform smoke matrix

Temporary generated Flutter scaffolds are built for:

- Web release;
- Android debug APK;
- Linux debug desktop;
- Windows debug desktop;
- macOS debug desktop;
- iOS simulator debug.

These are source/toolchain compatibility probes, not reviewed native release projects.

## Documentation state

The repository documentation now covers:

- public `2.0.12` source status;
- architecture and ADRs;
- unit model;
- bridge direction/protocol/shared parity fixture;
- local schema/migration/import/reset behavior;
- setup prerequisites including Python and Rust 1.82+;
- contributor workflow;
- repository/Rust/Flutter/bridge/native testing;
- performance policy;
- accessibility requirements;
- localization and keyboard behavior;
- diagnostics;
- dependency maintenance;
- platform support/native completion/smoke evidence boundaries;
- security and threat model;
- release procedure/checklist;
- GitHub maintenance;
- troubleshooting;
- exhaustive tracked-file inventory;
- changelog/roadmap;
- this handoff.

`docs/repository-inventory.md` was refreshed after the 2.0.12 audit so its file-role descriptions no longer refer to the old planned-alpha state.

## Verification status — do not overclaim

### Repository inspection

The live `main` branch was repeatedly read through the authenticated GitHub integration before fixes were written.

### Local execution limitation

The available execution environment has Git/Python but does **not** provide Cargo/Rust, Flutter, Dart, or native platform toolchains required for complete project verification.

The container also could not clone GitHub directly because external DNS/network access was unavailable from that environment.

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

Combined-status lookup for the latest inspected pre-handoff commit `89fb99647ea8209a4336dcd7202d55a86507f9a2` returned **no status contexts**.

A final green CI matrix is therefore **not proven** in this continuation. Workflow definitions are not execution evidence.

## Remaining blockers before a real `2.0.12` native release

1. Inspect/run final GitHub Actions and fix every actual repository/Rust/Flutter/platform failure.
2. Implement the production Rust↔Flutter generated bridge and package/load the Rust core on native targets where Rust authority is claimed.
3. Generate/review/commit native Android, Windows, Linux, macOS, Web, and iOS projects as appropriate.
4. Replace temporary generated-scaffold CI with committed-project builds target-by-target as native projects become authoritative.
5. Add native integration/E2E journeys for conversion, restart persistence, backup/import, custom units, history, and clipboard workflows.
6. Perform manual accessibility review: screen reader, focus/keyboard, large text, contrast, reduced motion, touch targets.
7. Record performance/search/batch/native profiling baselines on documented hardware where release decisions need evidence.
8. Create real icon/splash/platform assets and screenshots/demo media from verified builds.
9. Validate native packaging/signing/notarization/store requirements without committing credentials.
10. Perform clean-clone/release-candidate/downloaded-artifact verification.
11. Complete `docs/release-checklist.md`.
12. Only then validate/tag `v2.0.12` on the exact audited release commit.

## Exact next priority if another continuation is required

1. Inspect the newest GitHub Actions results.
2. Run `scripts/verify.sh` or `scripts/verify.ps1` on a machine with full Rust/Flutter/Dart toolchains.
3. Fix every real formatter/Clippy/analyzer/test failure found by execution.
4. Implement generated Rust↔Flutter native bindings against `docs/bridge-protocol.md`.
5. Commit reviewed platform projects one target at a time, updating `docs/repository-inventory.md` in the same commits.
6. Add native E2E/accessibility/performance evidence.
7. Generate real release media and native packages only from verified builds.
8. Complete the release checklist and tag `v2.0.12` only after evidence exists.

## Commit identity note

Requested local commit email: `sanskarin@outlook.in`.

The connected GitHub contents API does not expose a per-write `author.email`/`committer.email` field, so connector-created commit identity is controlled by the authenticated integration.

Local contributor guidance keeps the requested identity:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

Do not claim connector-created commits used a configurable email when the connector did not expose it.

## Recent meaningful 2.0.12 commits

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
- `ec8cb3b8` — `docs: replace handoff with UnitFlow 2.0.12 final audit state`
- `5313157c` — `docs: record locale grouping and reset UX fixes`
- `89fb9964` — `docs: refresh exhaustive inventory for 2.0.12`

Earlier final-hardening commits also added Dependabot, repository validator tests, inventory enforcement, backup-import consistency, reset ordering, recent-history validation, security/release hardening, and the six-target generated smoke matrix.

## Handoff rules

For any future continuation:

1. inspect live `main` first instead of trusting this file blindly;
2. prefer compiler/test/workflow evidence over assumptions;
3. keep `2.0.12` declarations synchronized unless the user explicitly asks for another version;
4. update this file after meaningful work;
5. keep commits focused and descriptive;
6. do not tag a release while the evidence blockers above remain open.
