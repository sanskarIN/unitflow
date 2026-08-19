# Setup

## Prerequisites

Install the stable toolchains required for the platform you plan to build.

### Rust

Install stable Rust with `rustup`, then ensure these components are available:

```bash
rustup component add rustfmt clippy
rustc --version
cargo --version
```

### Flutter

Install the stable Flutter SDK and verify:

```bash
flutter --version
flutter doctor -v
```

Resolve platform-specific `flutter doctor` requirements before release builds.

## Clone

```bash
git clone https://github.com/sanskarIN/unitflow.git
cd unitflow
```

Maintainer commit identity:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

## Rust core and bridge

```bash
cargo fetch
cargo test --workspace --all-features
```

The Rust workspace contains the authoritative `unitflow_core` domain crate and the thin `unitflow_bridge` Flutter FFI boundary.

## Flutter app

Resolve Flutter packages and generated localization code:

```bash
cd apps/unitflow_app
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

### Generate platform shells from a clean clone

Platform runner projects are reproducible generated inputs rather than hand-edited business logic. From the repository root:

```bash
bash tool/bootstrap_platforms.sh
```

The script runs Flutter's project generator for Android, Web, Windows, Linux, macOS, and iOS with the stable project identifier `in.sanskar.unitflow` and then resolves packages.

On a host that supports the selected target, run:

```bash
cd apps/unitflow_app
flutter run
```

### Generate Rust↔Flutter bindings

When working on native bridge code:

```bash
cargo install flutter_rust_bridge_codegen --version 2.12.0 --locked
bash tool/generate_bridge.sh
```

Generated bridge code must be followed by the full quality suite.

## Platform notes

### Android

Install Android Studio or the command-line Android SDK, an appropriate JDK supported by the installed Flutter stable channel, and accept Android SDK licenses:

```bash
flutter doctor --android-licenses
```

No broad storage permission is required for ordinary conversion. Backup import/export is initiated through platform file pickers.

### Windows

Use Windows with Visual Studio's **Desktop development with C++** workload for Flutter Windows desktop builds.

### Linux

Install the packages required by Flutter's Linux desktop toolchain for your distribution, including a compiler, CMake/Ninja, GTK development headers, and related dependencies.

### macOS / iOS

Use macOS with current Xcode tooling. iOS release deployment requires Apple signing configuration. Signing credentials and provisioning material must never be committed to this public repository.

### Web

Use a Flutter-supported browser and run:

```bash
flutter run -d chrome
```

The deterministic Dart decimal engine provides the current web fallback while the native targets use the Rust bridge integration path.

## Environment configuration

Static conversion does not require secrets. `.env.example` contains placeholders only. If an optional online integration is introduced later, document it explicitly and never commit real credentials.

## Clean verification

Before release validation, remove generated build artifacts and rebuild:

```bash
cargo clean
cd apps/unitflow_app
flutter clean
flutter pub get
flutter gen-l10n
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

Or from the repository root run:

```bash
bash tool/check.sh
```

Then build the intended platform using Flutter's documented `flutter build <target>` command or the tagged release workflow.
