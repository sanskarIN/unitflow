# Rust ↔ Flutter Bridge

UnitFlow keeps conversion-domain behavior in Rust and exposes a narrow Flutter Rust Bridge (FRB) API through `crates/unitflow_bridge`.

## Components

- `crates/unitflow_core` — authoritative catalog, validation, conversion, search, batch behavior, decimal precision, and rounding.
- `crates/unitflow_bridge` — FRB-safe DTOs/functions wrapping the core.
- `tool/generate_bridge.sh` — reproducible binding-generation command.
- `apps/unitflow_app/lib/src/rust` — generated Dart binding output after generation.

The app also includes a deterministic Dart exact-decimal implementation. It is used for web/testing/fallback paths and prevents the UI from depending on binary floating-point arithmetic while native integration is unavailable.

## Generator version

The repository currently pins Flutter Rust Bridge `2.12.0` in workspace/app dependencies and installs the matching code generator in CI. Do not silently generate bindings with a materially different FRB version and commit the result.

Install the expected generator:

```bash
cargo install flutter_rust_bridge_codegen --version 2.12.0 --locked
```

Then generate bindings:

```bash
bash tool/generate_bridge.sh
```

## Bridge API

The Rust bridge source currently exposes synchronous FRB functions for:

- `bridge_version` — reports the authoritative core release version;
- `list_units` — returns built-in unit DTOs;
- `search_units` — searches the built-in catalog with an optional category and bounded result count;
- `convert_value` — converts one decimal-string value between two built-in units;
- `batch_convert_value` — converts one decimal-string source value to an ordered target-ID list and preserves target order;
- `format_value` — formats one decimal string using explicit notation, precision, and rounding.

Batch conversion is all-or-error at the Rust core boundary: if a requested target is invalid, the bridge does not return a misleading partial batch.

Decimal values cross the FFI boundary as strings. Rust parses and validates them before executing domain behavior. This avoids silently converting high-precision decimal input through a binary floating-point representation.

Bridge regression tests exercise single conversion, ordered batch conversion, empty batches, invalid batch targets, explicit notation formatting, category-scoped search, invalid decimal input, and the shared conversion parity corpus covering all categories and rounding modes represented by `test_vectors/conversions.json`.

## Custom units and native adapter strategy

The current bridge catalog is intentionally the built-in Rust catalog. Flutter user-created units are stored locally and merged into the Dart-side application catalog. Therefore a native production adapter must not blindly route every pair to the built-in-only Rust bridge.

The intended adapter boundary is hybrid:

1. initialize the generated native Rust library on supported native platforms;
2. use Rust bridge conversion for pairs where both unit IDs are built-in and the native bridge is available;
3. retain the deterministic exact-decimal engine for custom-unit pairs and for web/fallback operation;
4. preserve the same `ConversionEngine` interface so presentation code does not depend on generated FRB classes/functions directly;
5. fail back safely when native initialization/loading is unavailable rather than crashing startup.

Do **not** implement this adapter by guessing generated Dart identifiers. First let the pinned generator produce/normalize `apps/unitflow_app/lib/src/rust`, inspect the exact generated API, and only then add the adapter imports/calls. This rule prevents hand-written source from depending on code-generator names that have not actually been produced for the pinned version.

## Generated sources

Generated bindings are treated as derived **but intentionally tracked** sources. The audit-branch normalization workflow installs the pinned generator, regenerates bindings, runs formatting, and commits generated changes when needed. Generated files must still pass Rust and Flutter analysis before merge.

Generated FRB Dart files must not be added to `.gitignore`; otherwise a code-generation run could create required source that CI cannot review or reproduce from a clean checkout. Cleanliness checks use `git status --porcelain --untracked-files=all`, not only `git diff`, so newly generated untracked files are treated as drift.

Do not hand-edit generated bridge files. Change the Rust API or generator configuration instead.

## Native packaging

Binding generation alone is not the same as shipping a native library. Platform release validation must also prove that the generated application bundles/loads the Rust artifact correctly on each native target.

The release checklist therefore distinguishes:

1. Rust core compiles/tests;
2. FRB bindings generate;
3. generated Rust/Dart analyze;
4. the application adapter initializes and routes built-in conversion through the generated native API;
5. native application builds;
6. installed app executes a built-in conversion through the intended native boundary;
7. custom units continue through the deterministic application fallback path;
8. web fallback executes deterministic Dart conversion without requiring a native library.

Until native adapter and platform evidence exist for steps 4–6, native bridge runtime use is not considered release-verified.

## API change policy

When bridge-visible Rust types/functions change:

1. update core/bridge regression tests;
2. regenerate bindings with the pinned codegen version;
3. run `cargo fmt`, `cargo clippy`, and workspace tests;
4. run Flutter generation, formatting, analysis, and tests;
5. confirm no modified or untracked generated source remains;
6. inspect adapter compilation against the generated API;
7. update this document and `what_changed.md` when integration behavior changes.

## Troubleshooting

If generation fails, first verify the installed `flutter_rust_bridge_codegen` version and run `flutter pub get` in `apps/unitflow_app`. See `docs/troubleshooting.md` for the wider toolchain checklist.
