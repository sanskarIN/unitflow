# Platform support matrix

UnitFlow is designed as one Flutter application around a portable Rust conversion core. The shared application code is kept Web-safe and the repository now enforces six explicit targets: Android, iOS, Web, Windows, Linux, and macOS.

## Supported targets

| Platform | Support level | Automated build evidence | Distribution-only work |
| --- | --- | --- | --- |
| Android | Supported target | Release Android App Bundle build | Production keystore, Play signing, store metadata |
| iOS | Supported target | Release device app build with `--no-codesign` | Apple signing, provisioning, App Store packaging |
| Web | Supported target | Release Web bundle build | Hosting/deployment policy and production headers |
| Windows | Supported target | Release Windows desktop bundle build | Installer choice and optional code signing |
| Linux | Supported target | Release Linux desktop bundle build | Distribution/package format selection |
| macOS | Supported target | Release macOS app build | Apple signing, notarization, distribution packaging |

The build matrix lives in `.github/workflows/platform-smoke.yml`. Despite the historical filename, it now performs committed-first release builds and uploads build artifacts for every target. If a platform project is not yet committed in a checkout, the job can regenerate that target with Flutter before building it.

## Cross-platform repository contract

`scripts/check_platform_support.py` makes six-platform support an enforced repository property. It verifies that:

- all six platform jobs exist in the build workflow;
- every target runs the expected release-mode Flutter build command;
- Bash and PowerShell platform bootstrap scripts reference all six targets;
- the platform-materialization workflow references all six targets;
- committed platform projects are either all present or all absent, never a partial set;
- shared Flutter libraries do not introduce an unconditional `dart:io` import that would make the library unavailable on Web.

This check runs from:

- `scripts/verify.sh`;
- `scripts/verify.ps1`;
- the main CI repository-integrity job;
- the release verification workflow.

## Platform project materialization

`scripts/bootstrap_platforms.sh` and `scripts/bootstrap_platforms.ps1` generate all six platform projects with Flutter itself rather than maintaining hand-copied native templates.

`.github/workflows/materialize-platforms.yml` automates the same process for the repository. It:

1. installs stable Flutter;
2. rejects an unsafe partially materialized state;
3. generates Android, iOS, Web, Windows, Linux, and macOS projects together;
4. runs Flutter source checks;
5. stages only the intended platform projects and `.metadata`;
6. regenerates `docs/platform-file-inventory.md` from the Git index;
7. runs inventory, release-consistency, and hygiene validation;
8. commits the generated platform projects when there are changes;
9. dispatches the cross-platform build matrix for the committed result.

The generated-file inventory is intentionally separate from the hand-maintained repository inventory so Flutter-generated platform trees can remain exhaustive without turning the human documentation into hundreds of repetitive entries.

## Shared acceptance criteria

A release-supported platform should verify:

- launch without requiring an account or network connection;
- exact common conversions and affine temperature conversions;
- locale-aware decimal entry and display;
- favorites, pinned pairs, recents, and settings persistence;
- custom-unit validation;
- backup export/import validation;
- batch table behavior;
- adaptive navigation across compact and desktop layouts;
- keyboard navigation where a hardware keyboard is expected;
- screen-reader labels, large-text behavior, contrast, and touch-target review;
- no unexpected outbound network traffic for the offline conversion feature set.

## Release build versus store-ready package

A successful release-mode build proves that the source, Flutter platform project, plugins, and platform compiler/toolchain can produce a release artifact. It does **not** by itself provide production signing credentials or complete a store submission.

UnitFlow intentionally keeps secrets out of source control. Android production signing, Apple signing/provisioning/notarization, and any platform-store credentials must be supplied through secure release infrastructure rather than committed files.

## Rust bridge

The Rust source bridge service and versioned protocol exist, but native generated Rust↔Flutter bindings and native-library packaging are a separate hardening milestone. Until those bindings are release-verified, the deterministic Dart engine remains the portable execution path for the Flutter application, including Web.

Native bridge integration must preserve exact-decimal parity and must not reduce support for any of the six Flutter targets.
