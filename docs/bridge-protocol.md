# Native bridge protocol

This document defines the stable application-level contract that the future generated Rust↔Flutter binding must preserve. It is intentionally separate from the binding generator so UnitFlow can change generator/tooling details without silently changing decimal semantics.

## Protocol version

Current protocol version: `1`.

The bridge protocol version is independent of the application version and local backup schema version.

## Decimal rule

**All conversion values cross the bridge as canonical base-10 text.**

Do not expose user values, scales, offsets, or conversion outputs as `double`/`f64` DTO fields. The native Rust side parses text into its decimal domain representation and returns canonical decimal text.

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

Unit identifiers must use stable catalog IDs rather than localized names or symbols.

## Conversion response

Logical fields:

```text
input: string
output: string
fromUnitId: string
toUnitId: string
```

The response should echo the normalized input and stable IDs used by the native conversion operation. Flutter resolves presentation metadata through its active catalog or a future catalog bridge.

## Failure contract

Binding-specific exceptions must be converted into a small safe application error contract. Recommended stable codes:

- `invalid_decimal`
- `unknown_unit`
- `category_mismatch`
- `invalid_precision`
- `invalid_rounding_mode`
- `catalog_invalid`
- `conversion_failed`
- `bridge_unavailable`
- `protocol_mismatch`

User-facing UI should map codes to localized messages. Raw Rust panic text, backtraces, file paths, arbitrary imported content, or generated-binding internals must not be displayed directly.

## Startup negotiation

A native backend should expose:

```text
protocolVersion: integer
backendId: string
```

The Flutter application must verify that it supports the reported protocol version before routing conversions to the backend. An incompatible bridge should fail closed and keep the selected engine stable for the lifetime of the calculation/session rather than silently switching midway through a result.

## Dart source contract

`apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart` contains the current Flutter-side DTO/interface contract. Its tests verify string-preserved decimals, response validation, and safe failure formatting.

## Future generated binding

The production integration should:

1. expose a long-lived Rust conversion/catalog service rather than rebuilding the catalog per keystroke;
2. keep DTOs generator-friendly and versioned;
3. provide cancellation/stale-result protection if calls are asynchronous;
4. prove parity against the deterministic Dart engine;
5. package the native library for every verified native platform;
6. keep Web on the deterministic Dart path unless a separately verified Web Rust backend is introduced.

## Parity suite

At minimum compare Rust and Dart results for:

- zero and negative inputs;
- exact SI scaling;
- temperature affine conversions;
- very small/large decimal magnitudes within supported bounds;
- all rounding modes at tie boundaries;
- custom multiplicative and affine units;
- batch conversion ordering and exact decimal text;
- invalid IDs, category mismatches, and malformed decimal text.

A native bridge is not considered release-ready until those parity tests and native packaging checks pass for the release commit.
