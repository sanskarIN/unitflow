# UnitFlow Privacy

_Last updated: 2026-08-19_

UnitFlow is designed as an offline-first unit converter. Static conversion does not require an account or remote service.

## Data handled by the app

Depending on enabled features, UnitFlow may store locally:

- appearance and accessibility preferences;
- favorite units and pinned conversion pairs;
- recent conversion history;
- custom user-defined units;
- onboarding/version state.

The intended default is on-device storage. UnitFlow does not need these values to leave the device to perform static conversions.

## Export and import

When backup/export features are used, the user chooses where exported data is saved or shared through platform facilities. Exported files can contain the user's preferences, custom units, favorites, pins, or history. Users should review files before sharing them.

Imported files are treated as untrusted input and must be validated before persistence or conversion.

## Networking

Core static conversion is offline. Future optional features that require networking must be clearly documented, disabled when not needed, and designed to minimize collected data.

## Logs

Application logs must avoid secrets, authentication material, raw exported content, and unnecessary personal information. Diagnostic details should be bounded and redacted.

## Permissions

UnitFlow should request only platform permissions needed for an explicit user action, such as choosing a file to import/export. Permission requests should be contextual rather than requested at startup without need.

## Third-party services

GitHub and Buy Me a Coffee links open external services under their own privacy terms. UnitFlow does not require a donation to function.

## Questions

- Support: `supportramsandesh@gmail.com`
- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`

This document describes the project design intent and must be updated whenever actual data flows change.
