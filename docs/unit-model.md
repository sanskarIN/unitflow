# Unit model and conversion rules

UnitFlow models each unit as an affine relationship to exactly one category base unit.

## Formula

For a unit definition:

```text
base = input × scale + offset
```

To convert from unit A to unit B:

```text
base = input × A.scale + A.offset
output = (base - B.offset) ÷ B.scale
```

This handles ordinary multiplicative conversions as well as temperature scales without special-case branches in the converter.

## Category base units

| Category | Base unit ID |
| --- | --- |
| Length | `meter` |
| Area | `square_meter` |
| Volume | `liter` |
| Mass | `kilogram` |
| Speed | `meter_per_second` |
| Pressure | `pascal` |
| Energy | `joule` |
| Power | `watt` |
| Angle | `radian` |
| Data size | `byte` |
| Frequency | `hertz` |
| Time | `second` |
| Temperature | `kelvin` |

## Stable identifiers

A unit ID is a persistence and API key, not display copy. Built-in IDs should not be renamed after release unless a migration is provided for favorites, pinned pairs, recents, custom references, backups, and external integrations.

Valid custom IDs use lowercase ASCII letters, digits, `_`, and `-`, with a maximum length of 64 characters.

## Decimal behavior

The Rust core uses `rust_decimal`. The Flutter fallback uses an exact base-10 `BigInt` representation. Neither conversion path intentionally routes decimal values through binary floating point.

User-selectable output precision is bounded to 28 decimal places in the persisted app settings and Rust conversion request API.

## Rounding

The Rust core exposes explicit rounding strategies, including nearest-even, half-away-from-zero, toward-zero, away-from-zero, floor, and ceiling. The default domain strategy is nearest-even.

## Catalog rules

Every built-in category must:

1. contain at least one unit;
2. contain its declared base unit;
3. define that base unit with `scale = 1` and `offset = 0`;
4. contain unique stable unit IDs;
5. use a positive scale for every unit.

Automated invariant tests verify these assumptions.

## Adding a built-in unit

When adding a unit:

1. choose the correct category;
2. verify the authoritative conversion constant;
3. represent the constant as decimal text with suitable precision;
4. add useful aliases without changing existing IDs;
5. add at least one regression test for a known conversion;
6. verify round-trip behavior where appropriate;
7. update educational or documentation text if the unit needs special context.

Do not silently introduce currency conversion into the static catalog. Currency values are time-dependent and require an explicit online-data boundary and freshness model.
