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

The bridge exposes safe string/primitive DTOs for:

- single conversion;
- batch conversion;
- built-in unit listing;
- catalog search;
- explicit rounding-mode selection.

Decimal values cross the FFI boundary as strings. Rust parses and validates them before executing domain behavior. This avoids silently converting high-precision decimal input through a binary floating-point representation.

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
4. native application builds;
5. installed app executes a conversion through the intended native boundary;
6. web fallback executes deterministic Dart conversion without a native library.

Until steps 4–5 have platform evidence, native bridge packaging is not considered release-verified.

## API change policy

When bridge-visible Rust types/functions change:

1. update core/bridge regression tests;
2. regenerate bindings with the pinned codegen version;
3. run `cargo fmt`, `cargo clippy`, and workspace tests;
4. run Flutter generation, formatting, analysis, and tests;
5. confirm no modified or untracked generated source remains;
6. update this document and `what_changed.md` when integration behavior changes.

## Troubleshooting

If generation fails, first verify the installed `flutter_rust_bridge_codegen` version and run `flutter pub get` in `apps/unitflow_app`. See `docs/troubleshooting.md` for the wider toolchain checklist.
