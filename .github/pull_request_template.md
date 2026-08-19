## What changed

Describe the user-visible or engineering change and why it is needed.

## Validation

- [ ] `cargo fmt --all -- --check`
- [ ] `cargo clippy --workspace --all-targets --all-features -- -D warnings`
- [ ] `cargo test --workspace --all-features`
- [ ] `flutter analyze` in `apps/unitflow_app`
- [ ] `flutter test` in `apps/unitflow_app`
- [ ] Relevant manual checks completed or explicitly marked not applicable

## Quality checklist

- [ ] No secrets, credentials, private user data, or generated build output added
- [ ] Conversion changes include regression tests for boundaries/rounding where applicable
- [ ] Persistence changes preserve or intentionally migrate the versioned schema
- [ ] UI changes remain keyboard-usable and screen-reader understandable
- [ ] Offline-first/privacy behavior is preserved
- [ ] Documentation and `what_changed.md` are updated when the change affects contributors or release readiness

## Screenshots / recordings

Add media for meaningful UI changes when a runnable platform build is available. Do not include sensitive data.

## Related issues

Closes #
