# Architecture

## Goals

UnitFlow separates conversion correctness from presentation so the same domain engine can serve multiple platforms and remain independently testable.

## Top-level structure

```text
crates/unitflow_core/
  Rust source of truth for categories, units, validation, conversion, search,
  notation, custom affine units, and serializable domain results.

apps/unitflow_app/
  Flutter presentation, adaptive layout, accessibility, local persistence,
  onboarding/settings, import/export orchestration, and platform integration.

docs/
  Architecture decisions, setup, testing, release, accessibility,
  performance, and troubleshooting guidance.
```

## Rust domain core

The core uses decimal arithmetic and a base-unit model. A unit maps to the category base using:

```text
base = input * scale + offset
```

The inverse conversion is:

```text
output = (base - target.offset) / target.scale
```

This supports ordinary multiplicative conversions and affine conversions such as temperature without embedding special-case UI rules.

Primary modules:

- `model` — category/unit identifiers and validated unit definitions.
- `catalog` — built-in unit metadata and search.
- `converter` — precision-safe conversion service and batch conversion.
- `custom_unit` — validation for user-defined affine units.
- `notation` — plain/scientific/engineering formatting helpers.
- `error` — centralized typed domain failures.

The Rust crate does not depend on Flutter, platform storage, or network services.

## Flutter application

Flutter follows feature-oriented layering:

```text
lib/
  app/                app shell, routing, theme
  core/               shared formatting, persistence contracts, widgets
  features/converter/ converter domain bridge + presentation
  features/library/   searchable catalog/favorites
  features/settings/  appearance/privacy/about
```

Widgets should not implement conversion formulas. A `ConversionEngine` abstraction lets the UI use a platform bridge while keeping tests deterministic.

## Persistence

Preferences, recents, favorites, pins, and custom units are local user data. Persistence implementations must:

- version serialized schemas;
- validate imported data before replacing local state;
- write atomically where supported;
- tolerate unknown future fields when safe;
- avoid network synchronization unless explicitly introduced later.

## Rust ↔ Flutter boundary

ADR-0001 chooses Rust as the authoritative conversion engine and Flutter as the UI. The bridge is intentionally a boundary rather than shared mutable state. Bridge DTOs should be serializable, stable, and free of UI-specific types.

## Error handling

Rust returns typed errors with safe display text. Flutter translates those errors into actionable validation or transient UI messages. Raw stack traces and internal details are for bounded diagnostics only.

## Security boundaries

Untrusted inputs include:

- numeric text;
- custom unit metadata;
- imported backup data;
- file paths chosen by users;
- future online catalog/provider responses.

Validation occurs before state mutation or conversion. No conversion feature requires authentication.

## Dependency direction

```text
Flutter UI -> application services -> conversion bridge contract
                                      |
                                      v
                                Rust domain core
```

Infrastructure implements contracts; domain modules do not import presentation modules.

## Architecture change process

Non-trivial changes to persistence format, bridge technology, security model, or domain calculation strategy require an ADR under `docs/adr/`.
