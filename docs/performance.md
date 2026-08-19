# Performance

UnitFlow's default conversion path is intentionally local and lightweight.

## Performance goals

- Single conversions should feel immediate on supported devices.
- Unit search should remain responsive for the complete built-in catalog.
- Batch conversion should avoid blocking work proportional to UI rendering.
- App startup should not require network access.
- The Rust core should avoid unnecessary allocation in hot conversion paths.

## Measurement

For Rust, use release builds when comparing performance:

```bash
cargo build --manifest-path rust/Cargo.toml --release
```

For Flutter, use profile/release modes and the Flutter performance tooling appropriate to the target platform.

## Budgets for 1.0

The project intends to establish reproducible device-class benchmarks before 1.0 covering:

- cold startup
- first conversion latency
- 1,000-value batch conversion
- full-catalog search latency
- memory footprint after repeated conversions

Budgets should be measured on documented hardware rather than guessed, then enforced where CI runners can produce stable results.
