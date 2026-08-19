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

Prefer indexed maps for repeated stable-ID lookup after the catalog grows enough to justify them. Keep correctness and deterministic decimal behavior before micro-optimization.

## Flutter hot paths

- Avoid rebuilding the entire app on each numeric keystroke.
- Debounce only work that is actually expensive; do not add artificial delays.
- Virtualize large search/history lists.
- Keep persistence off critical frame work where platform APIs are asynchronous.
- Cache immutable catalog metadata at an appropriate service boundary.

## Benchmarks

Rust benchmark targets should be added once the core is stable, with representative catalog and batch sizes. Record machine/toolchain context alongside performance conclusions.

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
