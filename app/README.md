# UnitFlow Flutter Frontend

This directory contains the Flutter presentation layer for UnitFlow.

## Features

- Material 3 responsive UI
- 12 conversion categories
- Searchable unit selection
- Unit swap
- Copy result
- Session favorites
- Recent conversion history
- Batch conversion
- Precision controls
- Scientific notation
- Light/dark system theme support
- Accessibility semantics on key controls

## Run

If platform runner folders are not present, generate them from the repository root:

```bash
./tool/bootstrap_platforms.sh
```

Windows PowerShell:

```powershell
./tool/bootstrap_platforms.ps1
```

Then:

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Architecture note

The Flutter layer currently includes a small dependency-free Dart conversion adapter so the app can run immediately across Flutter targets. The precision-focused Rust crate under `../rust` is the authoritative core and is prepared for a future native/WebAssembly bridge described in `../ROADMAP.md` and `../docs/architecture.md`.
