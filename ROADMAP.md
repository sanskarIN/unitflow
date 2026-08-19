# UnitFlow Roadmap

## 0.1 — Foundation

- Rust decimal conversion core
- Broad offline catalog
- Flutter Material 3 interface
- Search, swap, batch, favorites, history, precision, scientific notation
- Tests, CI, docs, contribution and security policies

## 0.2 — Native bridge

- Connect Flutter to the Rust core through a generated, audited native bridge
- Add Android/iOS native library packaging
- Add desktop native library packaging
- Add WebAssembly bridge for web builds
- Golden cross-engine regression tests so Dart adapter and Rust output stay aligned

## 0.3 — Personalization

- Persist favorites and recent conversions locally
- Pinned conversion pairs
- User-defined affine units with validation UI
- Import/export local settings
- Locale-aware number formatting and input normalization

## 0.4 — Advanced workflows

- CSV batch import/export
- Engineering notation and significant-figure modes
- Formula explanations with traceable conversion constants
- Expanded scientific catalog
- Keyboard shortcuts and command palette on desktop/web

## 1.0 — Stable release

- Stable cross-platform Rust bridge
- Completed accessibility audit
- Performance budgets enforced in CI
- Full release automation and signed artifacts
- Conversion constant provenance audit
- Versioned migration policy for local settings
