# UnitFlow local data format

UnitFlow stores user preferences and optional convenience data locally. The persisted document is versioned so imports can be rejected safely when their structure is unknown.

## Current schema

Current schema version: `2`.

Top-level keys:

- `schemaVersion`: integer schema discriminator. Current exports write `2`.
- `theme`: `system`, `light`, or `dark`.
- `notation`: persisted decimal-notation enum name.
- `roundingMode`: persisted exact-decimal rounding enum name.
- `decimalPlaces`: integer from `0` through `28`.
- `useGrouping`: boolean.
- `onboardingComplete`: boolean.
- `favoriteUnitIds`: array of known unit identifiers.
- `pinnedPairs`: array of compact `category|from|to` strings.
- `recents`: array of recent-conversion objects.
- `customUnits`: array of validated custom-unit objects.

Unknown or malformed required fields cause the import to fail rather than being partially accepted.

## Schema migration

Schema version `1` remains accepted. A version-1 document did not contain `roundingMode`; migration supplies `nearestEven`, preserving the behavior used before the setting became user-configurable. Once saved or exported again, the state is written as version `2`.

Future schema versions must either provide an explicit migration from a supported older version or reject the document without replacing active state.

## Recent conversion

Each item contains:

```json
{
  "input": "12.5",
  "fromUnitId": "meter",
  "toUnitId": "kilometer",
  "createdAt": "2026-08-19T08:00:00.000Z"
}
```

The original input is retained as text so decimal intent is not lost through binary floating-point conversion. Recent conversion unit identifiers are bounded to 64 characters each, and the stored input string is bounded to 1,024 characters.

## Custom unit

Each custom unit contains:

```json
{
  "id": "my_length",
  "category": "length",
  "name": "My Length",
  "symbol": "mlen",
  "scale": "2.5",
  "offset": "0",
  "aliases": ["custom length"],
  "description": "Optional description"
}
```

The affine relationship is:

```text
base = input × scale + offset
```

`scale` must be greater than zero. IDs, names, symbols, aliases, descriptions, and decimal text are validated before a custom unit is accepted.

## Import limits

The Shared Preferences repository rejects empty imports and files larger than 1,000,000 characters. JSON must decode to an object. A malformed, unsupported, or unsafe document is rejected before replacing active state.

Versioned user-state validation also bounds collection sizes before iterating or constructing active state:

| Collection | Maximum imported items |
| --- | ---: |
| Favorites | 500 |
| Pinned pairs | 100 |
| Recent conversions | 100 |
| Custom units | 200 |

These are defensive import ceilings rather than UI promises. Normal product workflows keep smaller working sets where appropriate, such as recent-history and pin retention limits enforced by the app controller.

## Backup behavior

Export produces human-readable JSON. Import first validates the complete document and rebuilds the conversion engine with all custom units. Only after those checks pass is the in-memory state replaced and persisted.

The Shared Preferences storage key remains `unitflow.user_state.v1` even though the document schema is version `2`. The key identifies the application-state slot, while `schemaVersion` identifies the payload format. Keeping the slot stable allows the migration logic to read existing version-1 documents instead of orphaning them under a new key.

## Compatibility policy

A future incompatible schema must increment `schemaVersion`. Migration code must be explicit, tested, and documented. Unit identifiers that are already persisted should remain stable whenever possible.
