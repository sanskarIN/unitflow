# UnitFlow — Development Handoff

This file is the primary continuation checkpoint for future development sessions.

## Current milestone

**Phase 0 → Phase 1 bootstrap in progress**

Target release: `0.1.0-alpha.1`

## Source prompt

Implementation is governed by the UnitFlow master prompt supplied for this repository. The repository is public/open-source, MIT licensed, uses a Rust core plus Flutter frontend, and must keep the visible credit **Made by the Sanskar**.

## Completed work

- Repository inspected before implementation; it was empty on 2026-08-19.
- Added the first production-oriented README with project identity, architecture, platform targets, setup commands, security/privacy notes, support contacts, BMC badge, and required credit.
- Established an incremental delivery strategy that preserves small meaningful commits.

## Files added or changed

- `README.md`
- `what_changed.md`

## Verification performed

Repository inspection:

- Confirmed `sanskarIN/unitflow` exists.
- Confirmed repository is public.
- Confirmed authenticated GitHub integration has push/admin permission.
- Confirmed default branch is `main`.

Local toolchain availability check in the execution environment:

- `rustc`: unavailable
- `cargo`: unavailable
- `flutter`: unavailable
- `dart`: unavailable

Because the required compilers are not installed in the execution environment, build/test claims must not be marked as passing until GitHub Actions or a later environment runs them.

## Commit identity note

Requested commit email: `sanskarin@outlook.in`.

The connected GitHub Contents API actions used in this session do not expose an `author.email`/`committer.email` argument, so individual API-created commit identity is controlled by the authenticated GitHub integration. The repository includes contributor setup guidance to configure `user.email=sanskarin@outlook.in` for local Git commits. Do not falsely claim that connector-created commits used a configurable email when the API surface did not permit it.

## Known limitations

- Rust/Flutter compilation has not yet been executed locally because those toolchains are unavailable in the execution environment.
- UI screenshots cannot be real until a runnable Flutter build exists.
- Native Rust↔Flutter binding generation will be introduced after the domain core and Flutter shell are stable.

## Exact next tasks

1. Add repository policy/configuration files and MIT license.
2. Add architecture/setup/testing/release documentation and first ADR.
3. Create Rust workspace and `unitflow_core` crate.
4. Implement category/unit models, validation, catalog, conversion service, notation helpers, and tests.
5. Create Flutter application package and adaptive converter UI.
6. Add persistence abstractions for favorites, recents, pinned pairs, settings, and custom units.
7. Add CI, CodeQL, dependency updates, templates, and release workflow.
8. Run available remote quality gates and fix every discovered issue.
9. Update this handoff after each milestone.

## Release notes draft

### 0.1.0-alpha.1

Initial UnitFlow foundation: project documentation, Rust conversion engine, Flutter application shell, automated quality gates, security/privacy documentation, and repository governance.

## Recent meaningful commits

- `36bac8e` — `docs: add UnitFlow repository overview`
