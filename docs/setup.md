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

## Rust core

```bash
cargo fetch
cargo test --workspace
```

## Flutter app

```bash
cd apps/unitflow_app
flutter pub get
flutter analyze
flutter test
flutter run
```

## Platform notes

### Android

Install Android Studio or the command-line Android SDK, an appropriate JDK supported by the current Flutter stable channel, and accept Android SDK licenses:

```bash
flutter doctor --android-licenses
```

### Windows

Use Windows with Visual Studio's Desktop development with C++ workload for Flutter Windows desktop builds.

### Linux

Install the packages required by Flutter's Linux desktop toolchain for your distribution (compiler, CMake/Ninja, GTK development headers, and related dependencies).

### macOS / iOS

Use macOS with current Xcode tooling. iOS builds require Apple platform signing configuration for physical-device/App Store deployment.

### Web

Use a Flutter-supported browser and run:

```bash
flutter run -d chrome
```

## Environment configuration

Static conversion does not require secrets. If optional environment-controlled features are added, document placeholder variables in `.env.example`. Never commit real credentials.

## Clean verification

Before release validation, remove generated artifacts and rebuild:

```bash
cargo clean
cd apps/unitflow_app
flutter clean
flutter pub get
flutter analyze
flutter test
```

Then build the intended platform using Flutter's documented `flutter build <target>` command.
