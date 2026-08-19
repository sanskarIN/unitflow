# Testing Strategy

UnitFlow treats conversion correctness as a core product requirement.

## One-command local audit

From the repository root:

```bash
bash tool/check.sh
```

The script runs the same primary repository, Rust, and Flutter quality gates used by CI. When the pinned bridge generator is installed, it also checks generated bridge cleanliness.

## Repository safety tests

Run the dependency-free repository utility tests with:

```bash
cd tool
python3 -m unittest discover -p 'test_*.py'
```

The utility suite covers duplicate JSON-key detection, release/source version consistency, Flutter numeric bundle-version policy, About-version synchronization, Flutter Rust Bridge codegen pin consistency, and release-tag validation helpers.

CI also validates shell/Python syntax, runs `python3 tool/check_versions.py`, scans tracked files for common credential signatures, validates tracked JSON/ARB files as UTF-8 JSON with unique object keys, and verifies internal Markdown targets.

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
- checked arithmetic overflow behavior;
- round-trip conversion invariants where exact decimal factors permit it;
- search by name, symbol, alias, and descriptive metadata where supported;
- custom-unit validation;
- scientific/engineering notation edge cases;
- batch conversion order and error behavior;
- Rust↔Flutter bridge DTO/endpoint behavior.

`crates/unitflow_core/tests/properties.rs` uses property-based tests for identity conversion, exact metric round trips, and batch target ordering across generated values.

`crates/unitflow_core/tests/parity_coverage.rs` verifies that the shared conversion-vector corpus covers every UnitFlow category and all six rounding modes.

## Shared Rust/Dart/bridge parity vectors

`test_vectors/conversions.json` is the language-boundary regression corpus. It includes representative conversions across:

- length;
- area;
- volume;
- mass;
- speed;
- pressure;
- energy;
- power;
- angle;
- data size;
- frequency;
- time;
- temperature;
- all six explicit rounding modes.

The Rust core, Dart fallback, and Rust bridge consume the same expected-output records. Adding a category or changing conversion/rounding behavior should update the shared vectors instead of creating unrelated language-specific expectations.

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

- exact-decimal parsing/arithmetic without binary floating point;
- Rust-compatible decimal coefficient/scale boundaries;
- rejection of fallback input and exact arithmetic intermediates that exceed the native decimal domain;
- converter input validation;
- source/target selection and swap;
- canonical recent-history persistence and locale-safe reopening;
- primary app/onboarding journey;
- responsive layout at representative widths;
- theme switching;
- favorites/pin/history state behavior;
- settings and About page content;
- semantics for major controls;
- custom-unit form validation and Rust-compatible formula bounds;
- backup schema round trips and rejected imports;
- runtime duplicate-key and JSON-nesting rejection;
- strict backup collection/property/identifier validation;
- custom-unit normalization and collection limits;
- batch CSV escaping.

## Rust–Flutter bridge tests and generation

Bridge source tests cover:

- core version exposure;
- built-in catalog DTOs;
- single conversion through decimal strings;
- ordered batch conversion;
- empty batch behavior;
- all-or-error invalid batch targets;
- explicit notation/rounding formatting;
- category-scoped search;
- invalid decimal input;
- the complete shared conversion-vector corpus.

The bridge is generated from checked-in Rust API source:

```bash
cargo install flutter_rust_bridge_codegen --version 2.12.0 --locked
bash tool/generate_bridge.sh
cargo check --workspace --all-features
cd apps/unitflow_app
flutter analyze --fatal-infos --fatal-warnings
```

CI runs generation as an independent job so generated APIs cannot silently drift from bridge source. Required generated files must be committed; modified and untracked generated-source drift is a failure.

The final native application adapter is intentionally gated on inspecting the actual generated Dart API. Do not substitute guessed generated identifiers for this evidence-producing step.

## Integration and end-to-end journeys

Primary journeys are tracked as layered widget/integration coverage:

1. launch the app offline;
2. complete or skip onboarding;
3. select a category and pair;
4. enter a decimal value;
5. observe a correct conversion;
6. swap units;
7. favorite or pin the pair;
8. submit a conversion and reopen the exact recorded value/pair from history;
9. restart and verify persisted state;
10. create a valid custom unit and use it;
11. reject an invalid imported backup without corrupting local state;
12. export user data and restore it into a clean profile;
13. copy deterministic batch CSV results.

Device-level integration tests are added when a platform runner is available; widget/domain tests remain deterministic and do not require production credentials.

## Fuzz testing

Cargo-fuzz harnesses live under `fuzz/` and are intentionally outside the normal workspace so release builds do not pull fuzz dependencies.

Install cargo-fuzz and run, for example:

```bash
cargo install cargo-fuzz
cd fuzz
cargo fuzz run catalog_search
cargo fuzz run decimal_bridge_inputs
```

The harnesses exercise arbitrary UTF-8 catalog search input and valid parsed decimal values through notation formatting. Fuzzing must never be converted into a fake passing CI result when the tool is unavailable.

## Regression policy

Every confirmed defect should receive a failing regression test before or with the fix when practical.

## CI policy

CI fails on repository utility/version checks, formatting, lint, analysis, tests, generated bridge verification, security checks, or build failures. A skipped platform check must be explicit rather than silently treated as success.
