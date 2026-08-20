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

## Failure contract

Binding-specific exceptions must be converted into a small safe application error contract. Recommended stable codes:

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

Flutter parses startup metadata before native routing. The backend identifier and capability identifiers are bounded stable diagnostic tokens; malformed payloads are rejected rather than trusted.

The Flutter application must verify both protocol version and required capabilities before selecting the native backend. A protocol mismatch fails with `protocol_mismatch`; a missing required capability fails with `capability_mismatch`. Either condition fails closed. The selected engine must remain stable for the lifetime of the calculation/session rather than silently switching midway through a result.

## Source contracts

`apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart` contains the Flutter-side DTO/interface contract. `NativeBridgeInfo` validates startup metadata, exposes `isCompatible`, and provides `requireCompatible()` for fail-closed protocol/capability negotiation. The interface exposes both single and batch conversion methods, and batch request serialization enforces the shared target ceiling. Its tests cover supported metadata, protocol mismatch, missing capabilities, malformed metadata, bounded batch requests, string-preserved decimals, response validation, and safe failure formatting.

`../crates/unitflow_core/src/bridge.rs` contains the Rust-side protocol service. It exposes protocol version `1`, backend metadata, the stable capability set, generator-friendly conversion/batch DTOs, the shared `256`-target batch ceiling, bridge unit-ID validation, canonical decimal validation, safe failure mapping, and a long-lived conversion service. `BridgeService::info()` returns generator-friendly startup metadata. `../crates/unitflow_core/tests/bridge_service.rs` locks those source-level guarantees and camelCase serialization.

`scripts/check_release_consistency.py` prevents bridge protocol declarations, required capabilities, and batch bounds from drifting between documentation, fixtures, Rust source, and Flutter source. Repository validator tests lock that cross-language check.

These source contracts are prerequisites for generated bindings. Their presence does not prove that a native library has been generated, loaded, packaged, or validated on any platform.

## Future generated binding

The production integration should:

1. expose the long-lived Rust conversion service through a reviewed binding generator/FFI layer;
2. expose `BridgeService::info()` before routing any conversion through Rust;
3. keep DTOs generator-friendly and versioned;
4. call Flutter compatibility validation before selecting the native engine;
5. preserve the documented batch ceiling and target ordering through generated bindings;
6. provide cancellation/stale-result protection if calls are asynchronous;
7. prove parity against the deterministic Dart engine through the generated boundary;
8. package the native library for every verified native platform;
9. keep Web on the deterministic Dart path unless a separately verified Web Rust backend is introduced.

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
- startup protocol mismatch and missing required capability behavior.

A native bridge is not considered release-ready until those parity tests and native packaging checks pass for the release commit.
