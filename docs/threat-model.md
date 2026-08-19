# UnitFlow threat model

UnitFlow is an offline-first utility. Its security model focuses on protecting local data integrity, preventing unsafe imports, minimizing permissions, and keeping conversion behavior deterministic.

## Assets

- conversion correctness;
- user-defined custom units;
- favorites, pinned pairs, and recent conversions;
- local preferences and backups;
- release artifacts and source integrity;
- repository and CI credentials.

## Trust boundaries

### User-entered numeric text

Numeric input is untrusted. Parsers bound exponent/length behavior and reject malformed decimals instead of evaluating expressions.

### Backup imports

Imported JSON is untrusted even when it was originally exported by UnitFlow. Imports are size-limited, structurally validated, schema-version checked, and custom units are revalidated before state replacement.

### Custom units

Names, symbols, IDs, aliases, scale, and offset are user-controlled. IDs and field lengths are bounded, scales must be positive, and duplicate identifiers are rejected before rebuilding the active catalog.

### Native bridge

Generated FFI bindings are a trust boundary between Flutter and Rust. Decimal values should cross as validated text, failures should return structured errors, and the domain crate should remain free of unsafe code.

### CI and releases

Actions run repository code and may receive scoped GitHub tokens. Workflows should use least-privilege permissions, pinned major action versions that are periodically reviewed, dependency review, security scanning, and release verification before publishing artifacts.

## Primary threats and mitigations

| Threat | Mitigation |
| --- | --- |
| Corrupt local state crashes startup | Load failures fall back to defaults without overwriting the invalid saved payload automatically |
| Oversized/malicious import | Character-size limit, JSON object requirement, strict schema validation |
| Custom unit shadows a built-in | Duplicate ID rejection during engine rebuild |
| Floating-point drift | Rust decimal arithmetic and exact Dart `BigInt` decimal fallback |
| Category-confused conversion | Converter rejects cross-category pairs |
| Unexpected data upload | Core product features are offline-first and do not require an account |
| Secret leakage through issue reports | Templates explicitly ask users to remove secrets/private data |
| Dependency regression | CI, dependency review, CodeQL, and planned automated update tooling |
| Malicious release from unverified source | Tag release workflow reruns Rust and Flutter quality gates and publishes checksums |

## Out of scope

UnitFlow does not attempt to protect data from a fully compromised operating system, a malicious administrator with unrestricted device access, or a modified build distributed outside trusted release channels.

## Security review triggers

A new review is required when adding:

- network access or live exchange-rate providers;
- cloud sync, accounts, or authentication;
- file-system access beyond explicit backup/import workflows;
- clipboard monitoring rather than user-initiated copy;
- platform permissions;
- native bridge code or unsafe Rust;
- third-party analytics, ads, crash reporting, or telemetry;
- automatic execution of imported content.
