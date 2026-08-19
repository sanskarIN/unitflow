# Local Data and Backup Format

UnitFlow is offline-first. Static conversions require no account and no network request. User preferences and optional convenience data are designed to remain on the current device unless the user explicitly exports a backup.

## Stored data

The current local state contains:

- theme preference;
- notation preference;
- explicit decimal rounding mode;
- decimal-place preference;
- grouping preference;
- reduced-motion accessibility preference;
- onboarding completion state;
- favorite unit identifiers;
- pinned unit pairs;
- bounded recent-conversion history;
- validated custom affine units.

The current schema version is **2**. Its machine-readable contract is published at `schemas/unitflow-backup-v2.schema.json`. The version 1 schema remains checked in at `schemas/unitflow-backup-v1.schema.json` for compatibility documentation and migration tests.

## Backup envelope

A backup is a UTF-8 JSON object. The root `schemaVersion` field is mandatory. UnitFlow validates the complete object before replacing the in-memory state; malformed or unsupported imports must not partially overwrite an existing profile.

Current safety bounds include:

- file/import text size: at most 1 MB;
- recent conversions: at most 100 accepted from an imported document, with the app normally retaining a smaller recent set;
- custom units: at most 200 accepted from an imported document;
- custom aliases: at most 32 per unit;
- decimal precision preference: 0–28 places;
- stable identifiers: lowercase ASCII letters, digits, `_`, and `-` only.

## Rounding modes

Schema version 2 stores a `roundingMode` field. Accepted values are:

- `nearestEven`;
- `halfAwayFromZero`;
- `towardZero`;
- `awayFromZero`;
- `floor`;
- `ceiling`.

The selected mode is applied by the conversion engine whenever a result must be rounded to the configured decimal-place precision.

## Accessibility preference

Schema version 2 may contain `reduceMotion`. It is a boolean and defaults to `false` when absent. Keeping this field optional allows early schema-v2 backups created before the preference was introduced to remain importable without another schema-version bump.

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

The application preserves the existing state when validation fails.

## Export behavior

UnitFlow supports explicit JSON backup export. File export uses a user-selected platform location where supported, while clipboard export remains available as a portable fallback. Export never includes credentials because UnitFlow static conversion has no credential requirement.

## Migration policy

### Version 1 → version 2

Version 1 did not contain a rounding preference. When a valid version 1 backup is imported, UnitFlow deterministically migrates it to `nearestEven`, which was the conversion engine's historical default. Version 1 also predates the persisted reduced-motion preference, so that preference migrates to `false`. A subsequent export emits schema version 2.

### Early version 2 compatibility

Version 2 backups that contain `roundingMode` but predate `reduceMotion` remain valid. Missing `reduceMotion` is interpreted as `false`.

For future schema versions:

1. keep older supported parsing deterministic;
2. add explicit migrations rather than silently reinterpreting old fields;
3. add migration and corruption-regression tests;
4. update the JSON Schema and this document;
5. update `CHANGELOG.md` with user-visible compatibility notes;
6. reject unknown future schemas rather than destructively rewriting them.

## Privacy

See `PRIVACY.md` for the user-facing privacy policy and `SECURITY.md` for vulnerability reporting.
