# Native platform completion plan

UnitFlow's Flutter feature code is intentionally portable, but repository-level platform support is not complete until generated native projects are committed and verified with the intended Flutter SDK.

## Current boundary

The repository contains Flutter application/domain/presentation source and tests, but native Flutter platform scaffolding must be generated and reviewed before binary release claims are made.

## Generation procedure

From `apps/unitflow_app` with the release Flutter SDK installed:

```bash
flutter create \
  --platforms=android,ios,web,windows,linux,macos \
  --org in.sanskar \
  .
```

Before committing generated files, review the diff carefully. Do not blindly accept regenerated `pubspec.yaml`, analysis settings, source files, minimum OS versions, signing configuration, permissions, network entitlements, or package identifiers if they conflict with UnitFlow's existing architecture.

## Required platform review

### Android

- choose and document a stable application ID;
- ensure no unnecessary permissions are declared;
- verify min/target SDK values supported by the selected Flutter release;
- add release signing only through local/CI secrets, never committed keys;
- build and install a release artifact on a representative device/emulator.

### Windows

- verify app identity, executable metadata, icon resources, window minimum sizing, and release build;
- smoke-test keyboard shortcuts, clipboard export, persistence, and external URL opening.

### Linux

- verify compiler/runtime prerequisites in setup docs;
- build a release bundle on a supported distribution;
- smoke-test clipboard, persistence, keyboard navigation, and URL launch behavior.

### macOS

- verify bundle identifier, deployment target, entitlements, and sandbox implications;
- test keyboard shortcuts using Command modifiers;
- document signing/notarization separately from local debug builds.

### Web

- verify `flutter build web` from a clean checkout;
- review CSP/hosting headers at deployment time;
- confirm local persistence behavior and generated localization assets;
- verify responsive navigation at narrow and wide browser widths.

### iOS

- generate and keep the project iOS-ready without claiming a distributed iOS release until macOS/Xcode build, signing, simulator/device tests, and App Store requirements are completed.

## Release evidence

A platform becomes release-verified only after its build command and smoke tests have actually passed for the release commit. Record that evidence in release notes or a release verification record rather than inferring support from portable source code alone.

## Rust bridge integration

Native scaffolding work should be coordinated with `docs/bridge.md`. The bridge must use stable decimal-string DTOs and parity tests. Web should continue using the deterministic Dart engine unless a Web-compatible Rust integration is explicitly introduced and tested.
