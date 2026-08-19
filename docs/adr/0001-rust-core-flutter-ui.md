# ADR-0001: Rust core with Flutter presentation

- Status: Accepted
- Date: 2026-08-19

## Context

UnitFlow targets Android, Windows, Linux, macOS, Web, and iOS-ready development while requiring high-precision reusable conversion logic. The project should keep business rules independently testable and avoid platform-specific formula duplication.

## Decision

Use a Rust library as the authoritative conversion/domain core and Flutter as the cross-platform presentation layer.

The Rust core owns:

- unit/category models;
- conversion formulas;
- decimal precision and rounding rules;
- catalog search behavior;
- custom-unit validation;
- reusable serializable domain results.

Flutter owns:

- responsive/adaptive UI;
- accessibility semantics and keyboard behavior;
- local settings/history/favorites orchestration;
- import/export platform integration;
- theming, onboarding, and About/support presentation.

The boundary will use explicit bridge DTOs and generated bindings where supported. UI tests may use a deterministic `ConversionEngine` test implementation so widget tests do not require a native library process.

## Consequences

### Positive

- Conversion rules are centralized and reusable.
- Rust tests can validate precision independently of Flutter.
- Flutter remains focused on product experience.
- Native targets can share one domain implementation.

### Trade-offs

- Rust↔Dart binding generation adds build complexity.
- Web may need a WASM-compatible bridge path distinct from native FFI.
- DTO compatibility becomes a versioned boundary.

## Rejected alternatives

### Dart-only domain

Simpler initial build, but conflicts with the chosen Rust-core project goal and would make Rust incidental rather than authoritative.

### Per-platform native implementations

Rejected because it duplicates formulas, increases drift risk, and makes cross-platform verification harder.

### Backend service for conversions

Rejected for core static conversion because it would weaken offline behavior, privacy, availability, and latency without a product need.
