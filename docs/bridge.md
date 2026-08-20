# Rust ↔ Flutter bridge plan

The Rust crate is the authoritative native conversion domain. Flutter currently includes a deterministic Dart implementation so UI development, web support, and tests do not depend on generated native bindings.

## Current source-level progress

`crates/unitflow_core/src/bridge.rs` implements the Rust-side application protocol layer that generated bindings can call. It provides:

- protocol version `1` and a stable diagnostic backend identifier;
- explicit startup capabilities for single conversion, ordered batch conversion, and canonical decimal text;
- generator-friendly `BridgeInfo` startup metadata exposed through `BridgeService::info()`;
- generator-friendly single and ordered batch conversion DTOs;
- canonical base-10 decimal strings at the boundary;
- camelCase startup/request/response serialization compatible with the documented Flutter contract;
- a long-lived `BridgeService` over a validated `Converter`;
- stable, safe failure codes for invalid decimal input, unknown units, category mismatches, invalid precision, catalog failures, and conversion failures;
- regression tests for startup metadata, capability ordering, canonical decimal enforcement, failure-code behavior, batch ordering, and serialized field names.

`apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart` now provides the matching Flutter-side negotiation contract. `NativeBridgeInfo` bounds and validates backend metadata, requires protocol version `1`, requires the documented capability set, exposes an `isCompatible` diagnostic predicate, and provides `requireCompatible()` so a future generated adapter can fail closed before native routing. Protocol and capability mismatches have stable safe failure codes.

`scripts/check_release_consistency.py` now prevents the protocol number and capability set from drifting between Rust, Flutter, fixtures, and documentation. Repository-validator tests lock the current cross-language contract.

This source-level negotiation is an important prerequisite, **not the completed production native integration**. Generated Rust↔Flutter bindings, native library loading/packaging, actual app startup selection, generated-boundary parity execution, and per-platform release validation are still required before a native build can claim Rust bridge authority.

## Goals

The production bridge must:

- expose stable request/response types rather than Flutter-specific objects;
- preserve decimal values as strings across the FFI boundary;
- return structured errors instead of panicking across FFI;
- negotiate protocol and required capabilities before routing conversions;
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

Flutter must parse this data through `NativeBridgeInfo` and call `requireCompatible()` before selecting the native engine. Protocol mismatch produces `protocol_mismatch`; missing required capability produces `capability_mismatch`. Malformed metadata is rejected at the DTO boundary.

Additional capabilities may be introduced compatibly when existing required semantics remain intact. Removing or renaming a required capability is a breaking contract change and must be coordinated with bridge protocol versioning.

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

Bridge adapters should translate `UnitFlowError` and binding-layer failures into stable error codes plus safe human-readable messages. Unknown units, category mismatch, invalid precision, malformed custom units, division by zero, arithmetic overflow, protocol mismatch, missing capabilities, and native bridge availability must remain distinguishable for tests and diagnostics.

The Rust source service deliberately does not echo untrusted unit identifiers or raw internal error details in its safe bridge messages. Flutter's `NativeBridgeFailure.toString()` likewise avoids embedding arbitrary detail.

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
- invalid unit IDs and category mismatches;
- protocol mismatch, capability mismatch, and malformed startup metadata.

The repository already shares versioned conversion/rounding vectors between Rust and Dart, and both sides now test the source-level negotiation contract. Those tests still do not substitute for executing the generated native binding on each supported platform.

## Failure strategy

The app should not silently switch calculation engines after a native calculation failure, because that could hide a bridge defect. A fallback may be selected once at startup for unsupported targets such as Web or when the native bridge is intentionally unavailable. An incompatible native bridge must fail closed before selection. The selected engine should remain stable for the session and be visible in diagnostics.

## Versioning

Generated bindings and bridge DTOs are tied to a bridge protocol version. Breaking changes must update the protocol version, source declarations, documentation, and parity fixtures together. Capability declarations are also repository-validated so Rust, Flutter, and documentation cannot silently disagree.
