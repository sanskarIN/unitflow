# Development Setup

## Prerequisites

- Git
- Rust stable toolchain with Cargo
- Flutter stable SDK
- Platform toolchains required by the Flutter target you plan to build

## Clone

```bash
git clone https://github.com/sanskarIN/unitflow.git
cd unitflow
```

Preferred local commit identity:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

## Rust core

```bash
cd rust
cargo test
cargo run -- 1 km m 8
cargo run -- --list
```

## Flutter frontend

Platform runner folders are intentionally bootstrap-generated so they match the installed Flutter SDK.

Unix-like systems:

```bash
./tool/bootstrap_platforms.sh
```

Windows PowerShell:

```powershell
./tool/bootstrap_platforms.ps1
```

Then:

```bash
cd app
flutter analyze
flutter test
flutter run
```

## Common Flutter targets

```bash
flutter run -d chrome
flutter run -d windows
flutter run -d linux
flutter run -d macos
flutter run -d android
```

Only targets supported by the current host/toolchain will be available.

## Repository hygiene

Generated build output, platform metadata caches, IDE state, environment files, and credentials are ignored. Do not commit secrets or signing material.
