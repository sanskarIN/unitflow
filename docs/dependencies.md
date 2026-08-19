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

## Automated update configuration

`.github/dependabot.yml` configures weekly update checks for:

- Cargo dependencies in the workspace root;
- Dart/Flutter packages in `apps/unitflow_app`;
- GitHub Actions used by repository workflows.

The schedules are intentionally staggered and the number of simultaneously open update pull requests is bounded. Dependabot is an update-discovery mechanism, not an approval mechanism: dependency pull requests still require review and applicable quality/platform checks.

Pull-request dependency review and CodeQL provide additional automated signals. Repository-level dependency alerts and secret scanning should remain enabled where the GitHub repository plan/settings support them.

## Update workflow

Before merging a dependency update:

1. read the dependency's release notes for breaking/security changes;
2. inspect the Dependabot or manual manifest/lockfile diff;
3. resolve package metadata from a clean checkout;
4. run `scripts/verify.sh` or `scripts/verify.ps1`;
5. run native platform builds for dependencies that include native code;
6. review changes to permissions, manifests, entitlements, generated files, and transitive packages;
7. update documentation when minimum tool/platform versions change;
8. keep dependency-update commits separate from unrelated feature work.

Never auto-merge a dependency update solely because the version is newer or an automated check opened the pull request.

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

## GitHub Actions dependencies

Action version changes deserve the same review as source dependencies because workflows can execute code with repository permissions. Check the upstream action repository/release notes, keep permissions least-privileged, and review unexpected changes to workflow behavior before merging.

## Lockfiles and reproducibility

Application lockfiles should be committed when the package manager/workflow expects them. Libraries should follow ecosystem conventions while retaining enough metadata for reproducible CI and release verification.

A dependency update is complete only after the relevant lockfiles, generated metadata, tests, repository validators, and required platform checks agree with the declared manifests.
