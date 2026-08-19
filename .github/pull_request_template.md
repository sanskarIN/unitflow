## What changed

Describe the user-visible or engineering change and why it is needed.

## Verification

- [ ] `cargo fmt --all -- --check`
- [ ] `cargo clippy --workspace --all-targets --all-features -- -D warnings`
- [ ] `cargo test --workspace --all-features`
- [ ] `flutter analyze --fatal-infos --fatal-warnings`
- [ ] `flutter test`
- [ ] Relevant manual journey checked where automation is insufficient

If a check is not applicable or could not run, explain why instead of marking it complete.

## Quality checklist

- [ ] Tests cover behavior changes or the reason they are unnecessary is documented.
- [ ] No secrets, credentials, signing keys, private endpoints, or real user data were added.
- [ ] Accessibility and keyboard/touch behavior were considered for UI changes.
- [ ] Static conversion remains offline-capable.
- [ ] Documentation and `what_changed.md` are updated when needed.
- [ ] Backward compatibility/migration impact is documented.

## Screenshots / recordings

Add UI evidence for visual changes when useful. Do not include private user data.
