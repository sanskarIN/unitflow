# Testing Strategy

UnitFlow treats conversion correctness as a core product requirement.

## One-command verification

From the repository root:

```bash
bash scripts/verify.sh
```

On PowerShell:

```powershell
./scripts/verify.ps1
```

Both scripts run the Rust and Flutter quality gates, including localization generation.

## Rust quality gates

Run:

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-features
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
- batch conversion order and error behavior;
- educational metadata references real base units.

The Rust suite includes catalog-wide identity and round-trip invariants plus search-ranking regression tests.

## Flutter quality gates

Run:

```bash
cd apps/unitflow_app
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

Coverage priorities:

- exact-decimal parser/arithmetic and all rounding modes;
- converter input validation;
- source/target selection and swap;
- responsive/adaptive navigation;
- theme switching;
- favorites/pin/history state behavior;
- settings and About page content;
- semantics for major controls;
- custom-unit validation;
- import/export failure states;
- CSV/TSV batch export escaping;
- structured-log redaction;
- schema migration and local collection cleanup.

`exact_decimal_properties_test.dart` uses deterministic generated inputs to exercise canonical round trips, comparison antisymmetry, rounding idempotence, and malformed-input bounds without adding a fuzzing dependency to the normal test suite.

`navigation_smoke_test.dart` checks that the main Convert, Batch, Library, History, and Settings destinations remain reachable through the adaptive shell.

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
10. export user data and restore it into a clean profile;
11. copy a batch table and verify its delimiter/escaping;
12. restore a recent conversion from History.

Native end-to-end automation should be added after platform scaffolding is committed. Until then, source-level and widget tests must not be described as proof that native release builds pass.

## Property/fuzz testing

Useful invariants include:

- converting a value from a unit to itself returns the same value;
- for valid units A/B and representable decimals, A→B→A remains within the defined rounding policy;
- invalid scales (zero/negative when prohibited) never construct a custom unit;
- parsers reject oversized exponents and inputs;
- parsers never panic on arbitrary Unicode input.

Long-running fuzzing should be isolated from normal CI time budgets unless a short deterministic smoke target is maintained.

## Performance checks

Run the dependency-free Rust smoke benchmark with:

```bash
cargo run --release -p unitflow_core --example benchmark
```

Do not compare results across machines without recording the environment. See `docs/performance.md`.

## Regression policy

Every confirmed defect should receive a failing regression test before or with the fix when practical.

## CI policy

CI fails on formatting, lint, localization generation, analysis, or test failures. Security scanning and dependency review run in separate workflows. A skipped platform check must be explicit rather than silently treated as success.
