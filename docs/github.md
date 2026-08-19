# GitHub Repository Operations

This document records recommended repository settings that cannot be represented reliably as source files alone.

## Default branch protection

Protect `main` and require pull requests for routine changes once the initial bootstrap is complete. Recommended rules:

- require the `Rust quality` and `Flutter quality` CI jobs;
- require CodeQL when the repository's security settings support it;
- require dependency review for pull requests that change dependencies;
- require branches to be up to date before merge when practical;
- block force pushes and branch deletion;
- require conversation resolution before merge;
- permit administrators to intervene only for documented emergencies.

Do not mark a check as required until the workflow exists and has run successfully at least once.

## Suggested labels

Use a small predictable taxonomy:

- `bug`
- `enhancement`
- `documentation`
- `accessibility`
- `security`
- `performance`
- `dependencies`
- `rust`
- `flutter`
- `android`
- `desktop`
- `web`
- `good first issue`
- `help wanted`
- `triage`
- `blocked`

Color choice is presentation-only; label meaning should remain understandable without relying on color.

## Suggested milestones

- `0.1.0-alpha.1 — Core preview`
- `0.2.0 — Local data and customization`
- `0.3.0 — Platform integration`
- `1.0.0 — Stable release`

Milestones should track deliverables rather than arbitrary issue counts.

## Discussions

If GitHub Discussions is enabled, suggested categories are:

- Announcements
- Ideas
- Q&A
- Show and tell

Security reports must not be posted in Discussions; use the private process in `SECURITY.md`.

## Merge strategy

Prefer merge commits for multi-commit feature branches when preserving useful atomic history matters. Squash only branches whose intermediate commits are noisy. Do not create empty commits solely to inflate contribution counts.

## Releases

Create releases from audited version tags. The release workflow builds reproducible artifacts; store signing credentials outside this repository. Never upload private signing material as a normal workflow artifact.

## Repository metadata

Suggested description:

> Precise, offline-first cross-platform unit converter with a Rust domain core and Flutter UI.

Suggested topics:

`unit-converter`, `rust`, `flutter`, `dart`, `android`, `desktop`, `web`, `offline-first`, `accessibility`, `open-source`

## Funding

The README and support documentation link to the optional Buy Me a Coffee page at `https://buymeacoffee.com/sanskarIN`. Funding must remain non-intrusive and must never gate features.
