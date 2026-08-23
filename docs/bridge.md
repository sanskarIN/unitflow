# Rust ↔ Flutter bridge plan

The Rust crate is the authoritative native conversion domain. Flutter currently includes a deterministic Dart implementation so UI development, Web support, and tests do not depend on generated native bindings.

## Current source-level progress

`crates/unitflow_core/src/bridge.rs` implements the Rust-side application protocol layer that generated bindings can call. It provides:

- protocol version `1` and a stable diagnostic backend identifier;
- explicit startup capabilities for single conversion, ordered batch conversion, and canonical decimal text;
- generator-friendly `BridgeInfo` startup metadata exposed through `BridgeService::info()`;
- generator-friendly single and ordered batch conversion DTOs;
- a shared `256`-target ceiling for native batch requests;
- strict bridge unit-ID bounds aligned with the Flutter DTO boundary;
- canonical base-10 decimal strings at the boundary;
- camelCase startup/request/response serialization compatible with the documented Flutter contract;
- a long-lived `BridgeService` over a validated `Converter`;
- stable, safe failure codes for invalid decimal input, unknown units, category mismatches, invalid precision, oversized batches, catalog failures, and conversion failures;
- regression tests for startup metadata, capability ordering, batch safety bounds, unit-ID validation, canonical decimal enforcement, failure-code behavior, batch ordering, and serialized field names.

`apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart` provides the matching Flutter-side negotiation and conversion contract. `NativeBridgeInfo` bounds and validates backend metadata, deterministically serializes capability metadata, and structurally revalidates even directly constructed metadata objects before they can influence backend selection. The contract requires protocol version `1`, the documented capability set, and the shared `256`-target batch ceiling.

`apps/unitflow_app/lib/features/converter/domain/conversion_session.dart` now provides the source-level runtime selection seam:

- `ConversionSession.bootstrap()` calls a future native bridge loader exactly once;
- native load failure selects deterministic Dart before the session starts with `native_load_failed`;
- a missing bridge selects Dart with `native_unavailable`;
- malformed startup metadata selects Dart with `metadata_invalid`;
- protocol/capability incompatibility fails closed before native selection;
- compatible metadata selects Rust and records the stable backend identifier;
- the selected bridge/backend is immutable for the session;
- native runtime failures never cause a silent mid-session switch to Dart;
- generated-adapter `Error` objects at load, startup metadata, single-conversion, and batch-conversion boundaries are contained and converted into stable application behavior;
- malformed native responses are surfaced as `invalid_response`;
- response identity/order/cardinality mismatches are surfaced as `response_mismatch`;
- unexpected adapter/backend execution failures are surfaced as `backend_failure`.

`apps/unitflow_app/lib/features/converter/domain/latest_conversion_request.dart` provides a presentation-agnostic generation-token gate for future asynchronous controller wiring. Only the newest live request may publish success or failure. Older completions are ignored, explicit invalidation drops in-flight work, and disposal rejects future work. Callback errors are not reclassified as conversion-operation failures.

`scripts/check_conversion_session_contract.py` locks one-shot loading, sticky selection, adapter-error containment, metadata/response validation, stable failure classification, response identity/order, no runtime fallback, latest-request race suppression, regression-test presence, and validator wiring into Bash, PowerShell, CI, release, platform materialization, and repository hygiene.

`scripts/check_release_consistency.py` separately prevents the protocol number, capability set, and batch target ceiling from drifting between Rust, Flutter, fixtures, and documentation.

These source-level contracts are important prerequisites, **not completed production native integration**. A generated adapter implementing `NativeConversionBridge`, native library loading/packaging, application/controller wiring to `ConversionSession`, generated-boundary parity execution, and per-platform release validation are still required before a native build can claim Rust bridge authority.

## Goals

The production bridge must:

- expose stable request/response types rather than Flutter-specific objects;
- preserve decimal values as strings across the FFI boundary;
- return structured errors instead of panicking across FFI;
- negotiate protocol and required capabilities before routing conversions;
- enforce bounded single/batch request contracts before expensive work;
- support catalog lookup, single conversion, batch conversion, notation, and custom-unit validation;
- produce results equivalent to the Dart fallback for the same catalog snapshot and settings;
- require no network connection;
- avoid unsafe code in the domain crate.

## Startup negotiation

The generated adapter must expose the Rust service's startup metadata before the first native conversion:

```text
protocolVersion: integer
backendId: stable string
capabilities: list<string>
```

Protocol version `1` currently requires:

- `convert`;
- `batchConvert`;
- `canonicalDecimalText`.

The adapter must construct or parse `NativeBridgeInfo`, while `ConversionSession.select()` performs an additional structural revalidation through `validatedCopy()` before calling `requireCompatible()`. Protocol mismatch produces `protocol_mismatch`; missing required capability produces `capability_mismatch`; malformed metadata produces the pre-session `metadata_invalid` fallback reason.

`ConversionSession.bootstrap()` is the intended source seam for the future platform-specific loader. The loader is invoked once. A null bridge or loading failure is resolved before the session begins. The loader is never retried during subsequent conversions, preventing per-request backend flapping.

Additional capabilities may be introduced compatibly when existing required semantics remain intact. Removing or renaming a required capability is a breaking contract change and must be coordinated with bridge protocol versioning.

## Boundary shape

A bridge request uses plain serializable values such as:

```text
value: decimal string
from_unit_id: stable string
to_unit_id: stable string
decimal_places: optional integer
round_mode: stable enum/string
```

An ordered batch request uses:

```text
value: decimal string
from_unit_id: stable string
target_unit_ids: ordered list of stable strings
decimal_places: optional integer
round_mode: stable enum/string
```

One native batch request may contain at most `256` targets. Request order must be preserved in the response. Oversized batches fail before conversion work with `invalid_batch` on the Rust boundary and are rejected before native invocation by the Flutter session/fallback contract.

A bridge response returns:

```text
input: decimal string
output: decimal string
from_unit_id: stable string
to_unit_id: stable string
```

Passing decimal strings prevents accidental binary floating-point conversion in generated bindings. Flutter revalidates response decimal text and unit IDs, verifies echoed request identity, and verifies batch cardinality/order before accepting native results.

## Error contract

Bridge adapters should translate `UnitFlowError` and binding-layer failures into stable error codes plus safe human-readable messages. Unknown units, category mismatch, invalid precision, malformed custom units, oversized batches, division by zero, arithmetic overflow, protocol mismatch, missing capabilities, native bridge availability, malformed responses, response mismatches, and adapter/backend failures must remain distinguishable for tests and diagnostics.

The Rust source service deliberately does not echo untrusted unit identifiers or raw internal error details in its safe bridge messages. Flutter's `NativeBridgeFailure.toString()` likewise avoids embedding arbitrary detail.

The Flutter session adds stable boundary classifications for failures that occur outside the Rust domain DTO contract:

- `native_load_failed` — the bridge loader failed before selection;
- `native_unavailable` — the loader/target intentionally supplied no native bridge;
- `metadata_invalid` — startup metadata failed structural validation;
- `startup_failed` — another generated-adapter startup failure occurred;
- `invalid_response` — a native response failed Flutter-side structural/canonical validation;
- `response_mismatch` — response identity/order/cardinality did not match the request;
- `backend_failure` — an unexpected adapter/backend execution failure occurred after native selection.

These classifications are diagnostic/application boundary states; they do not change the protocol version by themselves. If a generated wire protocol begins serializing them as stable cross-language DTO values, that contract must be documented and versioned explicitly.

## Async result publication

Generated bindings may make conversion calls asynchronous even when Rust computation itself is fast. The presentation layer must therefore prevent a slow older request from overwriting newer user input or selection.

`LatestConversionRequest` is the source-level gate for that integration. The eventual controller path should:

1. capture the complete conversion request state;
2. start work through `LatestConversionRequest.run()`;
3. publish only the current generation's success or failure;
4. invalidate pending work when input/category/unit state changes in a way that supersedes the request;
5. dispose the gate with the owning controller;
6. never treat callback/UI exceptions as backend failures.

The existing synchronous `ConverterController` has **not** yet been migrated to this asynchronous session path. That remains part of production adapter/controller integration.

## Catalog and custom-unit authority

The current Flutter `AppController` rebuilds its deterministic Dart engine when custom units change. A future native session must not hold a stale catalog snapshot while the UI uses a newer custom-unit catalog.

Before production native wiring is considered complete, choose and implement one explicit authority strategy, for example:

- rebuild/reselect a native session whenever the authoritative catalog snapshot changes; or
- expose custom-unit/catalog mutation through the native bridge and keep Rust as the single live catalog authority.

Do not route built-in conversions through Rust while silently routing custom-unit state through a divergent catalog without a documented parity boundary.

## Parity suite

Before the native bridge becomes the default conversion path, automated tests should compare native and Dart results for:

- every built-in unit identity conversion;
- representative pair conversions in every category;
- Celsius/Fahrenheit/Kelvin/Rankine boundaries;
- positive, zero, and negative values where physically meaningful;
- very small and large representable decimals;
- every rounding mode supported by both sides;
- batch conversion ordering;
- empty, normal, maximum-size, and oversized batches;
- custom multiplicative and affine units;
- invalid unit IDs and category mismatches;
- protocol mismatch, capability mismatch, malformed startup metadata, and loader failure behavior;
- malformed native response, response mismatch, and unexpected adapter/backend failure behavior;
- stale asynchronous completion suppression once the generated adapter is wired to presentation state.

The repository already shares versioned conversion/rounding vectors between Rust and Dart, and both sides test the source-level negotiation and bounded batch contracts. Those tests still do not substitute for executing the generated native binding on each supported platform.

## Failure strategy

The app must not silently switch calculation engines after a native calculation failure, because that could hide a bridge defect or produce inconsistent results within one interaction. A fallback may be selected once before the session for unsupported targets such as Web, an intentionally unavailable native bridge, loader failure, malformed startup metadata, or incompatible protocol/capabilities.

After Rust is selected, bridge-reported failures, adapter `Error` objects, malformed responses, and response mismatches are surfaced as failures while `ConversionSession.backend` remains `rustNative`. The selected engine and fallback reason/backend identifier are stable diagnostic state for that session.

## Versioning

Generated bindings and bridge DTOs are tied to a bridge protocol version. Breaking changes must update the protocol version, source declarations, documentation, and parity fixtures together. Capability declarations and batch limits are repository-validated so Rust, Flutter, and documentation cannot silently disagree.
