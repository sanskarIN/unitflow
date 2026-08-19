# UnitFlow

**A precise, offline-first unit converter powered by a Rust conversion core and a Flutter interface.**

[![CI](https://github.com/sanskarIN/unitflow/actions/workflows/ci.yml/badge.svg)](https://github.com/sanskarIN/unitflow/actions/workflows/ci.yml)
[![Security](https://github.com/sanskarIN/unitflow/actions/workflows/codeql.yml/badge.svg)](https://github.com/sanskarIN/unitflow/actions/workflows/codeql.yml)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-sanskarIN-FFDD00?logo=buy-me-a-coffee&logoColor=000000)](https://buymeacoffee.com/sanskarIN)

UnitFlow is an open-source conversion project designed around deterministic offline calculations, exact base-10 decimal behavior, accessible adaptive UI, local-first data, and a clean separation between reusable domain logic and platform presentation.

## Status

**Active alpha development — not yet release-verified.**

The Rust core, Flutter feature code, persistence model, tests, localization architecture, repository-integrity automation, dependency updates, and generated platform smoke-build matrix are implemented substantially. Reviewed native Flutter platform projects and the production Rust↔Flutter bridge still need to be committed/integrated and validated before UnitFlow claims tested Android, Windows, Linux, macOS, Web, or iOS release binaries.

See [`what_changed.md`](what_changed.md) for the exact continuation checkpoint and [`ROADMAP.md`](ROADMAP.md) for remaining blockers.

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

| Platform | Product target | Current release status |
|---|---|---|
| Android | Primary | Reviewed native project/release build verification pending |
| Windows | Primary desktop | Reviewed native project/release build verification pending |
| Linux | Primary desktop | Reviewed native project/release build verification pending |
| macOS | Supported target | Reviewed native project/release build verification pending |
| Web | Supported target | Reviewed Web project/release build verification pending |
| iOS | Ready target | Reviewed Xcode/native project verification pending |

Generated-scaffold smoke jobs cover all six targets as early compatibility checks, but they are intentionally not counted as release verification. See [`docs/platform-support.md`](docs/platform-support.md), [`docs/native-platforms.md`](docs/native-platforms.md), and [`docs/platform-smoke.md`](docs/platform-smoke.md).

## Tech Stack

- **Rust** — authoritative native conversion/domain core.
- **rust_decimal** — deterministic decimal arithmetic in Rust.
- **Flutter / Dart** — adaptive cross-platform UI and exact-decimal fallback.
- **Flutter gen-l10n / ARB** — generated localization resources.
- **Shared Preferences** — initial versioned local application-state repository.
- **Python 3 standard library** — repository consistency, documentation, hygiene, and release-tag validators.
- **GitHub Actions** — CI, CodeQL, dependency review, generated platform smoke builds, and source release verification.
- **Dependabot** — scheduled Cargo, Flutter/Dart, and GitHub Actions update discovery.

## Repository Layout

```text
crates/unitflow_core/   Rust domain, catalog, conversion engine, tests, benchmark
apps/unitflow_app/      Flutter application, local persistence, tests, l10n resources
docs/                   Architecture, setup, data format, testing, release, ADRs
scripts/                Repository validators plus Bash/PowerShell verification commands
.github/                 CI, security, dependency automation, governance, funding, ownership
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

Native `flutter run` targets require the corresponding Flutter platform project and toolchain; those reviewed scaffolds remain a documented alpha release task.

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

The scripts test the repository validators, validate Markdown/release consistency/repository hygiene, then run Rust formatting/Clippy/tests and Flutter dependency resolution/localization/formatting/analysis/tests. A successful run in your environment is evidence for that checkout; this README does not assume a build passed merely because source files or workflow definitions exist.

## Architecture

The Rust crate owns validated unit definitions, conversion rules, exact-decimal behavior, catalog search, custom-unit validation, notation, and native educational metadata. Flutter owns presentation, accessibility, adaptive navigation, local preferences/state, clipboard workflows, localization resources, and platform integration.

The current Dart conversion implementation is intentionally deterministic so Flutter/Web work remains testable before the native bridge is complete. Native clients should move to the Rust bridge only after parity and packaging are proven.

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
- Flutter exact-decimal, persistence/migration, batch-export, safe-logging, collection-cleanup, recent-reference, reset-ordering, and adaptive-navigation tests;
- deterministic property-style decimal tests;
- dependency-free Python regression tests for repository validators;
- Markdown-link, release-consistency, repository-hygiene, and exact release-tag guards;
- a dependency-free Rust conversion micro-benchmark;
- CI formatting/lint/analysis/test and repository-integrity gates;
- CodeQL and pull-request dependency review;
- generated-scaffold smoke builds for Android, Web, Linux, Windows, macOS, and iOS;
- a release workflow that re-runs source quality gates, rejects mismatched tags, and emits SHA-256 checksums.

See [`docs/testing.md`](docs/testing.md), [`docs/performance.md`](docs/performance.md), and [`docs/release-checklist.md`](docs/release-checklist.md).

## Localization

English is the current source locale. Primary Flutter presentation strings are maintained in `apps/unitflow_app/lib/l10n/app_en.arb` and generated with `flutter gen-l10n`. Additional locales should only be advertised after translation and UI/accessibility review.

See [`docs/localization.md`](docs/localization.md).

## Security and Privacy

UnitFlow does not require an account for static conversions and is designed to work offline. Preferences, favorites, history, pins, and custom units are stored locally by default and only leave the local state through explicit user actions such as copy/export.

Repository hygiene rejects commonly accidental tracked environment/signing/build artifacts, but maintainers should still keep GitHub secret scanning/push protection enabled where available.

Read [`SECURITY.md`](SECURITY.md), [`PRIVACY.md`](PRIVACY.md), and [`docs/threat-model.md`](docs/threat-model.md).

## Screenshots

Real screenshots and demo media are intentionally deferred until native release builds are generated and verified. The project does not use fabricated screenshots as release evidence.

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
