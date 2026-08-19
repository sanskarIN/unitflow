# Testing Strategy

UnitFlow treats conversion correctness as a core product requirement.

## Rust quality gates

Run:

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace
```

Coverage priorities:

- category and unit validation;
- source/target category mismatch handling;
- multiplicative and affine conversion accuracy;
- zero/negative/large/small decimal values;
- round-trip conversion tolerances where exact decimal factors permit it;
- search by name, symbol, and alias;
- custom-unit validation;
- scientific/engineering notation edge cases;
- batch conversion order and error behavior.

## Flutter quality gates

Run:

```bash
cd apps/unitflow_app
flutter pub get
flutter analyze
flutter test
```

Coverage priorities:

- converter input validation;
- source/target selection and swap;
- responsive layout at representative widths;
- theme switching;
- favorites/pin/history state behavior;
- settings and About page content;
- semantics for major controls;
- custom-unit form validation;
- import/export failure states.

## Integration and end-to-end tests

Primary journeys should eventually cover:

1. launch the app offline;
2. select a category and pair;
3. enter a decimal value;
4. observe a correct conversion;
5. swap units;
6. favorite or pin the pair;
7. restart and verify persisted state;
8. create a valid custom unit and use it;
9. reject an invalid imported backup without corrupting local state;
10. export user data and restore it into a clean profile.

## Property/fuzz testing

Useful invariants include:

- converting a value from a unit to itself returns the same value;
- for valid units A/B and representable decimals, A→B→A remains within the defined rounding policy;
- invalid scales (zero/negative when prohibited) never construct a custom unit;
- parsers never panic on arbitrary Unicode input.

Fuzzing should be isolated from normal CI time budgets unless a short smoke target is maintained.

## Regression policy

Every confirmed defect should receive a failing regression test before or with the fix when practical.

## CI policy

CI fails on formatting, lint, analysis, tests, security checks, or build failures. A skipped platform check must be explicit rather than silently treated as success.
