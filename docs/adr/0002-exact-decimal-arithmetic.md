# ADR 0002: Use exact base-10 decimal arithmetic

- Status: Accepted
- Date: 2026-08-19

## Context

Unit conversion often uses decimal constants that are exact by definition. Routing those constants or user-entered values through binary floating point can introduce representation artifacts that become visible during repeated conversion, formatting, or boundary tests.

UnitFlow also needs deterministic behavior across Rust and Flutter/Web environments.

## Decision

The Rust core uses `rust_decimal::Decimal` for conversion values and unit constants.

The Dart compatibility engine uses a base-10 representation backed by `BigInt`, storing a coefficient and decimal scale. Decimal input, persistence, batch export, and the future native bridge preserve decimal text rather than using `double` as the interchange format.

Rounding is explicit and bounded. Persisted application precision is limited to 28 decimal places to match the Rust domain contract.

## Consequences

Positive:

- common decimal conversions remain reproducible;
- exact defined constants can be represented without binary floating-point noise;
- parity testing between Rust and Dart is practical;
- exported values have a stable canonical decimal form.

Costs:

- arithmetic code is more complex than using `double`;
- extremely large exponents must be bounded to prevent pathological allocation;
- values outside the selected decimal implementation's range return errors instead of silently becoming infinities.

## Rejected alternatives

### IEEE-754 `f64` / Dart `double`

Rejected as the authoritative conversion representation because many finite decimal values cannot be represented exactly in binary floating point.

### Arbitrary rational numbers everywhere

Provides excellent exactness for multiplicative factors but complicates affine decimal display, serialization, formatting, and interoperability. It remains a possible specialized internal technique if future requirements justify it.
