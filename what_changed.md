# UnitFlow — Development Handoff

This file is the primary continuation checkpoint for future UnitFlow development sessions so chat responses can remain short while repository work remains fully traceable.

Last updated: **2026-08-20**

Repository: `https://github.com/sanskarIN/unitflow`

Branch: **`main`**

Current source version: **`2.0.12`**

Flutter build number: **`12`**

Latest inspected pre-handoff commit: **`c4866da2aa3fe5844caf5bd4eed30f87e9527b4b`** (`docs: record bridge negotiation hardening`)

## Current release state

UnitFlow remains an enforced six-target Flutter project for:

- Android;
- iOS;
- Web;
- Windows;
- Linux;
- macOS.

The repository has deterministic six-platform generation, all-or-nothing platform materialization automation, release-mode build jobs for all six targets, build artifact upload definitions, generated-platform inventory support, and repository validators that prevent the target matrix from silently drifting.

This continuation advanced the next major blocker: the Rust↔Flutter bridge contract. Rust and Flutter now share explicit startup protocol/capability metadata, fail-closed compatibility rules, actual single/batch source interfaces, stable bridge unit-ID bounds, a shared 256-target batch ceiling, and repository-level drift checks. The deterministic Dart fallback now uses the same batch ceiling so future engine selection does not change that behavior.

**Do not call `v2.0.12` a fully verified native/store release yet.** The latest inspected live `main` tree still does not contain the generated Android/iOS/Web/Windows/Linux/macOS project directories. Generated Rust↔Flutter bindings, actual runtime native-engine selection, native-library packaging/loading, generated-boundary parity execution, native E2E evidence, accessibility/performance review, signing/notarization, and final release-candidate verification remain open.

No `v2.0.12` tag was created.

## Work completed in this continuation

### 1. Rust startup capability negotiation

`crates/unitflow_core/src/bridge.rs` now exposes generator-friendly startup metadata through `BridgeInfo` and `BridgeService::info()`.

Current bridge protocol:

```text
protocolVersion = 1
backendId = rust-core
```

Current required capabilities:

```text
convert
batchConvert
canonicalDecimalText
```

The capability identifiers are exported as stable Rust constants and collected in `BRIDGE_CAPABILITIES`.

`crates/unitflow_core/src/lib.rs` re-exports the bridge negotiation contract for future generated binding code.

### 2. Flutter fail-closed startup negotiation

`apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart` now contains matching Flutter startup metadata and validation.

`NativeBridgeInfo.fromMap()` validates:

- positive bounded protocol version;
- stable bounded backend identifiers;
- bounded capability count;
- stable capability token syntax;
- duplicate capability rejection.

`NativeBridgeInfo.isCompatible` verifies protocol + required capabilities.

`NativeBridgeInfo.requireCompatible()` fails closed with stable safe failures:

```text
protocol_mismatch
capability_mismatch
```

A future generated bridge must pass this compatibility boundary before UnitFlow selects native conversion for a session.

### 3. Real batch bridge capability

An inconsistency was found during review: Flutter required the `batchConvert` capability but its `NativeConversionBridge` source interface exposed only single conversion.

That mismatch is fixed.

Flutter now has:

- `NativeBridgeBatchConversionRequest`;
- ordered `targetUnitIds` serialization;
- `NativeConversionBridge.batchConvert(...)`;
- shared precision/unit-ID validation;
- batch target-count validation.

The required `batchConvert` capability therefore corresponds to an actual source API instead of an aspirational flag.

### 4. Native bridge request hardening

Rust bridge requests now validate stable unit-ID syntax before conversion/catalog work.

The bridge accepts IDs containing only:

```text
[a-z0-9_-]
```

with a maximum length of 64 bytes and a non-empty requirement.

Malformed identifiers use the safe `unknown_unit` failure contract and are not echoed into bridge failure messages.

### 5. Shared 256-target batch ceiling

A bounded batch contract is now explicit across Rust, Flutter bridge DTOs, Flutter deterministic fallback, documentation, and repository verification.

Current limit:

```text
256 targets per batch request
```

Rust exposes:

```text
BRIDGE_MAX_BATCH_TARGETS = 256
```

Flutter bridge source exposes:

```text
nativeBridgeMaxBatchTargets = 256
```

Flutter deterministic conversion source exposes:

```text
maxBatchConversionTargets = 256
```

Oversized Rust bridge batches fail safely with:

```text
invalid_batch
```

The deterministic Dart fallback consumes at most 257 target entries before rejecting an oversized request, so an unbounded/lazy iterable is not fully materialized merely to discover that it violates the supported limit.

### 6. Deterministic fallback/native behavior parity

`ExactConversionEngine.batchConvert()` now shares the native batch ceiling.

This avoids a future runtime-selection inconsistency where the same oversized batch could succeed under the Dart fallback but fail after native Rust selection.

The fallback also validates decimal-place bounds before beginning batch work.

### 7. Rust bridge regression coverage

`crates/unitflow_core/tests/bridge_service.rs` now covers:

- protocol metadata;
- backend ID;
- capability metadata;
- camelCase startup serialization;
- canonical decimal-string conversion;
- malformed unit-ID rejection;
- unknown-unit safe-message behavior;
- category mismatch;
- invalid precision;
- ordered batch conversion;
- exact 256-target contract constant;
- oversized batch rejection with `invalid_batch`;
- camelCase request serialization.

### 8. Flutter bridge/fallback regression coverage

`apps/unitflow_app/test/core/native_conversion_bridge_test.dart` now covers:

- supported startup metadata;
- protocol mismatch;
- missing capability;
- malformed backend/capability payloads;
- duplicate capability rejection;
- exact decimal preservation;
- invalid unit IDs;
- invalid precision;
- ordered batch request serialization;
- the 256-target bridge constant;
- malformed batch target rejection;
- oversized batch rejection;
- response validation;
- safe failure formatting.

`apps/unitflow_app/test/converter_controller_test.dart` now additionally proves that the deterministic fallback:

- accepts exactly 256 targets;
- rejects 257 targets;
- preserves exact conversion output at the boundary limit.

### 9. Repository drift validation expanded

`scripts/check_release_consistency.py` previously validated release version/schema and bridge protocol declarations.

It now also verifies:

- fixture bridge protocol version;
- documented bridge protocol version;
- Rust bridge protocol version;
- Flutter bridge protocol version;
- Rust advertised capability set;
- Flutter required capability set;
- documented required capability set;
- Rust bridge batch target limit;
- Flutter bridge batch target limit;
- deterministic Flutter fallback batch target limit;
- documented batch target limit.

Any of these declarations drifting apart now fails repository release consistency validation.

`scripts/tests/test_repository_validators.py` locks the current protocol/capability/batch-limit values and calls the release-consistency validator against the current tree.

### 10. Bridge documentation upgraded

`docs/bridge-protocol.md` now defines:

- protocol version `1`;
- exact required capabilities;
- maximum batch target count;
- stable unit-ID rules;
- single request shape;
- batch request shape;
- ordering requirements;
- safe failure codes including `invalid_batch` and `capability_mismatch`;
- startup metadata shape;
- fail-closed compatibility behavior;
- current Rust and Flutter source contracts;
- generated-binding requirements;
- parity cases still required before release.

`docs/bridge.md` now distinguishes completed source-level negotiation/bounds from still-pending generated bindings and runtime native integration.

`ROADMAP.md` now marks source-level protocol/capability negotiation, bounded batch contracts, and repository parity validation complete while leaving production generated bindings/runtime selection/packaging open.

`CHANGELOG.md` records these 2.0.12 bridge and fallback hardening changes.

## Cross-platform infrastructure retained from the previous continuation

The following six-platform work remains present and is still required infrastructure:

- `scripts/bootstrap_platforms.sh`;
- `scripts/bootstrap_platforms.ps1`;
- `.github/workflows/materialize-platforms.yml`;
- `.github/workflows/platform-smoke.yml` release build matrix;
- `scripts/check_platform_support.py`;
- `scripts/update_platform_inventory.py`;
- `docs/platform-file-inventory.md`;
- all-or-nothing committed platform-set validation;
- Android/iOS/Web/Windows/Linux/macOS release build command coverage;
- artifact upload definitions for all six targets;
- generated-platform inventory enforcement;
- Web protection against unconditional shared `dart:io` imports.

## Latest live platform-tree inspection

The live `apps/unitflow_app` directory was re-inspected after this continuation.

It still contains only the shared Flutter sources/configuration:

- `analysis_options.yaml`;
- `l10n.yaml`;
- `lib/`;
- `pubspec.yaml`;
- `test/`.

The following generated platform directories are still absent on the inspected `main` tree:

```text
android/
ios/
web/
windows/
linux/
macos/
```

Therefore the repository remains in the validator's intended **generation-ready** state rather than a committed-platform **materialized** state.

Do not claim that six committed native projects exist until the live tree actually contains all six together.

## Verification evidence and limitations

### Connected GitHub evidence

All changes in this continuation were written directly to live `main` through the connected GitHub integration.

The latest commit chain was re-read after the work. The continuation from the previous checkpoint through `c4866da2` contains 26 granular bridge/fallback/documentation commits before this handoff update.

A legacy combined-status lookup on `c4866da2aa3fe5844caf5bd4eed30f87e9527b4b` returned no status entries. That is **not** equivalent to a successful GitHub Actions matrix, so no CI/build success is claimed from it.

The available workflow-run wrapper only exposes pull-request-triggered runs and could not establish the push-run matrix for these direct `main` commits. Direct public Actions-page retrieval was also unavailable through the current tools.

### Local execution limitation

The available execution environment does not provide the Flutter/Dart/Rust/native toolchains needed for trustworthy compilation of this live repository, and earlier direct GitHub clone attempts failed because the execution container could not resolve `github.com` through DNS.

Therefore this continuation does **not** claim local successful output for:

- `dart format`;
- `flutter analyze`;
- `flutter test`;
- `cargo fmt`;
- `cargo clippy`;
- `cargo test`;
- any Android/iOS/Web/Windows/Linux/macOS release build.

Source contracts and regression tests were added, but actual compiler/runner evidence must still be obtained in a toolchain-capable environment or GitHub Actions.

## Remaining blockers before `v2.0.12` can be called fully release-verified

1. Materialize, review, and commit all six Flutter platform directories plus `.metadata` together.
2. Run and review the six-platform release-build matrix against the committed platform projects.
3. Fix every real target-specific build failure surfaced by execution.
4. Generate the actual Rust↔Flutter binding layer from the now-stable source contract.
5. Implement actual app startup engine selection using `NativeBridgeInfo.requireCompatible()`.
6. Reconcile the current synchronous `ConversionEngine` presentation-facing API with the asynchronous future native bridge without introducing stale-result races or silent mid-session fallback.
7. Package/load the Rust native library on Android/iOS/Windows/Linux/macOS where Rust authority is claimed.
8. Execute native-vs-Dart parity through the generated binding, not only source-level DTO tests.
9. Add rendered primary UI integration tests and native E2E journeys.
10. Perform screen-reader, keyboard/focus, large-text, contrast, reduced-motion, and touch-target review.
11. Record performance/search/batch/native profiling baselines where release decisions need them.
12. Produce final app icons/splash/screenshots/demo media from verified builds.
13. Validate Android production signing and Apple signing/provisioning/notarization without committing credentials.
14. Complete clean-clone and downloaded-artifact release-candidate verification.
15. Complete `docs/release-checklist.md`.
16. Only then create and verify the exact `v2.0.12` tag.

## Exact next continuation priority

1. Inspect live `main` for all six generated platform directories and inspect available GitHub Actions results first.
2. If platform projects are still absent, execute `.github/workflows/materialize-platforms.yml` from a workflow-capable context or run the bootstrap scripts with Flutter installed; commit all six generated targets together and regenerate the platform inventory.
3. Fix every actual cross-platform build failure surfaced by the matrix.
4. Select and integrate a reviewed Rust↔Flutter binding generator/FFI implementation around `BridgeService::info()`, `convert()`, and `batch_convert()`.
5. Implement one-time startup engine selection that fails closed on protocol/capability mismatch and never silently changes engines midway through a calculation/session.
6. Execute generated-boundary Rust/Dart parity, including malformed metadata, exact 256-target batch behavior, rounding ties, affine temperature conversions, and safe errors.
7. Continue native E2E/accessibility/performance/release-candidate evidence.

## Commits created in this bridge-hardening continuation

- `841b7b48` — `core: add bridge capability negotiation metadata`
- `46a8f2af` — `core: export bridge negotiation contract`
- `9c565848` — `test: lock bridge capability negotiation contract`
- `697f184a` — `app: add native bridge compatibility negotiation`
- `deb55a45` — `test: cover native bridge compatibility negotiation`
- `227dca97` — `build: validate Flutter bridge protocol parity`
- `bb69e572` — `test: lock cross-language bridge protocol parity`
- `ef03e2aa` — `docs: define bridge capability negotiation`
- `200e5212` — `build: enforce bridge capability parity`
- `50aeef09` — `test: enforce documented bridge capabilities`
- `05991f7e` — `docs: advance native bridge negotiation plan`
- `dc1fc88d` — `core: bound native bridge batch requests`
- `8ea444b1` — `core: export bridge batch safety limit`
- `e10d8b90` — `app: expose bounded native batch bridge contract`
- `fd1d882e` — `test: cover bridge batch safety bounds`
- `52fa33d9` — `test: cover native batch bridge bounds`
- `2a637e18` — `docs: specify bounded native batch protocol`
- `f5204804` — `build: enforce bridge batch limit parity`
- `e2590291` — `test: enforce native batch limit parity`
- `778f5a79` — `docs: document bridge batch safety contract`
- `2c946073` — `docs: advance bridge hardening roadmap`
- `c8f3fd5e` — `app: bound fallback batch conversion work`
- `fe70d82b` — `test: enforce fallback batch conversion limit`
- `60ae0e54` — `build: lock fallback batch limit to bridge contract`
- `629e6b0a` — `test: lock fallback batch limit parity`
- `c4866da2` — `docs: record bridge negotiation hardening`

This handoff update follows those 26 commits.

## Previous cross-platform continuation commit range

The immediately preceding continuation ended with:

- `109ebca3` — `docs: record full six-platform continuation`

and included the platform materialization workflow, generated platform inventory, release build matrix, six-platform validator, verification wiring, tests, roadmap, changelog, and platform support documentation described above.

## Commit identity note

Requested local identity remains:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

GitHub connector-created commits do not expose a per-write author/committer email override. The platform materialization workflow explicitly configures the requested identity before its generated-platform commit.

## Handoff rules

For future continuation work:

1. inspect live `main` before trusting this file;
2. prefer compiler/test/workflow evidence over source/workflow definitions;
3. keep all six platform targets synchronized;
4. never accept a partially committed platform-project set;
5. regenerate `docs/platform-file-inventory.md` whenever generated platform files change;
6. preserve protocol/capability/batch-limit parity across Rust, Flutter bridge, deterministic fallback, and documentation;
7. never silently switch calculation engines after startup selection;
8. keep production signing credentials out of source control;
9. update this file after meaningful work;
10. do not tag or call `v2.0.12` release-verified while evidence blockers remain open.
