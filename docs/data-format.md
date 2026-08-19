# Local Data and Backup Format

UnitFlow is offline-first. Static conversions require no account and no network request. User preferences and optional convenience data are designed to remain on the current device unless the user explicitly exports a backup.

## Stored data

The current local state contains:

- theme preference;
- notation preference;
- decimal-place preference;
- grouping preference;
- onboarding completion state;
- favorite unit identifiers;
- pinned unit pairs;
- bounded recent-conversion history;
- validated custom affine units.

The current schema version is **1**. Its machine-readable contract is published at `schemas/unitflow-backup-v1.schema.json`.

## Backup envelope

A backup is a UTF-8 JSON object. The root `schemaVersion` field is mandatory. UnitFlow validates the complete object before replacing the in-memory state; malformed or unsupported imports must not partially overwrite an existing profile.

Current safety bounds include:

- file/import text size: at most 1 MB;
- recent conversions: at most 100 accepted from an imported document, with the app normally retaining a smaller recent set;
- custom units: at most 200 accepted from an imported document;
- custom aliases: at most 32 per unit;
- decimal precision preference: 0–28 places;
- stable identifiers: lowercase ASCII letters, digits, `_`, and `-` only.

## Custom-unit formula

Custom units use an affine relationship instead of evaluating arbitrary executable expressions:

```text
base_value = input_value * scale + offset
```

The scale must be strictly positive. This design covers ordinary multiplicative units and temperature-like offsets without introducing an expression interpreter into imported user data.

## Import behavior

An import is rejected when, among other validation failures:

- JSON is malformed;
- the root is not an object;
- the schema version is unsupported;
- required settings have invalid types or ranges;
- a custom-unit identifier or formula is invalid;
- duplicate identifiers would collide with built-in or imported custom units;
- the import exceeds configured size/count limits.

The application should preserve the existing state when validation fails.

## Export behavior

UnitFlow supports explicit JSON backup export. File export uses a user-selected platform location where supported, while clipboard export remains available as a portable fallback. Export never includes credentials because UnitFlow static conversion has no credential requirement.

## Migration policy

When schema version 2 or later is introduced:

1. keep version 1 parsing deterministic;
2. add explicit migrations rather than silently reinterpreting old fields;
3. add migration and corruption-regression tests;
4. update the JSON Schema and this document;
5. update `CHANGELOG.md` with user-visible compatibility notes;
6. preserve unknown future schemas by rejecting them rather than destructively rewriting them.

## Privacy

See `PRIVACY.md` for the user-facing privacy policy and `SECURITY.md` for vulnerability reporting.
