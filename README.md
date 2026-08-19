# UnitFlow

**UnitFlow** is a production-focused, offline-first unit converter built as a Rust core library with a Flutter frontend.

> Made by the Sanskar

## Goals

- Fast, reliable unit conversion across common scientific and everyday categories.
- High-precision decimal arithmetic in the Rust core.
- Offline-first behavior for static conversions.
- Searchable units with symbols, aliases, descriptions, favorites-ready metadata, and quick swap workflows.
- Accessible Flutter UI for Android, Windows, Linux, macOS, Web, with an iOS-ready project structure.
- Strong engineering quality: linting, formatting, tests, CI, security guidance, documentation, and release discipline.

## Current categories

Length, mass, temperature, time, area, volume, speed, data, pressure, energy, power, and angle.

## Repository layout

```text
.
├── app/                 # Flutter frontend
├── rust/                # Rust conversion engine
├── docs/                # Engineering and user documentation
├── .github/             # CI and contribution templates
├── CHANGELOG.md
├── CONTRIBUTING.md
├── ROADMAP.md
└── what_changed.md
```

## Quick start

### Rust core

```bash
cd rust
cargo test
```

### Flutter app

```bash
cd app
flutter pub get
flutter analyze
flutter test
flutter run
```

The Flutter app includes a dependency-free Dart conversion adapter so the UI runs immediately on supported Flutter targets. The Rust crate is the authoritative high-precision conversion engine and is structured for native/WASM bridge integration without changing its public conversion model.

## Quality commands

```bash
cargo fmt --manifest-path rust/Cargo.toml --check
cargo clippy --manifest-path rust/Cargo.toml --all-targets --all-features -- -D warnings
cargo test --manifest-path rust/Cargo.toml

cd app
flutter analyze
flutter test
```

## License

MIT. See [LICENSE](LICENSE).

## Security and support

See [SECURITY.md](SECURITY.md) and [SUPPORT.md](SUPPORT.md).
