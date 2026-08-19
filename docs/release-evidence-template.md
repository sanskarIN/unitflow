# Release Evidence Record

Use one copy of this template per release candidate. Evidence is valid only for the exact commit/tag recorded below.

## Candidate identity

- Version/tag:
- Commit SHA:
- Verification date:
- Rust toolchain:
- Flutter toolchain:
- FRB generator version: `2.12.0`

## Automated quality

- [ ] Repository safety job passed.
- [ ] Rust formatting/lint/tests passed.
- [ ] Flutter localization/format/analyze/tests passed.
- [ ] Rust↔Flutter bridge integration/generation is reproducible with a clean diff.
- [ ] CodeQL passed.
- [ ] Dependency review passed.
- [ ] Strict `tool/verify_release_candidate.sh` passed without modifying tracked files.

Record workflow URLs or immutable run identifiers here:

```text
CI:
CodeQL:
Dependency review:
Release validation:
```

## Conversion parity

- [ ] Shared Rust/Dart vectors pass.
- [ ] Representative temperature affine conversions pass.
- [ ] Representative decimal and binary data-size conversions pass.
- [ ] Explicit rounding-mode checks pass.
- [ ] Custom affine-unit checks pass.

## Platform matrix

| Platform | Build | Launch | Conversion | Backup/settings | Native bridge/fallback | Accessibility | Branding |
|---|---|---|---|---|---|---|---|
| Android | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Windows | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Linux | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| macOS | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |
| Web | [ ] | [ ] | [ ] | [ ] | fallback [ ] | [ ] | [ ] |
| iOS | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] | [ ] |

For iOS, distinguish no-codesign compilation from signed-device/App Store validation.

## Primary journey

For every advertised release platform:

- [ ] Launch without signing into an account.
- [ ] Convert a representative decimal value offline.
- [ ] Swap the pair.
- [ ] Pin/favorite the pair.
- [ ] Record and reopen history.
- [ ] Create/use/remove/undo a custom unit.
- [ ] Export a backup.
- [ ] Reject an invalid backup without corrupting current state.
- [ ] Restore a valid compatible backup.
- [ ] Change precision/notation/rounding/theme/reduced-motion settings.
- [ ] Verify the required **Made by the Sanskar** credit.

## Accessibility

- [ ] Keyboard-only navigation checked where applicable.
- [ ] Focus indicators visible.
- [ ] Large text / text scaling checked.
- [ ] Screen-reader-oriented labels/order checked.
- [ ] Light and dark contrast checked.
- [ ] Reduced motion checked.
- [ ] Error states are understandable without color alone.

## Branding and screenshots

- [ ] Final launcher icon uses UnitFlow artwork.
- [ ] Final startup/splash presentation uses UnitFlow artwork.
- [ ] Phone screenshot captured from this candidate.
- [ ] Desktop screenshot captured from this candidate.
- [ ] Dark-mode screenshot captured from this candidate.
- [ ] Screenshots contain no personal/private data.

## Performance and robustness

- [ ] `tool/profile_core.sh` output recorded with hardware/toolchain context.
- [ ] Fuzz campaign duration/targets recorded.
- [ ] No crash or data-loss regression remains open for the candidate.

Profiling/fuzz notes:

```text
Host:
CPU:
OS:
Profile output:
Fuzz targets and duration:
```

## Release artifacts

- [ ] Artifacts were produced from the exact audited tag.
- [ ] `SHA256SUMS` generated and verified.
- [ ] Signing/notarization/store credentials were supplied outside source control.
- [ ] Release notes match the exact candidate.
- [ ] `CHANGELOG.md`, `ROADMAP.md`, and `what_changed.md` contain no stale claims.

## Known limitations

List only verified limitations that remain acceptable for this release. Do not hide a failed required gate here.
