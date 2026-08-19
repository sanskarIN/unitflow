# ADR-0002: Generated Rust–Flutter bridge with deterministic fallback

- Status: Accepted
- Date: 2026-08-19

## Context

ADR-0001 establishes Rust as UnitFlow's authoritative conversion domain and Flutter as the presentation layer. The two runtimes need a typed, reproducible boundary that works across supported native targets without moving conversion formulas into widgets.

Flutter tests and web development also need deterministic behavior when a compiled native Rust library is unavailable.

## Decision

Use `flutter_rust_bridge` for generated native bindings around the dedicated `unitflow_bridge` crate.

The bridge API exchanges decimal values as strings and exposes stable DTOs rather than binary floating-point values. The bridge remains thin: it delegates catalog, conversion, notation, and validation behavior to `unitflow_core`.

Keep `ExactConversionEngine` in Dart as a deterministic fallback/test engine. It mirrors the released catalog and affine conversion model, avoids binary floating point, and implements the same application-facing `ConversionEngine` contract.

Generated bridge code is reproducible from checked-in Rust API source and `tool/generate_bridge.sh`. Generated FFI glue is isolated from the `unitflow_core` crate; the domain crate continues to forbid unsafe Rust.

## Native startup policy

A production native build should initialize the generated bridge and prefer a Rust-backed implementation of `ConversionEngine`. If bridge initialization fails, the app may fall back to the deterministic Dart engine with a non-blocking diagnostic warning rather than making basic offline conversion unavailable.

Web may use the deterministic Dart engine until the Rust bridge has a tested WASM path. Static conversion semantics must remain consistent across engines and are protected by mirrored regression tests.

## Consequences

### Positive

- Rust remains the authoritative native domain implementation.
- Flutter presentation stays independent of FFI details.
- Decimal values do not lose precision at the language boundary.
- Widget tests do not need a platform-native dynamic library.
- Bridge generation and platform setup are reproducible scripts rather than undocumented manual steps.

### Trade-offs

- Built-in unit metadata is mirrored in the fallback and must be kept in sync until catalog generation is automated.
- Generated bindings add build dependencies and platform-specific packaging work.
- Native and fallback engine parity requires cross-engine regression tests.

## Follow-up

Automate bridge code generation in release/audit workflows, add the Rust-backed Flutter adapter once generated APIs are checked in, and add a parity test that compares representative conversion vectors between Rust and the deterministic fallback.
