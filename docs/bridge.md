# Rust ↔ Flutter bridge plan

The Rust crate is the authoritative native conversion domain. Flutter currently includes a deterministic Dart implementation so UI development, web support, and tests do not depend on generated native bindings.

## Current source-level progress

`crates/unitflow_core/src/bridge.rs` now implements the Rust-side application protocol layer that generated bindings can call. It provides:

- protocol version `1` and a stable diagnostic backend identifier;
- generator-friendly single and ordered batch conversion DTOs;
- canonical base-10 decimal strings at the boundary;
- camelCase request/response serialization compatible with the documented Flutter contract;
- a long-lived `BridgeService` over a validated `Converter`;
- stable, safe failure codes for invalid decimal input, unknown units, category mismatches, invalid precision, catalog failures, and conversion failures;
- regression tests for protocol metadata, canonical decimal enforcement, failure-code behavior, batch ordering, and serialized field names.

This source service is an important prerequisite, **not the completed production native integration**. Generated Rust↔Flutter bindings, native library loading/packaging, startup negotiation in the app, and per-platform release validation are still required before a native build can claim Rust bridge authority.

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

The Rust source service deliberately does not echo untrusted unit identifiers or raw internal error details in its safe bridge messages.

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

The repository already shares versioned conversion/rounding vectors between Rust and Dart, and Rust now additionally tests the source-level bridge service. Those tests still do not substitute for executing the generated native binding on each supported platform.

## Failure strategy

The app should not silently switch calculation engines after a native calculation failure, because that could hide a bridge defect. A fallback may be chosen at startup for unsupported targets such as Web or when the native bridge is intentionally unavailable. The selected engine should remain stable for the session and be visible in diagnostics.

## Versioning

Generated bindings and bridge DTOs should be tied to a bridge protocol version. Breaking changes must update the protocol version and parity fixtures together.
