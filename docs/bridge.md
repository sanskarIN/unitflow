# Rust ↔ Flutter bridge plan

The Rust crate is the authoritative native conversion domain. Flutter currently includes a deterministic Dart implementation so UI development, web support, and tests do not depend on generated native bindings.

## Goals

The production bridge must:

- expose stable request/response types rather than Flutter-specific objects;
- preserve decimal values as strings across the FFI boundary;
- return structured errors instead of panicking across FFI;
- support catalog lookup, single conversion, batch conversion, notation, and custom-unit validation;
- produce results equivalent to the Dart fallback for the same catalog snapshot and settings;
- require no network connection;
- avoid unsafe code in the domain crate.

## Boundary shape

A bridge request should use plain serializable values such as:

```text
value: decimal string
from_unit_id: stable string
 to_unit_id: stable string
decimal_places: optional integer
round_mode: stable enum/string
```

A bridge response should return:

```text
input: decimal string
output: decimal string
from_unit_id: stable string
to_unit_id: stable string
category: stable enum/string
```

Passing decimal strings prevents accidental binary floating-point conversion in generated bindings.

## Error contract

Bridge adapters should translate `UnitFlowError` into a stable error code plus safe human-readable message. Unknown units, category mismatch, invalid precision, malformed custom units, division by zero, and arithmetic overflow must remain distinguishable for tests and diagnostics.

## Parity suite

Before the native bridge becomes the default conversion path, automated tests should compare native and Dart results for:

- every built-in unit identity conversion;
- representative pair conversions in every category;
- Celsius/Fahrenheit/Kelvin/Rankine boundaries;
- positive, zero, and negative values where physically meaningful;
- very small and large representable decimals;
- every rounding mode supported by both sides;
- batch conversion ordering;
- custom multiplicative and affine units;
- invalid unit IDs and category mismatches.

## Failure strategy

The app should not silently switch calculation engines after a native calculation failure, because that could hide a bridge defect. A fallback may be chosen at startup for unsupported targets such as Web or when the native bridge is intentionally unavailable. The selected engine should remain stable for the session and be visible in diagnostics.

## Versioning

Generated bindings and bridge DTOs should be tied to a bridge protocol version. Breaking changes must update the protocol version and parity fixtures together.
