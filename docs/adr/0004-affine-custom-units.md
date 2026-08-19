# ADR-0004: Affine custom-unit formulas instead of executable expressions

- Status: Accepted
- Date: 2026-08-19

## Context

UnitFlow allows users to define units that are not included in the built-in catalog. A general expression language would increase flexibility, but it would also introduce parsing complexity, ambiguous precedence, unsafe evaluation risks, harder validation, and difficult cross-language parity between Rust and Flutter.

Most conventional unit relationships needed by an offline converter are multiplicative or affine.

## Decision

Represent every custom unit relative to its category base unit using:

```text
base_value = input_value * scale + offset
```

Requirements:

- `scale` is a validated decimal strictly greater than zero;
- `offset` is a validated decimal;
- identifiers use a restricted stable character set;
- custom identifiers cannot collide with built-in or other custom identifiers;
- category membership is explicit and cross-category conversion is rejected;
- imported custom definitions pass the same validation as interactively created definitions;
- no arbitrary code, script, function call, or dynamic expression is evaluated.

The Rust core owns the authoritative domain validation. The deterministic Dart fallback mirrors the same model for web/tests/graceful bridge startup.

## Consequences

### Positive

- deterministic high-precision conversion;
- safe imported definitions;
- straightforward round-trip inversion through a shared base unit;
- consistent implementation across Rust and Dart;
- no expression interpreter attack surface.

### Trade-offs

- non-affine domain-specific formulas cannot be represented as custom units;
- advanced formula support would require a separate, deliberately designed feature rather than overloading the unit model.

## Follow-up

If non-affine conversions become a real product requirement, introduce a restricted declarative formula specification with a versioned grammar, complexity limits, fuzz tests, and explicit ADR rather than executing user-provided code.
