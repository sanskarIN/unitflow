# What Changed

## Current milestone

**UnitFlow 0.1 foundation — implementation and validation**

Date: 2026-08-19
Working branch: `chatgpt/unitflow-complete-20260819`
Target branch: `main`

## Implemented

### Rust core

- Added `unitflow-core` Rust crate.
- Added high-precision decimal conversion using `rust_decimal`.
- Added explicit rounding modes.
- Added affine temperature conversion.
- Added validated affine custom units.
- Added searchable built-in catalog with aliases and descriptions.
- Added 12 conversion categories: length, mass, temperature, time, area, volume, speed, data, pressure, energy, power, angle.
- Added command-line conversion interface and unit listing.
- Added Rust regression tests.

### Flutter frontend

- Added dependency-light Flutter application.
- Added Material 3 responsive UI.
- Added category selector.
- Added searchable unit picker.
- Added value input, live conversion, swap, copy result, precision controls, scientific notation.
- Added session favorite conversion pairs.
- Added recent conversion history.
- Added batch conversion and copy workflow.
- Added educational unit descriptions and conversion explanation.
- Added accessibility semantics and system light/dark theme support.
- Added Flutter conversion tests and UI smoke test.

### Build and tooling

- Added Flutter platform bootstrap scripts for Unix-like shells and Windows PowerShell.
- Added `Makefile` quality commands.
- Added `.gitignore`, `.editorconfig`, and `.gitconfig.example`.
- Added GitHub Actions CI for Rust check/tests and Flutter analyze/tests.
- Added bug report, feature request, and pull request templates.

### Documentation

- Added contribution, security, support, code of conduct, changelog, and roadmap documents.
- Added architecture, setup, testing, release, accessibility, and performance guides.
- Added app-specific and Rust-core-specific README files.

## Important architecture note

The Rust crate is the precision-focused authoritative conversion engine. The current Flutter UI uses a dependency-free Dart conversion adapter so the application can execute immediately without a generated native binding. Direct Rust-to-Flutter native/WebAssembly bridge integration is explicitly scheduled in `ROADMAP.md`; parity must be maintained until that bridge replaces the adapter.

## Validation status

- Static code review: in progress.
- GitHub Actions validation: pending pull request run.
- No validation result is recorded as passing until the workflow completes successfully.

## Commit identity note

The requested preferred commit email is `sanskarin@outlook.in`. The GitHub connector used for repository writes does not expose an author/committer email field, so connector-created commits use the identity GitHub assigns to the authenticated operation. `.gitconfig.example` and `CONTRIBUTING.md` preserve the requested email for normal local Git commits.

## Known limitations / next tasks

1. Run CI and correct any compile, analyzer, or test failures.
2. Merge the validated branch to `main`.
3. Add direct Rust native/WASM bridge in the next milestone.
4. Add local persistence for favorites/history/pinned pairs in a later milestone.
5. Add shared golden fixtures for Rust/Dart parity before expanding conversion constants further.

## Recent commit themes

The branch intentionally uses many focused commits for repository scaffolding, Rust core features, Flutter features, tests, documentation, CI, templates, fixes, and tooling.
