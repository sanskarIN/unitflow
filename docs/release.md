# Release Guide

## Versioning

UnitFlow uses SemVer-style versions. During `0.x`, breaking changes may occur but must be documented. Stable releases should preserve stored-data and bridge compatibility or include explicit migration notes.

The current development target is `0.1.0-alpha.1`. A version string in source is not a release declaration; release status is tied to an audited commit/tag and its evidence.

## Release checklist

1. Ensure the intended release commit is on the protected release branch and has no unreviewed local/generated changes.
2. Confirm `CHANGELOG.md`, `ROADMAP.md`, and `what_changed.md` match the exact candidate.
3. Run the strict host-independent release-candidate verifier.
4. Confirm CI, CodeQL, dependency review, bridge generation, and repository-safety checks are green for the exact candidate.
5. Build every advertised native/web platform in its supported CI/host environment.
6. Install/run primary user journeys on each release platform class rather than relying only on compilation.
7. Verify Rust-backed native conversion on native targets and deterministic Dart fallback behavior on web.
8. Verify backup import/export, migration behavior, custom units, favorites/pins/history, rounding, themes, and reduced motion.
9. Perform keyboard, text-scaling, contrast, and screen-reader-oriented manual accessibility review.
10. Verify final launcher/splash branding, About/version/license/support/funding links, and required **Made by the Sanskar** credit.
11. Capture real release screenshots from validated builds. Never substitute mock/placeholder images as release evidence.
12. Verify no secrets, signing material, private endpoints, or real user data are present in Git or release artifacts.
13. Generate checksums for distributable archives/binaries.
14. Tag the exact audited commit and let the release workflow package only that tag.

## Strict local verification

Install the pinned Flutter Rust Bridge generator first:

```bash
cargo install flutter_rust_bridge_codegen --version 2.12.0 --locked
```

Then run:

```bash
bash tool/verify_release_candidate.sh
```

This verifies repository safety/data/docs, Rust formatting/lint/tests/release build, Flutter localization/format/analyze/tests, bridge regeneration, generated-source cleanliness, web release build, and the core profiling harness. It intentionally fails if binding generation or formatting changes tracked files, because generated sources must be normalized and committed before a release candidate is considered reproducible.

`tool/check.sh` is the faster development-quality command. It may skip bridge regeneration when the code generator is not installed; therefore it is not a substitute for `tool/verify_release_candidate.sh`.

## Platform builds

The release workflow validates multiple targets on compatible GitHub-hosted operating systems. Typical manual build commands include:

```bash
cd apps/unitflow_app
flutter build apk --release
flutter build appbundle --release
flutter build web --release
flutter build windows --release
flutter build linux --release
flutter build macos --release
flutter build ios --release --no-codesign
```

Run only the commands supported by the current host. iOS `--no-codesign` confirms compilation, not distributable signing/provisioning.

See `docs/platform-support.md` for the distinction between targeted, CI validated, manually validated, and release-ready.

## Bridge release boundary

Before calling a native platform release-ready, verify that the native application packages/loads the Rust bridge and a primary conversion journey crosses the intended native boundary. Successful binding generation alone is insufficient. See `docs/bridge.md`.

## Branding and screenshots

Use `assets/branding/unitflow-mark.svg` as the editable source of truth and follow `docs/branding.md` for launcher/splash exports. Screenshots must come from a real validated build and should cover representative phone/desktop/dark-mode states without personal data.

## Tagging

Example:

```bash
git tag -a v0.1.0-alpha.1 -m "UnitFlow 0.1.0-alpha.1"
git push origin v0.1.0-alpha.1
```

Do not move or rewrite a published release tag to hide a defect. Publish a corrective release instead.

## Artifacts and checksums

Release artifacts must be generated from source through documented commands. Signing keys remain outside this public repository. For downloadable archives, publish a checksum manifest generated from the exact artifacts produced by the release run.

## Store releases

Mobile store publication has additional signing, privacy, screenshots, content-rating, metadata, and listing requirements. Store credentials remain outside the repository and must never be placed in backup/environment examples.

## Rollback

If a release contains a critical defect, publish a fixed patch/prerelease rather than rewriting an existing Git tag. Document impact, affected versions, data compatibility, and migration considerations in the changelog/security advisory as appropriate.
