# Testing Strategy

UnitFlow treats conversion correctness, persistence integrity, bridge-contract parity, accessibility safeguards, and repository/documentation integrity as core product requirements.

## One-command verification

From the repository root:

```bash
bash scripts/verify.sh
```

On PowerShell:

```powershell
./scripts/verify.ps1
```

Both scripts run the repository validator tests and integrity checks before the Rust and Flutter quality gates, including localization generation.

## Repository integrity gates

Run from the repository root:

```bash
python3 -m unittest discover -s scripts/tests -p 'test_*.py'
python3 scripts/check_repository_inventory.py
python3 scripts/check_platform_support.py
python3 scripts/check_accessibility_contract.py
python3 scripts/check_markdown_links.py
python3 scripts/check_release_consistency.py
python3 scripts/check_repository_hygiene.py
```

These checks cover:

- regression tests for the dependency-free repository validators;
- exact `git ls-files` parity with the exhaustive documented repository inventory;
- six-platform generation/build/project-set/Web compatibility;
- source-level reduced-motion policy, modal-surface coverage, converter semantic safeguards, accessibility smoke coverage, and verification wiring;
- repository-local Markdown file targets;
- Cargo/Flutter/About version consistency;
- Cargo minimum-Rust-version versus setup-documentation parity;
- changelog coverage for the current version;
- local-state schema documentation parity;
- Rust↔Flutter bridge protocol/capability/batch-limit parity;
- complete critical repository/configuration/documentation file presence;
- tracked `.env`, signing material, generated localization output, and build-output hygiene.

For the current source target, validate the intended release tag with:

```bash
python3 scripts/check_release_tag.py v2.0.12
```

Use the actual intended tag for future versions. The validator requires it to equal `v` plus the Cargo workspace version exactly.

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
- custom-unit validation and alias resource bounds;
- scientific/engineering notation edge cases;
- batch conversion order and error behavior;
- educational metadata references real base units;
- bridge rounding-mode serialization identifiers;
- direct execution of the shared versioned bridge parity fixture;
- Rust bridge protocol/capability metadata, canonical decimal DTO enforcement, safe failure-code mapping, ordered/bounded batch responses, unit-ID validation, and camelCase serialization.

The Rust suite includes catalog-wide identity and round-trip invariants plus search-ranking regression tests. `bridge_service.rs` exercises the generator-facing Rust protocol service independently of any future binding generator. The dense built-in catalog data table is deliberately excluded from rustfmt rewriting so conversion constants remain compact and reviewable; executable logic and tests remain under normal formatting checks.

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
- semantics for major controls and toggle state;
- reduced-motion policy for modal/route transitions;
- custom-unit validation;
- import/export failure states and consistent import bounds across repositories;
- persistence ordering for reset/save operations and safe reset-failure reporting;
- recent-history reference/category/input bounds while retaining locale-formatted original text;
- canonical native-bridge decimal/unit/precision DTO validation;
- startup bridge protocol/capability negotiation and batch bounds;
- execution of the shared bridge parity fixture across every supported rounding mode;
- CSV/TSV batch export escaping;
- structured-log redaction;
- schema migration and local collection cleanup;
- controller/repository primary-state survival across restart, backup/import, custom-unit reuse, and reset.

`exact_decimal_properties_test.dart` uses deterministic generated inputs to exercise canonical round trips, comparison antisymmetry, rounding idempotence, and malformed-input bounds without adding a fuzzing dependency to the normal test suite.

`navigation_smoke_test.dart` checks that the main Convert, Batch, Library, History, and Settings destinations remain reachable through the adaptive shell.

`accessibility_smoke_test.dart` locks the centralized reduced-motion policy and verifies that the converter pin action exposes semantic on/off state. It is source/widget evidence only; it does not replace TalkBack, VoiceOver, keyboard/focus, contrast, touch-target, or large-text review on real release-candidate platforms.

`scripts/check_accessibility_contract.py` complements widget tests without needing Flutter. It scans tracked Flutter source for modal dialog/bottom-sheet calls and requires the shared `AppMotion` policy, prevents reintroduction of a keystroke-driven converter live region, requires semantic pin/selector safeguards, and verifies that Bash, PowerShell, CI, release, platform materialization, and repository hygiene continue to enforce the accessibility contract.

`persisted_primary_journey_test.dart` exercises a broader controller/repository journey: user settings, favorites, pins, history, custom units, restart persistence, backup/import, post-restart conversion, and reset. It is intentionally classified as source-level integration-style coverage rather than native end-to-end evidence.

## Shared bridge parity

`fixtures/bridge_parity_v1.json` is the common executable fixture for both Rust and Dart. The two test suites must deserialize that file directly rather than copying its vectors into language-specific tests. The fixture currently includes representative SI/affine/data/time conversions and every supported rounding mode.

The fixture protocol version must match `docs/bridge-protocol.md`; `scripts/check_release_consistency.py` additionally locks the Rust/Flutter protocol declarations, required capabilities, and shared 256-target batch ceiling.

The Rust source bridge service has additional direct contract coverage in `crates/unitflow_core/tests/bridge_service.rs`. Generated binding parity remains a separate release requirement and must execute through the actual native boundary once that integration exists.

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

Controller/repository coverage now proves several persistence-focused parts of this journey at source-test level. Full UI integration still needs interactions through rendered screens/widgets, and native end-to-end automation should be added after reviewed platform scaffolding and generated bindings are committed. Source-level and widget tests must not be described as proof that native release builds pass.

## Cross-platform release builds

`.github/workflows/platform-smoke.yml` retains its historical filename, but it is now a committed-first release-mode build matrix for Android, Web, Linux, Windows, macOS, and iOS. When a platform directory is not yet committed during the transition period, the job can generate that target before compiling so compatibility is not silently skipped. Each target uploads its build artifact; iOS intentionally builds with `--no-codesign`.

These jobs are useful compilation/toolchain evidence, but successful workflow definitions alone do not prove a release candidate passed. Release verification requires reviewing actual workflow executions against the final committed platform projects and then completing signing/notarization/store-specific checks where applicable. See `docs/platform-smoke.md` and `docs/platform-support.md` for the exact evidence boundary.

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

Every confirmed defect should receive a failing regression test before or with the fix when practical. Test-only repositories/adapters must enforce the same externally relevant parsing and import limits as production adapters so passing tests cannot rely on weaker validation.

A repository-structure change must update `docs/repository-inventory.md` in the same change. This is enforced automatically rather than relying on review memory.

## CI policy

CI fails on repository-inventory/integrity validation, accessibility source-contract validation, validator regression tests, formatting, lint, localization generation, analysis, or test failures. Security scanning, dependency review, cross-platform release builds, and release packaging run in their respective workflows. A skipped platform check must be explicit rather than silently treated as success.
