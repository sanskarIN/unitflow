# ADR-0003: Versioned validated local backups

- Status: Accepted
- Date: 2026-08-19

## Context

UnitFlow stores preferences, favorites, pinned pairs, recent conversions, and custom units locally. Users need an explicit way to move or restore this state without requiring an account or a hosted synchronization service.

Imports are untrusted input. A malformed or future-version document must not partially corrupt valid local state.

## Decision

Use a small versioned UTF-8 JSON document for portable backup and restore.

The root object carries a mandatory `schemaVersion`. Version 1 is documented by `schemas/unitflow-backup-v1.schema.json` and `docs/data-format.md`.

Import follows validate-then-replace semantics:

1. enforce a bounded input size;
2. parse JSON;
3. validate the supported schema version and all fields;
4. validate custom-unit definitions and identifier collisions;
5. construct a complete replacement state and conversion catalog;
6. persist only after all validation succeeds.

Unknown future schema versions are rejected. They are never silently treated as the current version.

File access is user initiated through platform pickers where supported. Clipboard import/export remains an explicit fallback. UnitFlow does not request broad filesystem access for backup operations.

## Consequences

### Positive

- no account or cloud service is required;
- backup data is human-readable and portable;
- validation can be tested deterministically;
- migrations have an explicit version boundary;
- failed imports do not require partial rollback logic.

### Trade-offs

- future schema changes require explicit migration work;
- JSON is larger than a compact binary format, though current state is intentionally small;
- file save capabilities vary by Flutter target, so the UI must retain a portable fallback.

## Follow-up

When adding a schema version, add migration tests before enabling writes in the new format and keep the previous schema documentation available for compatibility review.
