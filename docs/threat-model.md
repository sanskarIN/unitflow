# UnitFlow threat model

UnitFlow is an offline-first utility. Its security model focuses on protecting local data integrity, preventing unsafe imports, minimizing permissions, keeping conversion behavior deterministic, and making source/release integrity auditable.

## Assets

- conversion correctness;
- user-defined custom units;
- favorites, pinned pairs, and recent conversions;
- local preferences and backups;
- release artifacts and source integrity;
- repository and CI credentials;
- signing/provisioning material kept outside the repository.

## Trust boundaries

### User-entered numeric text

Numeric input is untrusted. Parsers bound exponent/length behavior and reject malformed decimals instead of evaluating expressions. Locale-aware input remains text until the application parser validates it.

### Backup imports

Imported JSON is untrusted even when it was originally exported by UnitFlow. All repository adapters use the same decoder: empty/oversized payloads are rejected before JSON decoding, the top-level value must be an object with string keys, collection/string limits are enforced, schema versions are checked/migrated explicitly, custom units are revalidated, and saved unit references are checked before active state replacement.

### Local persistence ordering

Persistence is asynchronous, so write order is a correctness and deletion-integrity boundary. State saves are serialized. Reset is queued behind earlier writes, clears storage, then saves a clean baseline so an older pending write cannot restore data after a reset request.

### Custom units

Names, symbols, IDs, aliases, scale, and offset are user-controlled. IDs and field lengths are bounded, scales must be positive, decimal text must parse safely, and duplicate identifiers are rejected before rebuilding the active catalog.

### Native bridge

The future production FFI/generated-binding path is a trust boundary between Flutter and Rust. Decimal values should cross as validated text, failures should return structured errors, bridge protocol changes require parity fixtures/tests, and the domain crate should remain free of unnecessary unsafe code. The current deterministic Dart fallback is not evidence that native Rust loading/packaging is complete.

### CI, repository automation, and releases

Actions run repository code and may receive scoped GitHub tokens. Normal CI/platform smoke workflows should remain read-only. Release automation requires write permission only to create release assets. Repository integrity validators check tracked-file documentation, local Markdown targets, release/schema/protocol consistency, critical-file hygiene, and exact release-tag/version matching before packaging.

Dependabot, dependency review, and CodeQL provide automated signals; dependency updates still require human review and applicable tests.

### Native platform scaffolding

Temporary `flutter create` scaffolds in CI compile shared source against target toolchains but are not trusted release configuration. Reviewed package identifiers, permissions, entitlements, signing boundaries, runtime behavior, and production bridge packaging belong to the committed native projects used for actual release builds.

## Primary threats and mitigations

| Threat | Mitigation |
| --- | --- |
| Corrupt local state crashes startup | Load failures fall back to defaults without automatically overwriting the invalid saved payload |
| Oversized/malicious import | Shared 1,000,000-character pre-decode limit, JSON object/string-key requirement, bounded collections/fields, strict schema validation |
| Invalid import partially replaces active state | Complete state/catalog/reference validation happens before controller state replacement/persistence |
| Pending save restores data after reset | Serialized persistence chain; reset waits, clears, then persists a clean baseline |
| Custom unit shadows a built-in | Duplicate stable-ID rejection during engine rebuild |
| Floating-point drift | Rust decimal arithmetic and exact Dart `BigInt` decimal fallback |
| Category-confused conversion/history | Converter and recent-reference paths reject cross-category pairs |
| Unexpected data upload | Core product features are offline-first and do not require an account |
| Secret/signing file committed accidentally | `.gitignore`, repository hygiene validation, and GitHub secret scanning/push protection where enabled |
| Secret leakage through issue/log content | Issue templates request redaction; structured logs redact sensitive keys and bound metadata |
| Dependency regression | Dependabot discovery, dependency review, CodeQL, CI, release verification, and manual review |
| Undocumented repository drift | Exhaustive tracked-file inventory plus `git ls-files` inventory validator |
| Mismatched or misleading release tag | Release tag must exactly equal `v` plus the Cargo workspace version before packaging |
| Malicious/incorrect release from unverified source | Tag release workflow reruns repository/Rust/Flutter quality gates and publishes source checksums; native artifacts require separate reviewed-platform evidence |

## Out of scope

UnitFlow does not attempt to protect data from a fully compromised operating system, a malicious administrator with unrestricted device access, a maliciously modified build distributed outside trusted release channels, or third-party platform/store infrastructure outside the project's control.

## Security review triggers

A new review is required when adding:

- network access or live exchange-rate providers;
- cloud sync, accounts, or authentication;
- file-system access beyond explicit backup/import workflows;
- clipboard monitoring rather than user-initiated copy;
- new platform permissions or entitlements;
- production native bridge code or unsafe Rust;
- third-party analytics, ads, crash reporting, or telemetry;
- automatic execution of imported content;
- signing/notarization automation or new release credentials;
- a dependency that introduces native code, networking, dynamic loading, or a materially larger transitive attack surface.
