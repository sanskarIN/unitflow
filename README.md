# UnitFlow

**A precise, offline-first unit converter powered by a Rust conversion core and a Flutter interface.**

[![CI](https://github.com/sanskarIN/unitflow/actions/workflows/ci.yml/badge.svg)](https://github.com/sanskarIN/unitflow/actions/workflows/ci.yml)
[![Security](https://github.com/sanskarIN/unitflow/actions/workflows/codeql.yml/badge.svg)](https://github.com/sanskarIN/unitflow/actions/workflows/codeql.yml)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-sanskarIN-FFDD00?logo=buy-me-a-coffee&logoColor=000000)](https://buymeacoffee.com/sanskarIN)

UnitFlow is an open-source converter targeting Android, Windows, Linux, macOS, Web, and iOS-ready workflows. It is designed around deterministic offline conversions, explicit precision and rounding behavior, accessible responsive UI, privacy-preserving local data, and a maintainable separation between conversion logic and presentation.

## Status

The application and quality-hardening work is being validated through the active audit pull request. See [`what_changed.md`](what_changed.md) for the exact checkpoint and [`ROADMAP.md`](ROADMAP.md) for milestone status. Do not interpret source-level completion as a release claim until the documented CI, platform, accessibility, and release-candidate checks are green.

## Product Features

- Length, area, volume, mass, speed, pressure, energy, power, angle, data size, frequency, time, temperature, and extensible custom categories/units architecture.
- High-precision decimal conversion with explicit rounding modes: nearest-even, half-away-from-zero, toward zero, away from zero, floor, and ceiling.
- Searchable unit library across stable IDs, names, symbols, aliases, and descriptive metadata.
- Favorites, recent conversions, pinned unit pairs, fast swap, keyboard navigation, and desktop shortcuts.
- Validated custom affine units using `base = value × scale + offset` without arbitrary expression execution.
- Batch conversion table plus deterministic CSV copying.
- Plain, scientific, and engineering notation.
- Locale-aware number parsing/formatting foundations and generated Flutter localization infrastructure.
- Offline-first static conversion data; no account is required for core conversions.
- Local preferences/history/custom units with bounded JSON backup and restore through file or clipboard workflows.
- Light, dark, and system themes plus an explicit reduced-motion preference.
- Screen-reader semantics, keyboard/touch interaction foundations, adaptive navigation, and accessible error handling.
- User-initiated link to official releases without background update tracking.
- Redacting structured diagnostics that avoid conversion history, clipboard payloads, and backup contents.
- Project-authored UnitFlow brand mark with editable vector source.

## Architecture

```text
crates/unitflow_core/      authoritative Rust conversion/domain core
crates/unitflow_bridge/    Flutter Rust Bridge API boundary
apps/unitflow_app/         adaptive Flutter application
fuzz/                      Rust fuzz targets
tool/                      repeatable developer/verification utilities
schemas/                   versioned portable backup schemas
assets/branding/           editable project branding sources
docs/                      architecture, setup, testing, accessibility, release docs
.github/                    CI, security, dependency, issue and release automation
```

The Rust core owns validated units, deterministic decimal conversion, precision/rounding, search, batch operations, and reusable result models. Flutter owns presentation, accessibility, local preferences, backup UX, localization, and platform integration. The Dart exact-decimal implementation remains a deterministic fallback while native bridge integration is validated.

See [`docs/architecture.md`](docs/architecture.md), [`docs/bridge.md`](docs/bridge.md), and [`docs/adr/0001-rust-core-flutter-ui.md`](docs/adr/0001-rust-core-flutter-ui.md).

## Supported Targets

| Platform | Intended status |
|---|---|
| Android | Primary target |
| Windows | Primary desktop target |
| Linux | Primary desktop target |
| macOS | Supported target |
| Web | Supported Flutter fallback target |
| iOS | iOS-ready target pending release validation/signing |

Actual platform release status is recorded only after the corresponding build/journey checks pass. See [`docs/platform-support.md`](docs/platform-support.md) and [`docs/release.md`](docs/release.md).

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

See [`docs/setup.md`](docs/setup.md) for platform prerequisites and [`docs/troubleshooting.md`](docs/troubleshooting.md) for common setup failures.

## Development Quality Gates

Core checks:

```bash
python3 tool/check_secrets.py
python3 tool/check_data_files.py
python3 tool/check_docs_links.py
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-features
cd apps/unitflow_app
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

Bridge generation and profiling:

```bash
bash tool/generate_bridge.sh
bash tool/profile_core.sh
```

See [`docs/testing.md`](docs/testing.md), [`docs/performance.md`](docs/performance.md), and [`docs/verification.md`](docs/verification.md).

## Local Data and Portability

UnitFlow keeps preferences, favorites, bounded recent history, pinned pairs, accessibility choices, and custom units locally by default. The portable backup format is versioned and validated before replacement of current state. Version 1 backups migrate deterministically to schema version 2, including the historical nearest-even rounding default.

See [`docs/data-format.md`](docs/data-format.md) and [`schemas/unitflow-backup-v2.schema.json`](schemas/unitflow-backup-v2.schema.json).

## Accessibility

UnitFlow is designed for keyboard/touch use, screen-reader-friendly controls, responsive text/layout, visible focus behavior, and reduced motion. Manual platform accessibility review remains a release gate, not an assumption from source code alone.

See [`docs/accessibility.md`](docs/accessibility.md).

## Security and Privacy

Static conversions work offline and require no account. Repository CI includes common credential-pattern scanning, structured-data validation, dependency review, CodeQL, Rust/Flutter quality gates, and documentation link validation. Suspected vulnerabilities should be reported privately according to [`SECURITY.md`](SECURITY.md).

See [`PRIVACY.md`](PRIVACY.md) and [`SECURITY.md`](SECURITY.md).

## Branding

Editable source artwork is stored in [`assets/branding/unitflow-mark.svg`](assets/branding/unitflow-mark.svg). Runtime Flutter branding is rendered from project primitives. See [`docs/branding.md`](docs/branding.md) before producing launcher, splash, or promotional assets.

## Contributing

Contributions are welcome. Read [`CONTRIBUTING.md`](CONTRIBUTING.md), follow [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md), add regression tests for behavior changes, avoid committing secrets or user data, and keep changes reviewable.

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
