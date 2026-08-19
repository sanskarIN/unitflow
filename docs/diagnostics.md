# Diagnostics and logging

UnitFlow keeps diagnostics deliberately small because the product is offline-first and does not require telemetry for core functionality.

## Current behavior

The Flutter application exposes a tiny structured logger in `lib/core/logging/app_log.dart`.

- Log records are emitted only in debug builds.
- Records are JSON-shaped so development logs are searchable.
- Metadata keys containing sensitive fragments such as `authorization`, `cookie`, `credential`, `password`, `secret`, or `token` are replaced with `[REDACTED]`.
- Nested maps are sanitized recursively.
- Long strings and large collections are bounded before output.
- Unknown object values are represented by their runtime type rather than arbitrary `toString()` output.
- User-facing error messages do not display raw internal exception details for backup/custom-unit failures.

## Events currently used

Examples include:

- `state_load_failed`
- `state_save_failed`
- `backup_import_rejected`
- `custom_unit_create_failed`

Metadata should describe the failure class or operation, not contain a user's conversion history, backup JSON, custom-unit content, clipboard data, credentials, or platform signing details.

## No telemetry by default

UnitFlow currently has no analytics, remote crash reporter, background log uploader, or account-linked telemetry pipeline. Debug output stays within the developer/runtime logging facilities provided by the platform.

Adding remote diagnostics later would cross an explicit privacy/network boundary and requires:

1. an updated threat model and privacy policy;
2. clear opt-in/consent behavior where appropriate;
3. data minimization and retention rules;
4. secret/PII filtering tests;
5. offline behavior that remains fully functional without the service;
6. documentation of endpoints and configuration;
7. platform permission/network review.

## Logging rules for contributors

Do not log:

- backup payloads;
- clipboard contents;
- authentication/session tokens;
- signing credentials;
- email contents or personal files;
- complete exception objects when their string form could include user input;
- precise local file paths unless necessary for a local-only development diagnostic.

Prefer a stable event name plus bounded metadata such as an error type, category, count, or non-sensitive state transition.

## Testing

`test/core/app_log_test.dart` verifies recursive sensitive-key redaction and string-length bounds. Extend those tests whenever the sanitizer or logging contract changes.
