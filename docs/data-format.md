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

The runtime decoder performs a bounded structural pass before normal JSON decoding. It rejects duplicate object keys, including keys that become equal after JSON escape decoding, and rejects nesting deeper than 64 containers. This prevents ambiguous last-value-wins parsing and unbounded recursive input structures from entering state validation.

The decoder also rejects unknown object properties instead of silently discarding them. This keeps runtime behavior aligned with the checked-in JSON Schemas, which use `additionalProperties: false`, and prevents misspelled or future fields from appearing to import successfully when their meaning was actually ignored.

Current safety bounds include:

- file/import text size: at most 1,000,000 characters through the state decoder and at most 1,000,000 bytes through file import/export;
- JSON nesting: at most 64 containers;
- recent conversions: at most 100 accepted from an imported document, with the app normally retaining at most 50 active recents;
- recent input text: at most 1024 characters;
- pinned pairs: at most 20 active pairs;
- custom units: at most 200 accepted from an imported document and at most 200 created locally;
- custom aliases: at most 32 per unit;
- custom scale/offset text: at most 1024 characters each;
- decimal precision preference: 0–28 places;
- stable identifiers: 1–64 lowercase ASCII letters, digits, `_`, and `-` only.

Collection bounds are validated before iterating imported entries. Oversized arrays are rejected; their tail is never silently discarded during parsing.

## Decimal portability domain

The native Rust core uses `rust_decimal::Decimal`. To keep the deterministic Dart fallback from accepting values that the authoritative native core cannot represent, fallback conversion input and custom-unit scale/offset values are restricted to the same normalized value domain:

- scale from 0 through 28 decimal places;
- absolute 96-bit coefficient no greater than `79228162514264337593543950335`.

The Dart `ExactDecimal` type remains arbitrary precision internally because it is useful for deterministic intermediate formatting and tests, but product conversion entry points enforce the Rust-compatible boundary. This avoids a web/test-only acceptance path for values that would be rejected by the native bridge.

## Canonicalization

Custom-unit text is normalized at the trust boundary before it becomes durable state:

- names, symbols, descriptions, and aliases are trimmed;
- aliases are deduplicated case-insensitively while preserving first-occurrence order;
- scale and offset are parsed through UnitFlow's exact decimal implementation, checked against the Rust-compatible decimal domain, and persisted in canonical decimal form;
- stable identifiers are validated rather than rewritten.

Recent conversions created by the current application store the input value in locale-independent canonical decimal form. When a recent conversion is reopened, the canonical value is parsed first and then formatted for the current input locale before converter parsing. Older history rows that contain non-canonical localized input are not reinterpreted as canonical numeric data; their unit pair can still be restored without silently changing the numeric meaning.

Canonicalization ensures a unit created interactively and the same unit restored from backup have equivalent durable representation.

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

The scale must be strictly positive, and both scale and offset must fit the shared Rust-compatible decimal domain. This design covers ordinary multiplicative units and temperature-like offsets without introducing an expression interpreter into imported user data.

## Referential normalization

Favorites, pinned pairs, and recent conversions store stable unit IDs. A previously valid ID can become stale if a custom unit is removed or a future catalog migration retires an identifier.

When state is loaded or imported, UnitFlow rebuilds the current catalog and normalizes convenience references against it:

- favorites referencing an unavailable unit are removed;
- pinned pairs are kept only when both units exist and still belong to the stored category;
- recent conversions are kept only when both units exist and belong to the same category;
- active pins are bounded to 20 and active recents to 50;
- custom units themselves are not silently dropped by this normalization step; invalid or duplicate custom-unit definitions reject the load/import instead.

Removing a custom unit also removes favorites, pins, and recent-history rows that reference that unit. This prevents an otherwise valid backup from accumulating inaccessible convenience data.

Normalization diagnostics record only removed item counts, not unit names, values, backup payloads, or conversion history contents.

## Import behavior

An import is rejected when, among other validation failures:

- JSON is malformed;
- duplicate JSON object keys are present;
- JSON nesting exceeds the configured depth bound;
- the root is not an object;
- the schema version is unsupported;
- an object contains unsupported properties;
- required settings have invalid types or ranges;
- favorite or pinned identifiers do not match the stable-ID grammar;
- duplicate favorite, pinned-pair, or custom-unit identifiers are present where uniqueness is required;
- a custom-unit identifier or formula is invalid or outside the portable decimal domain;
- duplicate identifiers would collide with built-in or imported custom units;
- the import exceeds configured size/count limits.

The application preserves the existing state when validation fails. A structurally valid import may have stale convenience references normalized as described above after its catalog is successfully rebuilt.

Production and in-memory repositories share the same decoder so tests do not accidentally exercise a more permissive import path than the shipped application.

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

## Repository data validation

`tool/check_data_files.py` parses every tracked JSON and ARB file as UTF-8 JSON and rejects duplicate object keys. Duplicate keys are forbidden because ordinary JSON parsers may silently keep one value and discard another, creating ambiguous configuration or schema evidence.

Runtime backup parsing has its own duplicate-key/depth enforcement in `apps/unitflow_app/lib/core/persistence/strict_json.dart`; repository validation is not relied on for untrusted user imports.

## Privacy

See `PRIVACY.md` for the user-facing privacy policy and `SECURITY.md` for vulnerability reporting.
