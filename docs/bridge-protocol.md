# Native bridge protocol

This document defines the stable application-level contract that the future generated Rust↔Flutter binding must preserve. It is intentionally separate from the binding generator so UnitFlow can change generator/tooling details without silently changing decimal semantics.

## Protocol version

Current protocol version: `1`.

The bridge protocol version is independent of the application version and local backup schema version.

Current required capabilities: `convert`, `batchConvert`, `canonicalDecimalText`.

Current maximum batch targets: `256`.

A backend is compatible only when it reports the exact supported protocol version and contains every required capability. It may report additional forward-compatible capabilities, but removing or renaming a required capability is a breaking bridge change and must be reviewed together with protocol versioning.

## Decimal rule

**All conversion values cross the bridge as canonical base-10 text.**

Do not expose user values, scales, offsets, or conversion outputs as `double`/`f64` DTO fields. The native Rust side parses text into its decimal domain representation and returns canonical decimal text.

## Unit identifier rule

Bridge unit identifiers use stable catalog IDs rather than localized names or symbols. Boundary identifiers are limited to 1–64 ASCII lowercase letters, digits, `_`, and `-`. Malformed identifiers are rejected before catalog lookup and are surfaced through the same safe `unknown_unit` contract without echoing the supplied identifier.

## Conversion request

Logical fields:

```text
value: string
fromUnitId: string
toUnitId: string
decimalPlaces: integer or null
roundMode: enum/string
```

Supported rounding identifiers:

- `nearestEven`
- `halfAwayFromZero`
- `towardZero`
- `awayFromZero`
- `floor`
- `ceiling`

## Batch conversion request

Logical fields:

```text
value: string
fromUnitId: string
targetUnitIds: list<string>
decimalPlaces: integer or null
roundMode: enum/string
```

Target order is semantically significant and must be preserved in the returned result list. One request may contain at most `256` targets. Oversized native requests fail with `invalid_batch` before conversion work begins. An empty target list is valid and returns an empty result list.

## Conversion response

Logical fields:

```text
input: string
output: string
fromUnitId: string
toUnitId: string
```

The response should echo the normalized input and stable IDs used by the native conversion operation. Flutter resolves presentation metadata through its active catalog or a future catalog bridge.

Batch responses use the same response shape for each target and preserve request target order.

Flutter does not trust a typed generated response merely because it has already been constructed. The application boundary reparses response fields through `NativeBridgeConversionResponse.fromMap`, enforcing canonical decimal text and stable unit-ID syntax before accepting the result. It then verifies that echoed input/source/target metadata matches the originating request. Batch responses additionally must have the same cardinality and target ordering as the request.

## Failure contract

Binding-specific exceptions must be converted into a small safe application error contract. Rust/domain-oriented stable codes include:

- `invalid_decimal`
- `unknown_unit`
- `category_mismatch`
- `invalid_precision`
- `invalid_rounding_mode`
- `invalid_batch`
- `catalog_invalid`
- `conversion_failed`
- `bridge_unavailable`
- `protocol_mismatch`
- `capability_mismatch`

User-facing UI should map codes to localized messages. Raw Rust panic text, backtraces, file paths, arbitrary imported content, or generated-binding internals must not be displayed directly.

The current Rust source service maps domain failures into this safe contract without echoing untrusted unit identifiers. Typed Rust DTOs make an invalid rounding identifier a deserialization/binding-layer concern; generated adapters must normalize that case to `invalid_rounding_mode`.

The Flutter application boundary additionally classifies failures that can occur around loading/generated adapters:

- `native_load_failed` — loading/constructing the native adapter failed before session selection;
- `native_unavailable` — no native bridge is available for the current target/session;
- `metadata_invalid` — startup metadata failed bounded structural validation;
- `startup_failed` — another adapter startup failure occurred before selection;
- `invalid_response` — a returned response failed Flutter-side structural/canonical validation;
- `response_mismatch` — response identity, cardinality, or target ordering does not match the request;
- `backend_failure` — an unexpected adapter/backend execution failure occurred after native selection.

These Flutter-side codes are currently application-boundary diagnostics, not additional serialized Rust DTO variants. If they become part of the generated wire contract later, the protocol documentation/versioning must be updated deliberately.

## Startup negotiation

A native backend must expose bounded, validated startup metadata:

```text
protocolVersion: integer
backendId: string
capabilities: list<string>
```

Protocol version `1` currently requires:

- `convert` — single conversion requests are supported;
- `batchConvert` — ordered, resource-bounded batch conversion requests are supported;
- `canonicalDecimalText` — decimal inputs and outputs use canonical base-10 text.

Flutter parses startup metadata before native routing. The backend identifier and capability identifiers are bounded stable diagnostic tokens; malformed payloads are rejected rather than trusted. `NativeBridgeInfo.toMap()` produces deterministic capability ordering, and `validatedCopy()` ensures directly constructed metadata objects are revalidated through the same parsing boundary before selection.

`ConversionSession.bootstrap()` is the source-level startup seam. It invokes a supplied native bridge loader exactly once. A loader failure selects Dart with `native_load_failed`; a null result selects Dart with `native_unavailable`. `ConversionSession.select()` then performs structural metadata validation followed by protocol/capability validation. Protocol mismatch produces `protocol_mismatch`; a missing required capability produces `capability_mismatch`; malformed metadata selects Dart with `metadata_invalid`; another startup-adapter failure selects Dart with `startup_failed`.

All of those decisions occur before the calculation session begins. Once the native backend is selected, the selected engine remains stable for the lifetime of that session and runtime failures do not trigger a silent fallback to Dart.

## Runtime selection and adapter boundary

The current source router is `apps/unitflow_app/lib/features/converter/domain/conversion_session.dart`.

Its guarantees are:

1. a candidate native bridge is loaded at most once during bootstrap;
2. the fallback engine and selected native bridge are fixed when the session is created;
3. request DTOs are validated before native invocation;
4. generated-adapter `Error`/exception failures are contained at startup, single-conversion, and batch-conversion boundaries;
5. bridge-reported `NativeBridgeFailure` values are propagated without changing the selected engine;
6. native response fields are structurally revalidated after invocation;
7. response identity/order/cardinality is validated before publishing typed conversion results;
8. no native runtime failure causes a mid-session engine switch.

The source seam is intentionally adapter-agnostic. No production `NativeConversionBridge` generated adapter or native library loader is committed yet, and the current `main.dart`/`ConverterController` path is not yet wired through `ConversionSession`.

## Asynchronous publication rule

Generated bindings may make calls asynchronous. A slower older conversion must never overwrite state derived from newer input, category, source unit, target unit, or rounding settings.

`apps/unitflow_app/lib/features/converter/domain/latest_conversion_request.dart` provides the current generation-token gate. Only the newest live request may publish success or failure. Explicit invalidation suppresses an in-flight completion, and disposal suppresses pending publication and rejects future requests.

The eventual controller integration must use this or an equivalent reviewed mechanism around asynchronous session calls. The gate itself is source-tested now, but the synchronous `ConverterController` has not yet been migrated to the native async path.

## Catalog snapshot rule

A native session and the Flutter presentation layer must agree on the same unit/catalog snapshot. This matters especially for custom units because the current Dart `AppController` can rebuild its local conversion engine when custom units change.

Production integration must therefore either:

- recreate/reselect the native session when the authoritative catalog snapshot changes; or
- move custom-unit/catalog mutation behind the native bridge so Rust remains the single live authority.

A release must not claim Rust authority while custom-unit conversions silently use a divergent catalog snapshot.

## Source contracts

`apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart` contains the Flutter-side DTO/interface contract. `NativeBridgeInfo` validates startup metadata, deterministically serializes it, exposes `isCompatible`, provides `requireCompatible()`, and supports structural revalidation through `validatedCopy()`. The interface exposes both single and batch conversion methods, and batch request serialization enforces the shared target ceiling.

`apps/unitflow_app/lib/features/converter/domain/conversion_session.dart` contains one-shot loader/bootstrap selection, immutable session backend state, request/response validation, safe failure classification, and no-mid-session-fallback behavior. `apps/unitflow_app/lib/features/converter/domain/latest_conversion_request.dart` contains stale asynchronous completion suppression for future presentation wiring.

`../crates/unitflow_core/src/bridge.rs` contains the Rust-side protocol service. It exposes protocol version `1`, backend metadata, the stable capability set, generator-friendly conversion/batch DTOs, the shared `256`-target batch ceiling, bridge unit-ID validation, canonical decimal validation, safe failure mapping, and a long-lived conversion service. `BridgeService::info()` returns generator-friendly startup metadata. `../crates/unitflow_core/tests/bridge_service.rs` locks those source-level guarantees and camelCase serialization.

`scripts/check_release_consistency.py` prevents bridge protocol declarations, required capabilities, and batch bounds from drifting between documentation, fixtures, Rust source, and Flutter source. `scripts/check_conversion_session_contract.py` separately locks runtime-selection/race-safety source semantics and its verification wiring.

These source contracts are prerequisites for generated bindings. Their presence does not prove that a native library has been generated, loaded, packaged, wired into the app, or validated on any platform.

## Future generated binding

The production integration should:

1. expose the long-lived Rust conversion service through a reviewed binding generator/FFI layer;
2. expose `BridgeService::info()` before routing any conversion through Rust;
3. implement a production `NativeConversionBridge` adapter without weakening DTO validation;
4. provide a platform loader consumed once by `ConversionSession.bootstrap()`;
5. preserve the documented batch ceiling and target ordering through generated bindings;
6. wire single and batch controller flows through the same selected session;
7. apply `LatestConversionRequest` or equivalent stale-result protection around async publication;
8. keep catalog/custom-unit authority synchronized with the selected session;
9. prove parity against the deterministic Dart engine through the generated boundary;
10. package the native library for every verified native platform;
11. keep Web on the deterministic Dart path unless a separately verified Web Rust backend is introduced.

## Parity suite

At minimum compare Rust and Dart results for:

- zero and negative inputs;
- exact SI scaling;
- temperature affine conversions;
- very small/large decimal magnitudes within supported bounds;
- all rounding modes at tie boundaries;
- custom multiplicative and affine units;
- batch conversion ordering and exact decimal text;
- empty, maximum-size, and oversized batch requests;
- invalid IDs, category mismatches, and malformed decimal text;
- startup protocol mismatch, missing required capability, malformed metadata, missing bridge, and loader failure behavior;
- malformed native responses, response mismatches, and unexpected generated-adapter failures;
- stale asynchronous completion suppression after controller integration.

A native bridge is not considered release-ready until those parity tests and native packaging checks pass for the release commit.
