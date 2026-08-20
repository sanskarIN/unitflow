# UnitFlow

**A precise, offline-first unit converter powered by a Rust conversion core and a Flutter interface.**

[![CI](https://github.com/sanskarIN/unitflow/actions/workflows/ci.yml/badge.svg)](https://github.com/sanskarIN/unitflow/actions/workflows/ci.yml)
[![Cross-platform](https://github.com/sanskarIN/unitflow/actions/workflows/platform-smoke.yml/badge.svg)](https://github.com/sanskarIN/unitflow/actions/workflows/platform-smoke.yml)
[![Security](https://github.com/sanskarIN/unitflow/actions/workflows/codeql.yml/badge.svg)](https://github.com/sanskarIN/unitflow/actions/workflows/codeql.yml)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-sanskarIN-FFDD00?logo=buy-me-a-coffee&logoColor=000000)](https://buymeacoffee.com/sanskarIN)

UnitFlow is an open-source conversion project designed around deterministic offline calculations, exact base-10 decimal behavior, accessible adaptive UI, local-first data, and a clean separation between reusable domain logic and platform presentation.

## Status

**Current source version: `2.0.12`. Six-platform source support is implemented; final native release verification is still in progress.**

The shared Flutter application is maintained as one cross-platform codebase for Android, iOS, Web, Windows, Linux, and macOS. The repository now includes deterministic six-platform generation/materialization automation, an enforced platform-support validator, release-mode build jobs for all six targets, and uploaded CI build artifacts. The production Rust↔Flutter generated binding layer, final committed/reviewed generated platform trees, platform signing/notarization, and final release-candidate evidence remain separate release-hardening work.

See [`what_changed.md`](what_changed.md) for the exact continuation checkpoint and [`ROADMAP.md`](ROADMAP.md) for remaining release blockers.

## Current Features

- Length, area, volume, mass, speed, pressure, energy, power, angle, data size, frequency, time, and temperature catalogs.
- Exact decimal conversion in Rust plus a deterministic pure-Dart compatibility engine.
- Explicit rounding strategies: nearest-even, half-away-from-zero, toward-zero, away-from-zero, floor, and ceiling.
- Plain, scientific, and engineering notation.
- Searchable unit library with stable IDs, symbols, aliases, favorites, and validated custom units.
- Favorites, pinned conversion pairs, recent local history, pair restore, and quick swap.
- Dedicated batch conversion workspace with CSV, TSV, and JSON clipboard export.
- Versioned local backup/import with strict schema validation and schema-v1 → schema-v2 migration.
- Educational category explanations and examples available offline.
- Locale-aware numeric parsing/display architecture and generated Flutter localization resources.
- Light, dark, and system theme modes.
- Adaptive mobile/desktop navigation and keyboard shortcuts.
- User-initiated GitHub Releases access; no background update checking is required for core conversions.
- Structured debug logging with sensitive-key redaction.
- Offline-first static data: no account is required for conversion.

## Platform Targets

| Platform | Support target | Automated build path | Distribution note |
|---|---|---|---|
| Android | Supported | Release App Bundle | Production signing/store publication remains external to source control |
| iOS | Supported | Release device app with `--no-codesign` | Apple signing/provisioning is required for distribution |
| Web | Supported | Release Web bundle | Hosting/security headers are deployment concerns |
| Windows | Supported | Release desktop bundle | Optional installer/code-signing work remains |
| Linux | Supported | Release desktop bundle | Distribution/package format remains release-specific |
| macOS | Supported | Release app bundle | Signing/notarization remains required for distribution |

The historical `.github/workflows/platform-smoke.yml` filename is retained for continuity, but the workflow now performs **release-mode cross-platform builds** and uploads artifacts for all six targets. It prefers committed platform projects and can regenerate a missing target with Flutter before building it.

`scripts/check_platform_support.py` makes the six-target contract enforceable. It prevents platform-job drift, partial platform commits, missing generation coverage, and unconditional shared `dart:io` imports that would break Web.

See [`docs/platform-support.md`](docs/platform-support.md), [`docs/native-platforms.md`](docs/native-platforms.md), and [`docs/platform-smoke.md`](docs/platform-smoke.md).

## Tech Stack

- **Rust 1.82+** — authoritative native conversion/domain core.
- **rust_decimal** — deterministic decimal arithmetic in Rust.
- **Flutter / Dart** — adaptive cross-platform UI and exact-decimal fallback.
- **Flutter gen-l10n / ARB** — generated localization resources.
- **Shared Preferences** — initial versioned local application-state repository.
- **Python 3 standard library** — repository, platform-support, documentation, hygiene, and release validators.
- **GitHub Actions** — CI, CodeQL, dependency review, platform materialization, six-platform release builds, artifact upload, and source release verification.
- **Dependabot** — scheduled Cargo, Flutter/Dart, and GitHub Actions update discovery.

## Repository Layout

```text
crates/unitflow_core/   Rust domain, catalog, conversion engine, tests, benchmark
apps/unitflow_app/      Flutter application, local persistence, tests, l10n resources
docs/                   Architecture, setup, data format, testing, release, ADRs
scripts/                Repository/platform validators plus Bash/PowerShell verification commands
.github/                 CI, platform builds/materialization, security, dependency automation, governance
```

## Quick Start

### Rust core

```bash
cargo test --workspace --all-features
```

### Flutter app

```bash
cd apps/unitflow_app
flutter pub get
flutter gen-l10n
flutter analyze --fatal-infos --fatal-warnings
flutter test
flutter run
```

### Generate all six Flutter platform projects

From the repository root on a machine with Flutter installed:

```bash
bash scripts/bootstrap_platforms.sh
```

On PowerShell:

```powershell
./scripts/bootstrap_platforms.ps1
```

The scripts generate Android, iOS, Web, Windows, Linux, and macOS projects together and run Flutter source checks afterward. The repository also contains `.github/workflows/materialize-platforms.yml` to perform deterministic platform generation, inventorying, validation, and commit preparation in GitHub Actions.

See [`docs/setup.md`](docs/setup.md) for prerequisites.

## One-Command Verification

Unix-like shell:

```bash
bash scripts/verify.sh
```

PowerShell:

```powershell
./scripts/verify.ps1
```

The scripts test the repository validators, validate the exhaustive tracked-file inventories, enforce the six-platform support contract, validate Markdown/release consistency/repository hygiene, then run Rust formatting/Clippy/tests and Flutter dependency resolution/localization/formatting/analysis/tests. A successful run in your environment is evidence for that checkout; this README does not assume a build passed merely because source files or workflow definitions exist.

## Architecture

The Rust crate owns validated unit definitions, conversion rules, exact-decimal behavior, catalog search, custom-unit validation, notation, and native educational metadata. Flutter owns presentation, accessibility, adaptive navigation, local preferences/state, clipboard workflows, localization resources, and platform integration.

The current Dart conversion implementation is intentionally deterministic so Flutter/Web work remains testable before the native bridge is complete. Native clients should move to the Rust bridge only after parity and packaging are proven. Rust and Dart parity tests consume the same versioned decimal-string fixture.

Read:

- [`docs/architecture.md`](docs/architecture.md)
- [`docs/bridge.md`](docs/bridge.md)
- [`docs/unit-model.md`](docs/unit-model.md)
- [`docs/data-format.md`](docs/data-format.md)
- [`docs/adr/0001-rust-core-flutter-ui.md`](docs/adr/0001-rust-core-flutter-ui.md)
- [`docs/adr/0002-exact-decimal-arithmetic.md`](docs/adr/0002-exact-decimal-arithmetic.md)
- [`docs/adr/0003-local-first-persistence.md`](docs/adr/0003-local-first-persistence.md)
- [`docs/adr/0004-deterministic-dart-fallback.md`](docs/adr/0004-deterministic-dart-fallback.md)

## Testing and Quality

The repository includes:

- Rust conversion/catalog invariant and regression tests;
- shared Rust/Dart bridge parity vectors covering representative affine/scaling conversions and every rounding mode;
- Flutter exact-decimal, persistence/migration, batch-export, safe-logging, collection-cleanup, recent-reference, reset-ordering/failure, native-bridge-validation, persisted-journey, and adaptive-navigation tests;
- deterministic property-style decimal tests;
- dependency-free Python regression tests for repository validators;
- exhaustive tracked-file inventory, Markdown-link, release-consistency, repository-hygiene, six-platform support, and exact release-tag guards;
- a dependency-free Rust conversion micro-benchmark;
- CI formatting/lint/analysis/test and repository-integrity gates;
- CodeQL and pull-request dependency review;
- release-mode builds for Android, Web, Linux, Windows, macOS, and iOS, with build artifact upload;
- deterministic all-or-nothing Flutter platform materialization and generated-file inventory automation;
- a release workflow that re-runs source quality/platform-contract gates, rejects mismatched tags, requires a clean Rust package tree, and emits SHA-256 checksums.

See [`docs/testing.md`](docs/testing.md), [`docs/performance.md`](docs/performance.md), and [`docs/release-checklist.md`](docs/release-checklist.md).

## Localization

English is the current source locale. Primary Flutter presentation strings are maintained in `apps/unitflow_app/lib/l10n/app_en.arb` and generated with `flutter gen-l10n`. Additional locales should only be advertised after translation and UI/accessibility review.

See [`docs/localization.md`](docs/localization.md).

## Security and Privacy

UnitFlow does not require an account for static conversions and is designed to work offline. Preferences, favorites, history, pins, and custom units are stored locally by default and only leave the local state through explicit user actions such as copy/export.

Repository hygiene rejects commonly accidental tracked environment/signing/build artifacts, and the native bridge DTO boundary rejects malformed decimal/unit payloads before future generated bindings are trusted. Maintainers should still keep GitHub secret scanning/push protection enabled where available.

Read [`SECURITY.md`](SECURITY.md), [`PRIVACY.md`](PRIVACY.md), and [`docs/threat-model.md`](docs/threat-model.md).

## Screenshots

Real screenshots and demo media are intentionally deferred until release-candidate builds are generated and verified. The project does not use fabricated screenshots as release evidence.

## Contributing

Contributions are welcome. Read [`CONTRIBUTING.md`](CONTRIBUTING.md), follow the code of conduct, add regression tests for behavior changes, keep commits meaningful and focused, and run the quality gates before opening a pull request.

Repository-maintainer guidance is in [`docs/github-maintenance.md`](docs/github-maintenance.md).

## License

MIT License. See [`LICENSE`](LICENSE).

## Contact and Support

- Business: `sanskarin@outlook.in`
- Business: `sanskarin.business@gmail.com`
- Support: `supportramsandesh@gmail.com`
- GitHub: https://github.com/sanskarIN
- Buy Me a Coffee: https://buymeacoffee.com/sanskarIN

---

**Made by the Sanskar**