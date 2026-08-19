# Platform Support Matrix

UnitFlow is designed as a cross-platform Flutter application with a Rust conversion core. A platform is not called release-ready merely because Flutter can generate a shell for it; release status requires build and primary-journey evidence.

| Platform | Product target | Static conversion | Native Rust target | Release evidence required |
|---|---|---|---|---|
| Android | Primary | Offline | Yes | release APK/app-bundle build, install, conversion journey, backup/settings checks |
| Windows | Primary desktop | Offline | Yes | release desktop build, launch, keyboard navigation, conversion journey |
| Linux | Primary desktop | Offline | Yes | release bundle build, launch, conversion journey |
| macOS | Supported | Offline | Yes | release app build, launch, conversion journey |
| Web | Supported | Offline after load | No native library | release web build, deterministic Dart fallback journey |
| iOS | iOS-ready | Offline | Yes | no-codesign CI validation plus signed device/App Store validation before distribution |

## Shared expectations

Every supported target must preserve:

- deterministic static conversion behavior;
- no account requirement for core conversion;
- local-only preferences/history/custom units by default;
- validated backup import behavior;
- light/dark/system theme behavior;
- text scaling and accessible semantics;
- user-controlled reduced motion;
- user-visible **Made by the Sanskar** credit;
- no mandatory network request during static conversion.

## Desktop keyboard behavior

Windows, Linux, macOS, and web desktop layouts support navigation shortcuts in the application shell:

- Ctrl/Cmd + `1` — Converter
- Ctrl/Cmd + `2` — Library
- Ctrl/Cmd + `3` — History
- Ctrl/Cmd + `,` — Settings
- Ctrl/Cmd + `K` — Library/search destination

Manual release review must verify focus visibility and logical traversal rather than assuming shortcut registration alone proves accessibility.

## Web boundary

The web target cannot load the ordinary native Rust dynamic/static library. UnitFlow therefore retains deterministic exact-decimal Dart conversion as the web/fallback path. Web release validation must compare representative results against Rust regression vectors to prevent divergence.

## iOS boundary

iOS CI can validate a release build without code signing, but distribution requires signing/provisioning under an Apple developer identity. CI success without signing is not equivalent to an App Store-ready artifact.

## Release workflow

`.github/workflows/release.yml` builds/validates the platform matrix appropriate to GitHub-hosted runners. Generated platform shells are used as build scaffolding until platform-specific files are committed and fully branded. Launcher/splash branding and actual installed-app validation remain release-candidate gates.

## Status language

Use these terms consistently:

- **targeted** — architecture/source supports the platform;
- **CI validated** — automated platform build/tests passed for a specific commit;
- **manually validated** — primary user journeys were run on the platform;
- **release-ready** — required automated/manual/signing/packaging gates are satisfied for a release candidate.

Record concrete evidence in `what_changed.md` and the release verification record.
