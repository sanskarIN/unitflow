# Security Policy

## Supported versions

Until the first stable release, security fixes are applied to the latest code on `main` and the newest tagged prerelease. After `1.0.0`, the support window will be documented per release line.

UnitFlow is currently alpha software. A generated platform smoke build or source-level passing check is not a statement that a native release binary is security-reviewed or supported.

## Reporting a vulnerability

Please do **not** open a public GitHub issue for a suspected vulnerability.

Report security concerns privately to:

- `sanskarin@outlook.in`
- `supportramsandesh@gmail.com`

Include, when possible:

- affected version or commit;
- impacted platform;
- concise reproduction steps;
- expected and observed behavior;
- potential impact;
- any suggested mitigation.

Do not include real credentials, sensitive user data, or destructive proof-of-concept payloads.

## Project security model

UnitFlow is offline-first for static conversions. The project aims to:

- avoid unnecessary runtime network permissions and account requirements;
- treat backup/import content and custom-unit definitions as untrusted input;
- bound imported payload/collection/string sizes before expensive processing;
- validate imported unit references and complete state before replacing active state;
- serialize local persistence mutations where ordering matters, including reset/save behavior;
- keep secrets, `.env` files, and signing material outside Git;
- redact sensitive values from structured logs;
- review dependencies and automated Dependabot updates rather than blindly auto-merging them;
- run repository-integrity checks, CodeQL, and dependency-oriented CI checks;
- validate release tags against repository package metadata before source packaging;
- use maintained libraries instead of custom cryptography.

Repository hygiene is a defense-in-depth check, not a replacement for GitHub secret scanning/push protection or maintainer review. Where repository settings support them, keep private vulnerability reporting, dependency alerts, secret scanning, and push protection enabled.

## Release security boundary

Before a platform is advertised as release-verified, its reviewed native project, permissions/entitlements, dependency set, production Rust bridge packaging, and intended release build must be checked on the relevant toolchain. Temporary `flutter create` platform scaffolds are compatibility probes only.

See `docs/threat-model.md`, `docs/native-platforms.md`, and `docs/release-checklist.md` for the detailed engineering/release boundary.

## Disclosure process

Maintainers will acknowledge actionable reports, assess impact, prepare a fix, add regression coverage, and coordinate disclosure when appropriate. Exact response timelines are not guaranteed for this volunteer open-source project.

## Out of scope

Reports that rely only on unsupported modified builds, social engineering, denial-of-service traffic against third-party services, or vulnerabilities in unrelated upstream infrastructure may be closed as out of scope, while still being documented when useful.
