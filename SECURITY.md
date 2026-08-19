# Security Policy

## Supported versions

Until the first stable release, security fixes are applied to the latest code on `main` and the newest tagged prerelease. After `1.0.0`, the support window will be documented per release line.

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

- avoid unnecessary network permissions;
- validate imported/custom unit data before use;
- keep secrets and signing material outside Git;
- redact sensitive values from logs;
- pin/lock dependencies and review automated updates;
- run CodeQL and dependency-oriented CI checks;
- use maintained libraries instead of custom cryptography;
- treat exported files and future imported backups as untrusted input.

## Disclosure process

Maintainers will acknowledge actionable reports, assess impact, prepare a fix, add regression coverage, and coordinate disclosure when appropriate. Exact response timelines are not guaranteed for this volunteer open-source project.

## Out of scope

Reports that rely only on unsupported modified builds, social engineering, denial-of-service traffic against third-party services, or vulnerabilities in unrelated upstream infrastructure may be closed as out of scope, while still being documented when useful.
