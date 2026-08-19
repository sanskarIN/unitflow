# UnitFlow — Development Handoff

This file is the primary continuation checkpoint for future UnitFlow development sessions. It intentionally contains the detailed engineering handoff so chat responses can remain short.

Last updated: **2026-08-19**

Repository: `https://github.com/sanskarIN/unitflow`

Target prerelease: **`0.1.0-alpha.1`**

## Current milestone

UnitFlow is no longer in repository bootstrap. The repository now has a substantial Rust conversion core, Flutter product source, local-first persistence, deterministic Dart compatibility engine, tests, localization, repository governance, CI/security/release automation, generated six-platform compatibility smoke builds, and deep engineering documentation.

The current stage is **alpha release hardening / native integration readiness**.

Do **not** describe the project as release-complete yet. The major remaining blockers are reviewed native Flutter platform projects, the production Rust↔Flutter bridge and generated bindings/native packaging, full clean CI/native execution evidence, integration/E2E coverage, accessibility/performance manual evidence, and release-candidate verification.

## Product implementation completed

### Rust domain core

The `unitflow_core` Rust crate includes:

- validated unit/category models and stable identifiers;
- exact base-10 decimal conversion with `rust_decimal`;
- multiplicative and affine conversions;
- explicit rounding policies;
- single and batch conversion services;
- searchable catalog with names/symbols/aliases;
- validated custom affine units;
- plain/scientific/engineering notation support;
- offline educational category metadata;
- typed public errors;
- catalog/conversion/custom-unit/education/notation/bridge parity tests;
- catalog-wide invariant coverage;
- dependency-free conversion benchmark example.

Rust remains the intended authoritative native domain core. Native Flutter clients must not claim that authority is active until the production bridge is integrated and packaged.

### Flutter/Dart application

The Flutter application source includes:

- adaptive mobile/desktop application shell;
- Convert, Batch, Library, History, and Settings destinations;
- exact deterministic Dart decimal implementation during bridge transition;
- locale-aware decimal parsing/display architecture;
- source/target selection and swap;
- result formatting with persisted notation, precision, grouping, and rounding settings;
- searchable unit library;
- favorites and pinned conversion pairs;
- local recent-conversion history with restore/clear behavior;
- validated custom-unit editor;
- batch conversion table;
- CSV, TSV, and JSON batch export/copy behavior;
- onboarding;
- theme settings;
- local state backup/import/reset workflows;
- About/project/support surfaces;
- generated Flutter localization resources with English source ARB;
- keyboard/adaptive navigation basics;
- structured diagnostic logging with sensitive-key redaction.

### Local persistence and backup hardening

The versioned state layer is currently schema version `2`, with explicit migration support from schema version `1`.

Important current guarantees:

- imports are rejected if empty or larger than 1,000,000 characters before JSON decoding;
- both production Shared Preferences and in-memory test repositories use the same shared import decoder;
- top-level JSON must be an object with string keys;
- favorite/pin/recent/custom-unit collection counts are bounded;
- persisted identifiers and user-controlled fields have explicit bounds;
- custom units are fully validated before activation;
- imported favorites, pins, and recents must reference valid units/categories before active state replacement;
- rejected imports do not partially replace active state;
- recent-history input must contain non-whitespace content and be at most 1,024 characters;
- valid locale-formatted original history text such as `1,5` is preserved rather than incorrectly forcing dot-decimal parsing at persistence time;
- custom-unit removal also removes dangling favorites, pins, and recents;
- asynchronous state saves are serialized;
- local reset is serialized behind pending writes, then clears storage and persists a clean baseline, preventing an earlier queued save from repopulating reset data.

## Concrete bugs fixed in the final hardening continuation

### Reset ordering race

An existing regression test expected a pending save to complete before reset, followed by repository clear and a persisted clean baseline. `AppController.resetLocalData()` previously cleared storage outside `_writeChain`, so an older queued save could write stale state after reset.

The reset path now:

1. switches visible in-memory state immediately to a clean baseline;
2. enqueues behind prior writes;
3. clears repository storage;
4. saves the clean baseline;
5. preserves write-chain continuity if persistence reports an error.

### Recent-history reference validation

`recordRecent()` previously allowed values that its tests and persisted-state validation considered invalid. It now rejects:

- unknown source unit IDs;
- unknown target unit IDs;
- cross-category pairs;
- blank input;
- input longer than 1,024 characters.

The fix deliberately preserves locale-formatted original text instead of re-parsing with the non-locale exact-decimal parser.

### Backup repository inconsistency

The in-memory repository used by tests previously bypassed production import-size and top-level JSON validation. Both repository implementations now use `_decodeUserState`, ensuring test success cannot rely on a weaker import path.

### Imported blank history

Imported recent conversions previously accepted whitespace-only `input`. The persisted model now rejects blank history text and a regression test covers it.

### Generated platform smoke documentation mismatch

The documentation described six generated platform smoke jobs while the workflow actually had only Web and Android. The workflow now implements all documented generated-scaffold jobs:

- Web release build on Ubuntu;
- Android debug APK on Ubuntu with Java 17;
- Linux debug desktop build on Ubuntu with required GTK/CMake/Ninja dependencies;
- Windows debug desktop build on `windows-latest`;
- macOS debug desktop build on `macos-latest`;
- iOS debug simulator build on `macos-latest`.

These jobs generate temporary platform scaffolds in CI. They are compatibility probes, **not** reviewed native release projects.

## Repository quality/security automation completed

### Dependabot

`.github/dependabot.yml` now schedules weekly update discovery for:

- Cargo workspace dependencies;
- Flutter/Dart dependencies in `apps/unitflow_app`;
- GitHub Actions.

Dependency PRs are explicitly treated as review proposals, not automatic approvals.

### Repository validators

The repository now contains dependency-free Python validators for:

- repository-local Markdown targets;
- package/version/changelog/schema/bridge-protocol consistency;
- exact release tag versus Cargo workspace version;
- critical repository/documentation file presence and tracked-file hygiene;
- exhaustive tracked-file versus documentation-inventory parity.

Standard-library `unittest` regression coverage validates important helper/parser/tag/inventory behavior.

### Exhaustive repository inventory

`docs/repository-inventory.md` documents **every tracked first-party file** and its role.

`scripts/check_repository_inventory.py` compares those machine-readable inventory entries to `git ls-files` and fails on:

- a tracked file missing from the inventory;
- a stale inventory entry for a non-tracked file;
- duplicate inventory entries.

This gate is now part of local Bash/PowerShell verification, main CI, and release verification. Any future tracked-file addition/removal must update the inventory in the same change.

### Repository hygiene

`scripts/check_repository_hygiene.py` now requires the complete critical project/governance/documentation/validator set and rejects commonly accidental tracked artifacts, including:

- `.env` files and unexpected `.env.*` variants except `.env.example`;
- common signing/provisioning file suffixes;
- target/build directories;
- `.dart_tool` output;
- generated localization output.

### Release tag guard

`scripts/check_release_tag.py` reads the root Cargo workspace version and requires the release tag to equal exactly `v<version>`.

The release workflow executes this guard before packaging on tag-triggered runs. A tag such as `v9.9.9` cannot package the current `0.1.0-alpha.1` source as if it were that version.

### Verification scripts

`scripts/verify.sh` and `scripts/verify.ps1` now run, in order:

1. repository-validator regression tests;
2. exhaustive repository inventory validation;
3. Markdown-link validation;
4. release/schema/protocol consistency validation;
5. repository hygiene validation;
6. Rust formatting;
7. Rust Clippy with warnings denied;
8. Rust workspace tests;
9. Flutter dependency resolution;
10. Flutter localization generation;
11. Dart formatting;
12. Flutter analysis with fatal infos/warnings;
13. Flutter tests.

The PowerShell script supports `python3`, `python`, or the Windows `py -3` launcher.

### CI

`.github/workflows/ci.yml` now has a dedicated `Repository integrity` job in addition to Rust and Flutter quality jobs. It runs validator tests plus inventory, Markdown, release-consistency, and hygiene checks.

### Release workflow

The release workflow now:

- tests the repository validators;
- verifies inventory/Markdown/release consistency/hygiene;
- rejects a mismatched tag;
- reruns Rust formatting/Clippy/tests;
- resolves/generates/analyzes/tests Flutter source;
- packages the Rust source crate;
- creates a deterministic Flutter source archive;
- emits SHA-256 checksums;
- uploads verification artifacts;
- creates a GitHub release only from an actual tag ref.

Source artifacts do not substitute for native installers/bundles.

## Documentation completed/refreshed

The repository documentation now covers and cross-links:

- architecture;
- unit model;
- Rust↔Flutter bridge direction;
- bridge protocol/parity fixture;
- local persisted data format/migrations/import limits/reset ordering;
- setup for Git/Python/Rust/Flutter/native toolchains;
- development conventions;
- testing and regression strategy;
- performance measurement policy;
- accessibility requirements;
- localization workflow;
- keyboard shortcuts;
- diagnostics/logging;
- dependency/Dependabot maintenance;
- platform target/support terminology;
- reviewed native platform completion requirements;
- generated platform smoke-build evidence boundaries;
- threat model;
- security policy;
- release procedure;
- release checklist;
- GitHub repository maintenance/settings;
- troubleshooting;
- four architecture decision records;
- exhaustive tracked-file repository inventory.

`README.md`, `CHANGELOG.md`, `ROADMAP.md`, `SECURITY.md`, and this handoff have been updated to match the implemented alpha-hardening state and avoid claiming unverified native release status.

## Verification status — do not overclaim

### What was verified by repository inspection

During this continuation, the connected GitHub repository was repeatedly inspected before edits. The latest source structure, workflows, tests, persistence code, roadmap, changelog, and documentation were read directly from the repository before the corresponding fixes were made.

### Toolchain limitation in this execution environment

The execution environment used for this continuation does **not** provide the project Rust/Flutter/Dart/native toolchains needed to run the full repository verification locally. Therefore this handoff does **not** claim that:

- `cargo fmt` passed;
- `cargo clippy` passed;
- Rust tests passed;
- Flutter localization generation passed;
- Dart formatting passed;
- Flutter analysis passed;
- Flutter tests passed;
- any native target build passed.

Do not change those statements to “passed” until actual output exists from a suitable environment or GitHub Actions.

### GitHub Actions status seen in this continuation

A workflow-run lookup for the then-latest inspected commit returned no runs yet. Therefore remote green status was **not** established from this session. The workflow definitions were strengthened, but definitions are not the same as successful execution evidence.

The next continuation should inspect the latest commit's workflow runs and fix every real failure rather than marking the roadmap complete from source inspection alone.

## Current release blockers

The remaining blockers are intentional and real:

1. **Production Rust↔Flutter bridge** — implement/generate/review native bindings and make native Flutter builds load the Rust domain core where Rust authority is claimed.
2. **Reviewed native platform projects** — generate/update, review, and commit Android, Windows, Linux, macOS, Web, and iOS projects as appropriate; generated CI scaffolds are not enough.
3. **Actual full CI evidence** — run/review repository integrity, Rust, Flutter, security/dependency, and generated platform workflows on the final candidate commit and fix every discovered issue.
4. **Native integration/E2E** — exercise persisted primary journeys on committed platform projects.
5. **Accessibility manual review** — screen readers, large text, reduced motion, contrast, focus/keyboard, touch targets.
6. **Performance evidence** — record catalog-search/batch/native profiling baselines on documented hardware where release decisions require them.
7. **Release assets/media** — real screenshots/demo media, icon/splash/native assets from verified builds.
8. **Native packaging/signing/store evidence** — validate platform-specific bundle/install/sign/notarize/store requirements without committing credentials.
9. **Release-candidate checks** — clean-clone verification, downloaded-artifact smoke testing, final release checklist, and tag only after blockers are satisfied.

## Exact next development priority

If development continues toward `0.1.0-alpha.1`, use this order:

1. Inspect the latest GitHub Actions runs and address all repository-integrity/Rust/Flutter/platform-smoke failures.
2. Run the complete `scripts/verify.sh` or `scripts/verify.ps1` from a machine with Git, Python 3, Rust, Flutter, and Dart.
3. Implement the production Rust↔Flutter generated bridge/binding workflow using the documented decimal-string protocol and parity fixture.
4. Generate/review/commit native platform projects deliberately, updating `docs/repository-inventory.md` in the same commits.
5. Change platform CI from temporary generated scaffolds to building committed native projects target-by-target as each reviewed project lands.
6. Add native integration/E2E coverage for the primary offline conversion/persistence/backup journeys.
7. Perform accessibility/performance/platform-manual audits and record evidence.
8. Add real app artwork/screenshots only from verified builds.
9. Run the final release checklist.
10. Validate the intended tag with `python3 scripts/check_release_tag.py v0.1.0-alpha.1` and tag only the exact audited candidate commit.

## Commit identity note

Requested local Git commit email: `sanskarin@outlook.in`.

The connected GitHub contents/write API used here does not expose a per-write `author.email` or `committer.email` parameter. Connector-created commit identity is controlled by the authenticated GitHub integration. Contributor/setup documentation therefore includes the requested local configuration:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

Do not falsely claim connector-created commits used a configurable email when the connector did not provide that field.

## Meaningful commits from this final hardening continuation

The continuation intentionally used many small meaningful commits. Important commits include:

- `c9fdd487` — `ci: enable automated dependency updates`
- `779a5068` — `security: extend repository hygiene coverage`
- `21850a5d` — `build: include repository integrity in bash verification`
- `703bc936` — `build: include repository integrity in PowerShell verification`
- `3341ba99` — `ci: enforce repository integrity checks`
- `bfd65d38` — `build: validate release tags against package version`
- `30b82d62` — `security: require release tag validator`
- `a3c3724b` — `ci: harden release validation before packaging`
- `30d7ad06` — `security: detect nested environment and signing files`
- `85c5a9e2` — `test: cover repository validation helpers`
- `884e8bf4` — `test: keep validator tests version agnostic`
- `80b147e0` — `test: run repository validator tests in CI`
- `1959c516` — `test: include validator tests in bash verification`
- `bffb6090` — `test: include validator tests in PowerShell verification`
- `13dbed23` — `test: run validator tests before release packaging`
- `5638e9d1` — `fix: keep backup import validation consistent`
- `c8b680bd` — `test: cover memory backup size limit`
- `6f483792` — `security: require repository validator regression tests`
- `968dcf1e` — `docs: complete documentation navigation for final validators`
- `c7558d4e` — `docs: document Python and complete verification prerequisites`
- `2c322236` — `docs: expand testing strategy with repository integrity gates`
- `da144583` — `docs: harden evidence based release procedure`
- `e109e5ce` — `docs: make release checklist match final quality gates`
- `a87cdb6b` — `docs: document active Dependabot maintenance policy`
- `2287aa7d` — `build: make PowerShell validator invocation explicit`
- `3156f3f6` — `fix: serialize local reset with pending persistence`
- `a6083bc2` — `fix: validate recent conversions before persistence`
- `99c9e577` — `fix: preserve locale formatted recent inputs`
- `741b042b` — `test: preserve localized recent conversion text`
- `b8e23c05` — `ci: complete generated platform smoke matrix`
- `5df5846e` — `docs: align README with final automation and quality gates`
- `1d7f4f8f` — `docs: update GitHub maintenance for final CI gates`
- `b32f7302` — `docs: align development workflow with hardened repository`
- `268a6e23` — `fix: reject empty recent history inputs`
- `d141c789` — `test: reject blank imported recent history`
- `4d172ea2` — `docs: document hardened backup and history validation`
- `582c6a9f` — `docs: refresh roadmap after final hardening audit`
- `cb8c43af` — `docs: record final hardening changes in changelog`
- `dbb3226a` — `docs: add exhaustive tracked file inventory`
- `affbfc45` — `docs: enforce exhaustive repository inventory`
- `4afbbf99` — `test: cover repository inventory validator`
- `b5aeba21` — `security: require complete project documentation set`
- `da9245b8` — `build: verify exhaustive repository inventory`
- `181e7f7b` — `build: verify inventory in PowerShell quality gate`
- `52df1139` — `ci: enforce complete repository documentation inventory`
- `24f448b4` — `ci: verify repository inventory before release`
- `af894f9b` — `docs: index every engineering documentation guide`
- `cafb87eb` — `docs: align security policy with hardened import and release model`
- `eb0aea41` — `docs: update threat model for persistence and release hardening`
- `a72acf35` — `docs: include inventory parity in testing strategy`
- `da33d80c` — `docs: require inventory and persistence regressions before release`
- `731fc23e` — `docs: add inventory validation to setup workflow`
- `fca2fc21` — `docs: record exhaustive documentation inventory gate`

## Release notes draft

### `0.1.0-alpha.1` — planned, not tagged yet

UnitFlow's first development preview is intended to include the exact-decimal Rust conversion core, adaptive Flutter interface, deterministic Dart compatibility engine, broad offline unit catalog, favorites/pins/history/custom units, batch export, versioned local backup/import, localization-ready UI, repository security/quality automation, and source release tooling.

Do not publish this prerelease until the current release blockers above are cleared or the release notes explicitly narrow platform/support claims to match verified evidence.

## Handoff rule

Future work should keep this file current after meaningful milestones. When a tracked file is added/removed, update `docs/repository-inventory.md` in the same change. When a confirmed defect is fixed, add regression coverage where practical. Never mark a roadmap/release check complete without execution evidence that actually satisfies it.
