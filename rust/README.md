# UnitFlow Rust Core

The Rust crate provides UnitFlow's precision-focused conversion engine.

## Run tests

```bash
cargo test
```

## CLI

Convert a value:

```bash
cargo run -- 1 km m 8
```

List built-in units:

```bash
cargo run -- --list
```

## Library example

```rust
use unitflow_core::{convert_str, ConversionOptions};

let result = convert_str("1.25", "km", "m", ConversionOptions::default())?;
assert_eq!(result.value.to_string(), "1250.00");
# Ok::<(), unitflow_core::ConversionError>(())
```

## Design

Linear units convert through a base unit using decimal factors. Temperature uses explicit affine transformations. Custom units use validated formulas of the form:

```text
base = value * factor + offset
```

The crate avoids network access and forbids unsafe Rust through crate lint configuration.
