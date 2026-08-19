# Security Policy

## Supported versions

Security fixes are applied to the latest release line and the default development branch.

## Reporting a vulnerability

Please do not publish exploitable details in a public issue before a fix is available. Report security concerns privately to:

- `sanskarin@outlook.in`
- `sanskarin.business@gmail.com`

Include the affected component, reproduction conditions, impact, and any safe proof-of-concept details needed to understand the issue.

## Security model

UnitFlow is designed to keep static conversions offline. The conversion core does not require remote services, analytics, accounts, or cloud storage. This reduces data exposure and allows the default conversion workflow to operate without network permissions.

## Secrets

Never commit API keys, access tokens, signing credentials, keystores, private certificates, or production environment files.

## Dependency hygiene

CI checks formatting, static analysis, tests, and Rust advisory/security tooling where available. Dependency changes should be reviewed for maintenance status, licensing, and necessity before merge.
