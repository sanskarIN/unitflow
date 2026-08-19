# Dependency maintenance

UnitFlow keeps dependencies deliberately small. Every dependency adds update, security, licensing, and platform-compatibility work, so additions should solve a concrete problem that is difficult to implement safely with the standard library or existing stack.

## Current dependency boundaries

### Rust

The Rust core should remain focused on deterministic domain behavior. New crates require review for:

- maintenance activity and security history;
- transitive dependency size;
- MSRV/toolchain implications;
- unsafe-code usage relevant to the feature;
- license compatibility with MIT distribution;
- deterministic/offline behavior;
- Web/native portability if the dependency crosses the bridge boundary.

### Flutter/Dart

Flutter dependencies should be chosen for platform integration or mature reusable behavior rather than UI convenience that can be expressed with the SDK.

Review:

- Android/iOS/desktop/Web support;
- native permissions and entitlements;
- network behavior and telemetry;
- platform minimum versions;
- maintenance status;
- package licensing;
- generated-code/toolchain requirements.

## Update workflow

Before merging a dependency update:

1. read the dependency's release notes for breaking/security changes;
2. resolve lock/package metadata from a clean checkout;
3. run `scripts/verify.sh` or `scripts/verify.ps1`;
4. run native platform builds for dependencies that include native code;
5. review changes to permissions, manifests, entitlements, generated files, and transitive packages;
6. update documentation when minimum tool/platform versions change;
7. keep dependency-update commits separate from unrelated feature work.

## Useful local commands

Rust:

```bash
cargo tree
cargo tree -d
cargo update
cargo test --workspace --all-features
```

Flutter:

```bash
cd apps/unitflow_app
flutter pub outdated
flutter pub upgrade --dry-run
flutter pub get
flutter analyze --fatal-infos --fatal-warnings
flutter test
```

Review command output rather than automatically accepting every available major update.

## Automated repository checks

The repository includes pull-request dependency review and CodeQL workflows. Repository-level dependency alerts, secret scanning, and automated update tooling should remain enabled/configured where available.

Creation of `.github/dependabot.yml` was blocked by the connected repository write path during the current implementation session. That missing configuration remains explicit in `ROADMAP.md` and `what_changed.md`; it must not be described as completed until the file/settings are actually present.

## Lockfiles and reproducibility

Application lockfiles should be committed when the package manager/workflow expects them. Libraries should follow ecosystem conventions while retaining enough metadata for reproducible CI and release verification.

A dependency update is complete only after the relevant lockfiles, generated metadata, tests, and platform checks agree with the declared manifests.
