# Architecture

## Overview

UnitFlow is a small monorepo with two deliberately separated layers:

- `rust/` — precision-focused conversion domain engine.
- `app/` — Flutter presentation layer and dependency-free Dart adapter.

The separation keeps conversion rules independent from UI code and makes it possible to replace the temporary Dart adapter with a native/WASM Rust bridge without redesigning the screens.

## Rust core

The Rust crate contains:

- `catalog.rs` — unit/category metadata and search.
- `converter.rs` — decimal conversion, affine temperature handling, rounding, validation.
- `custom.rs` — validated affine custom units.
- `error.rs` — typed error model.
- `src/bin/unitflow.rs` — command-line interface.
- `tests/` — regression coverage.

Built-in linear units convert through a category base unit. Temperature uses explicit affine transformations. The Rust core uses `rust_decimal` to avoid ordinary binary floating-point drift for stored decimal constants and supported arithmetic.

## Flutter app

The frontend contains:

- `core/` — lightweight unit model, local catalog, and conversion adapter.
- `state/` — application state, recent history, favorites, precision settings, batch operations.
- `screens/` — page-level layout.
- `widgets/` — searchable unit picker, converter card, history, batch and settings UI.

No account, backend, analytics service, or network API is required for static conversions.

## Bridge direction

The stable bridge milestone will expose Rust conversion functions through generated native bindings on mobile/desktop and WebAssembly on web. Golden fixtures will compare Rust and Dart adapter results until the adapter can be removed or retained only as an emergency development fallback.

## Data policy

Current favorites and history are session-local only. Future persistence must remain local by default, have an explicit schema version, and avoid collecting personal information.
