# UnitFlow

**A precise, offline-first unit converter powered by a Rust conversion core and a Flutter interface.**

[![CI](https://github.com/sanskarIN/unitflow/actions/workflows/ci.yml/badge.svg)](https://github.com/sanskarIN/unitflow/actions/workflows/ci.yml)
[![Security](https://github.com/sanskarIN/unitflow/actions/workflows/codeql.yml/badge.svg)](https://github.com/sanskarIN/unitflow/actions/workflows/codeql.yml)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-sanskarIN-FFDD00?logo=buy-me-a-coffee&logoColor=000000)](https://buymeacoffee.com/sanskarIN)

UnitFlow is an open-source converter for Android, Windows, Linux, macOS, Web, and iOS-ready workflows. The project is designed around deterministic offline conversions, high-precision decimal arithmetic, accessible responsive UI, and a maintainable separation between domain logic and presentation.

## Status

The repository is under active development. See [`what_changed.md`](what_changed.md) for the exact implementation checkpoint and [`ROADMAP.md`](ROADMAP.md) for planned milestones.

## Features

- Length, area, volume, mass, speed, pressure, energy, power, angle, data size, frequency, time, temperature, and extensible categories.
- High-precision decimal conversion in the Rust core.
- Searchable catalog with symbols, aliases, and descriptions.
- Favorites, recents, pinned pairs, and quick swap architecture.
- Custom affine units (`base = value × factor + offset`) with validation.
- Batch conversion and export-ready result models.
- Scientific and engineering notation helpers.
- Locale-aware Flutter input/formatting architecture.
- Offline-first static conversion data.
- Light, dark, and system theme support.
- Keyboard and screen-reader oriented UI foundations.

## Screenshots

Real screenshots will replace these placeholders once release builds are available.

| Phone | Desktop | Dark mode |
|---|---|---|
| `docs/assets/screenshot-phone.png` | `docs/assets/screenshot-desktop.png` | `docs/assets/screenshot-dark.png` |

## Supported Platforms

| Platform | Target |
|---|---|
| Android | Primary |
| Windows | Primary desktop |
| Linux | Primary desktop |
| macOS | Supported target |
| Web | Supported target |
| iOS | Architecture ready |

## Tech Stack

- **Rust** — authoritative conversion/domain core.
- **rust_decimal** — deterministic decimal arithmetic.
- **Flutter / Dart** — adaptive cross-platform UI.
- **GitHub Actions** — quality, security, and release automation.

## Repository Layout

```text
crates/unitflow_core/   Rust domain and conversion engine
apps/unitflow_app/      Flutter application
docs/                   Architecture, setup, testing, release, ADRs
.github/                 CI, security, issue and PR automation
```

## Quick Start

### Rust core

```bash
cargo test --workspace
```

### Flutter app

```bash
cd apps/unitflow_app
flutter pub get
flutter analyze
flutter test
flutter run
```

See [`docs/setup.md`](docs/setup.md) for complete platform prerequisites.

## Development Quality Gates

Before opening a pull request:

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace
cd apps/unitflow_app
flutter pub get
flutter analyze
flutter test
```

## Architecture

The Rust crate owns unit definitions, validation, conversion rules, precision behavior, search, and reusable result models. Flutter owns presentation, accessibility, adaptive layout, local preferences, and platform integration. See [`docs/architecture.md`](docs/architecture.md) and [`docs/adr/0001-rust-core-flutter-ui.md`](docs/adr/0001-rust-core-flutter-ui.md).

## Security and Privacy

UnitFlow does not require an account for static conversions and is designed to work offline. User preferences and custom units are intended to stay on-device unless the user explicitly exports them. See [`SECURITY.md`](SECURITY.md) and [`PRIVACY.md`](PRIVACY.md).

## Contributing

Contributions are welcome. Read [`CONTRIBUTING.md`](CONTRIBUTING.md), follow the code of conduct, add tests for behavior changes, and keep commits atomic.

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
