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

Measurable paths include:

- catalog lookup by stable ID;
- text search across symbols/aliases;
- conversion through base units;
- batch conversion;
- notation formatting.

The catalog already keeps a stable-ID hash index for repeated direct lookup. Keep correctness and deterministic decimal behavior before micro-optimization.

## Reproducible profiling harness

A dependency-free release-mode harness is available at `crates/unitflow_core/examples/profile.rs`. Run:

```bash
bash tool/profile_core.sh
```

or directly:

```bash
cargo run -p unitflow_core --example profile --release
```

The harness measures repeated:

- stable-ID lookup;
- category-scoped search;
- single conversion;
- length-category batch conversion.

It prints iteration counts, elapsed milliseconds, approximate nanoseconds per iteration, catalog size, and batch target count. It intentionally does **not** enforce universal timing thresholds because GitHub-hosted runners and developer machines vary. Performance conclusions must record CPU/OS/toolchain context and compare equivalent workloads on equivalent hardware.

The harness uses `std::hint::black_box` to reduce trivial optimizer elimination. It is a profiling smoke harness, not a substitute for a statistically rigorous microbenchmark framework if future regressions require one.

## Flutter hot paths

- Avoid rebuilding unrelated application state on each numeric keystroke.
- Debounce only work that is actually expensive; do not add artificial delays.
- Virtualize large search/history lists.
- Keep persistence off critical frame work where platform APIs are asynchronous.
- Cache immutable catalog metadata at an appropriate service boundary.
- Keep core static conversion free of network startup dependencies.

## Memory

Avoid duplicating large catalogs across layers unnecessarily. Imported files have bounded parsing/allocation behavior before they are accepted.

## Regression process

For a reported performance regression:

1. reproduce with a deterministic workload;
2. profile before changing code;
3. identify the dominant path;
4. add or extend a measurable regression workload when practical;
5. optimize without weakening validation/precision;
6. record before/after results with machine/toolchain context.

## Release evidence

Before a stable release, save representative profiling output in the release verification record. Never claim a device/platform performance target as passed unless it was measured on that device/platform class.
