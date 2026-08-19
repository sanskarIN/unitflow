# Release Checklist

## Before tagging

1. Update version numbers in `rust/Cargo.toml` and `app/pubspec.yaml`.
2. Update `CHANGELOG.md` and `what_changed.md`.
3. Run Rust format, Clippy, and tests.
4. Bootstrap Flutter platform folders using the target stable SDK.
5. Run Flutter analyze and tests.
6. Review conversion constants changed since the previous release.
7. Perform accessibility and responsive-layout checks.
8. Confirm no secrets, signing keys, generated credentials, or local environment files are tracked.

## Build checks

At minimum, produce a web build plus one native target available on the release host:

```bash
cd app
flutter build web
```

Platform-specific release builds should be produced only on appropriately configured hosts.

## Versioning

UnitFlow follows semantic versioning:

- patch: fixes without intended API breakage
- minor: backward-compatible features and new units
- major: incompatible API/data-format changes

## Tagging

```bash
git tag -a v0.1.0 -m "UnitFlow 0.1.0"
git push origin v0.1.0
```

Release notes should include user-visible changes, migration notes, validation performed, known limitations, and links to security information when relevant.
