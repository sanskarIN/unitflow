# Performance

UnitFlow should remain responsive with a large unit catalog and batch conversion workloads, but optimization must be driven by measurement.

## Initial budgets

These are engineering targets rather than marketing guarantees:

- Single static conversion should be effectively instantaneous relative to UI frame budgets.
- Search over the built-in catalog should not block the Flutter UI thread perceptibly.
- Typing into the converter should not trigger unnecessary persistence writes or expensive rebuilds.
- Batch conversion should scale linearly with the number of requested target units.
- Startup should avoid network requests for core functionality.

## Rust hot paths

Likely measurable paths:

- catalog lookup by stable ID;
- text search across symbols/aliases;
- conversion through base units;
- batch conversion;
- notation formatting.

The catalog already uses a stable-ID hash map for direct lookup. Keep correctness and deterministic decimal behavior before micro-optimization.

## Flutter hot paths

- Avoid rebuilding the entire app on each numeric keystroke where a smaller listener boundary is practical.
- Debounce only work that is actually expensive; do not add artificial delays.
- Virtualize large search/history lists.
- Keep persistence off critical frame work where platform APIs are asynchronous.
- Cache immutable catalog metadata at an appropriate service boundary.

## Developer micro-benchmark

A dependency-free Rust smoke benchmark lives at `crates/unitflow_core/examples/benchmark.rs`.

Run it with:

```bash
cargo run --release -p unitflow_core --example benchmark
```

It performs a warmup and then measures 100,000 representative mile-to-kilometer conversions. The output reports elapsed time and an approximate nanoseconds-per-conversion value.

This result is intentionally not committed as a universal performance claim. Record CPU, operating system, Rust version, power mode, and commit when comparing measurements across changes.

For statistically rigorous performance work, add a dedicated benchmark harness only when there is a concrete regression or optimization question to answer.

## Memory

Avoid duplicating large catalogs across layers unnecessarily. Imported files must have bounded parsing/allocation behavior before being accepted.

## Regression process

For a reported performance regression:

1. reproduce with a deterministic workload;
2. profile before changing code;
3. identify the dominant path;
4. add a benchmark or measurable regression guard when practical;
5. optimize without weakening validation/precision;
6. record before/after results here or in release notes.
