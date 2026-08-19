# Release Guide

UnitFlow releases are evidence-based. A source-level test suite, generated platform scaffold, or successful package command must not be presented as proof that a native release binary is ready unless the corresponding native project and platform checks were actually performed.

## Versioning

UnitFlow uses SemVer-style versions. During `0.x`, breaking changes may occur but must be documented. Stable releases should preserve stored-data and bridge compatibility or include explicit migration notes.

The release tag must equal `v` plus the Cargo workspace version exactly. For example, workspace version `0.1.0-alpha.1` requires tag `v0.1.0-alpha.1`.

## Release checklist

1. Ensure `main` is current and protected according to repository guidance.
2. Confirm `CHANGELOG.md`, `ROADMAP.md`, and `what_changed.md` are current.
3. Run the complete repository verification script.
4. Validate the intended release tag against the workspace version.
5. Perform dependency/security checks and review unresolved findings.
6. Build and test every native platform that will be claimed as supported by the release.
7. Verify no secrets, `.env` files, generated output, or signing material are committed.
8. Validate accessibility basics and primary user journeys on representative targets.
9. Verify About/version/license/support links and stored-data migration behavior.
10. Replace stale screenshots/release notes only with evidence from verified builds.
11. Tag the exact audited commit; do not move an existing published tag.

The detailed evidence checklist is in [`release-checklist.md`](release-checklist.md).

## Complete source verification

Unix-like shell:

```bash
bash scripts/verify.sh
```

PowerShell:

```powershell
./scripts/verify.ps1
```

The scripts run Python repository-validator tests, Markdown/release/hygiene validation, Rust formatting/Clippy/tests, Flutter dependency resolution/localization, Dart formatting, Flutter analysis, and Flutter tests.

For targeted troubleshooting, see [`testing.md`](testing.md).

## Tag validation

Before creating a release tag, validate the exact intended tag:

```bash
python3 scripts/check_release_tag.py v0.1.0-alpha.1
```

Substitute the intended version. The release GitHub Actions workflow runs this check automatically for tag-triggered executions and refuses to package a mismatched `v*` tag.

## Native and generated platform builds

`.github/workflows/platform-smoke.yml` generates temporary Flutter platform projects and tests whether shared source can compile against target toolchains. This is useful compatibility evidence, but generated scaffolds are not the reviewed platform projects distributed to users.

Before advertising a platform as release-verified:

1. generate or update the native project deliberately;
2. review identifiers, permissions, entitlements, minimum OS versions, build settings, assets, and signing boundaries;
3. commit the reviewed native project;
4. build that committed project in the intended release configuration;
5. launch and exercise representative user journeys on a compatible host/device;
6. record any platform-specific limitations in release notes.

See [`native-platforms.md`](native-platforms.md) and [`platform-smoke.md`](platform-smoke.md).

## Example platform build commands

From `apps/unitflow_app`, once the corresponding committed native project exists:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
```

Windows, Linux, macOS, and iOS builds require their compatible host/toolchains. iOS release/signing work requires macOS/Xcode.

## Tagging

Example only after the audited release commit passes the applicable checklist:

```bash
git tag -a v0.1.0-alpha.1 -m "UnitFlow 0.1.0-alpha.1"
git push origin v0.1.0-alpha.1
```

Never create a tag merely to see whether CI passes. Run source checks before tagging, then require the tag-triggered release workflow to independently rerun its gates.

## Release workflow artifacts

The release workflow:

- checks repository integrity and validator regressions;
- validates tag/version equality for tag-triggered runs;
- reruns Rust and Flutter source quality gates;
- packages the Rust crate and Flutter source bundle;
- creates SHA-256 checksums;
- uploads verification artifacts;
- creates a GitHub release only for an actual tag ref.

These source artifacts are not substitutes for platform-native installers/bundles. Native binary publication remains blocked until the corresponding native projects and release checks are complete.

## Store releases

Mobile/desktop store publication has additional signing, privacy, screenshot, listing, entitlement, and policy requirements. Store credentials remain outside this public repository. Never commit signing keys or provisioning material.

## Rollback

If a release contains a critical defect, publish a fixed patch/prerelease rather than rewriting an existing Git tag. Document impact, affected versions, migration considerations, and verification of the replacement release in the changelog/release notes.
