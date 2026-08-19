# UnitFlow Setup Guide

UnitFlow uses Rust for the authoritative native conversion domain and Flutter/Dart for the cross-platform application. Python 3 powers dependency-free repository integrity validators. Core conversion development does not require an account, API key, database, or online service.

## 1. Git

Verify:

```bash
git --version
```

Install or upgrade from the official Git distribution for your operating system if the command is missing or your installed release is no longer supported by your environment.

Clone the repository:

```bash
git clone https://github.com/sanskarIN/unitflow.git
cd unitflow
```

Maintainer commit identity:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

## 2. Python 3

Python 3 is used only for repository validation scripts and their standard-library tests. No third-party Python package installation is required.

Verify one of these commands is available:

```bash
python3 --version
```

On Windows, `python --version` or `py -3 --version` may be the installed launcher form. The PowerShell verification script detects all three common forms.

Run the repository-only checks without Rust or Flutter:

```bash
python3 -m unittest discover -s scripts/tests -p 'test_*.py'
python3 scripts/check_markdown_links.py
python3 scripts/check_release_consistency.py
python3 scripts/check_repository_hygiene.py
```

## 3. Rust

Install Rust using `rustup`, the Rust project's toolchain manager. UnitFlow tracks stable Rust unless the repository later pins a narrower toolchain.

Verify:

```bash
rustup --version
rustc --version
cargo --version
```

Update the stable toolchain:

```bash
rustup update stable
```

Install the components used by the quality gates:

```bash
rustup component add rustfmt clippy
```

Run the core checks:

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace --all-features
```

## 4. Flutter and Dart

Install the current supported Flutter stable SDK from Flutter's official installation guide. Flutter bundles a compatible Dart SDK; do not independently replace that bundled Dart version for this project.

Verify:

```bash
flutter --version
dart --version
flutter doctor -v
```

Upgrade an existing stable Flutter installation when appropriate:

```bash
flutter channel stable
flutter upgrade
flutter doctor -v
```

Resolve application dependencies and generate localization sources:

```bash
cd apps/unitflow_app
flutter pub get
flutter gen-l10n
```

Then run source-level Flutter checks:

```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

Generated localization Dart files live under `lib/l10n/generated/` and are intentionally ignored by Git. Edit ARB files instead of generated sources.

## 5. One-command repository verification

From the repository root on macOS/Linux or a compatible shell:

```bash
bash scripts/verify.sh
```

On Windows PowerShell:

```powershell
./scripts/verify.ps1
```

Both scripts run, in order:

1. standard-library tests for the Python repository validators;
2. Markdown-link, release-consistency, and repository-hygiene validation;
3. Rust formatting, Clippy, and tests;
4. Flutter dependency resolution and localization generation;
5. Dart formatting, Flutter analysis, and Flutter tests.

A complete run therefore requires Git, Python 3, Rust/Cargo, Flutter, and Dart on `PATH`. Native platform release builds are separate checks because they require platform-specific toolchains and reviewed native projects.

## 6. Platform toolchains

Install only the native toolchains for platforms you intend to build.

### Android

Use Android Studio or the Android command-line tools and a supported Android SDK/JDK combination reported healthy by `flutter doctor -v`.

### Windows

Use Windows with Visual Studio and the Desktop development with C++ workload required by Flutter.

### Linux

Install the compiler, CMake/Ninja, GTK development packages, and other dependencies listed by Flutter for your distribution. Confirm with `flutter doctor -v`.

### macOS and iOS

Use a supported macOS version with Xcode and command-line tools. iOS builds, signing, simulators, and App Store packaging require macOS/Xcode even though shared Flutter source can be edited elsewhere.

### Web

Use a browser/toolchain supported by the installed Flutter stable SDK. Confirm Web support with:

```bash
flutter devices
```

## 7. Native Flutter project scaffolding

The alpha repository currently keeps portable Flutter feature code separate from generated native scaffolding. Before claiming a platform release build, generate and review the native projects with the release Flutter SDK from `apps/unitflow_app`:

```bash
flutter create \
  --platforms=android,ios,web,windows,linux,macos \
  --org in.sanskar \
  .
```

On PowerShell, place the command on one line or use PowerShell continuation syntax instead of the Bash backslashes shown above.

Do not blindly commit regenerated files. Review package identifiers, minimum OS versions, permissions, entitlements, signing configuration, network capabilities, and any changes to existing source/configuration. See `docs/native-platforms.md` and `docs/platform-smoke.md`.

## 8. IDE recommendations

VS Code works well with the Rust Analyzer and Dart/Flutter extensions. Android Studio is useful for Android SDK/emulator management, and Xcode/Visual Studio are required for their respective native builds.

IDE plugins are conveniences; repository verification uses command-line tools so contributors and CI share the same quality gates.

## 9. Environment configuration

Core UnitFlow features need no `.env` secrets. `.env.example` documents this boundary. Real `.env` files and common signing credentials are ignored by Git and rejected by repository hygiene validation if accidentally tracked.

If a future optional online feature is introduced, its configuration must be documented explicitly and must not turn static offline conversion into an account/network dependency.

## 10. Troubleshooting

### Python is not found

Install a supported Python 3 distribution, reopen the terminal, and verify `python3`, `python`, or the Windows `py -3` launcher. The repository validators require only the Python standard library.

### `cargo` or `rustc` is not found

Restart the terminal after installing Rust and verify the rustup-managed Cargo bin directory is on `PATH`.

### `flutter` is not found

Add the Flutter SDK's `bin` directory to `PATH`, open a new shell, and rerun `flutter doctor -v`.

### Localization classes are missing

From `apps/unitflow_app` run:

```bash
flutter pub get
flutter gen-l10n
```

Then rerun analysis/tests. Do not hand-create the generated `app_localizations.dart` file.

### `flutter doctor` reports a native toolchain problem

Fix the specific Android/Visual Studio/Xcode/Linux dependency reported by `flutter doctor -v`. A green source-level test suite is not evidence that an unavailable native toolchain can build.

### Existing tools are out of support

Prefer upgrading through each tool's official installer/toolchain manager rather than mixing unrelated package managers. After upgrading, rerun `rustup`/`flutter doctor`, then the repository verification scripts.

## 11. Validation before submitting changes

At minimum run the relevant checks for the files you changed. Before release or a broad pull request, run the complete verification script and the required native platform build/smoke checks documented in `docs/release-checklist.md`.
