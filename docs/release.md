# Release Guide

## Versioning

UnitFlow uses SemVer-style versions. During `0.x`, breaking changes may occur but must be documented. Stable releases should preserve stored-data and bridge compatibility or include explicit migration notes.

## Release checklist

1. Ensure `main` is current and protected according to repository guidance.
2. Confirm `CHANGELOG.md`, `ROADMAP.md`, and `what_changed.md` are current.
3. Run the complete Rust quality suite.
4. Run Flutter analysis/tests and build the intended release targets.
5. Perform dependency/security checks.
6. Verify no secrets or signing material are present in Git.
7. Validate accessibility basics and primary user journeys.
8. Verify About/version/license/support links.
9. Replace stale screenshots and release notes.
10. Tag the exact audited commit.

## Suggested local commands

```bash
cargo fmt --all -- --check
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace

cd apps/unitflow_app
flutter pub get
flutter analyze
flutter test
```

Then run platform builds required for the release, for example:

```bash
flutter build apk --release
flutter build appbundle --release
flutter build web --release
```

Desktop/macOS/iOS builds must run on compatible hosts with the required platform toolchains.

## Tagging

Example:

```bash
git tag -a v0.1.0-alpha.1 -m "UnitFlow 0.1.0-alpha.1"
git push origin v0.1.0-alpha.1
```

The GitHub release workflow should only package artifacts from version tags after validation.

## Artifacts

Release artifacts must be generated from source through documented commands. Do not commit signing keys. Checksums should be generated for distributable binaries when practical.

## Store releases

Mobile store publication has additional signing, privacy, screenshot, and listing requirements. Store credentials remain outside this public repository.

## Rollback

If a release contains a critical defect, publish a fixed patch/prerelease rather than rewriting an existing Git tag. Document impact and migration considerations in the changelog.
