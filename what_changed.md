# UnitFlow — Development Handoff

This file is the primary continuation checkpoint for future UnitFlow development sessions so chat responses can stay short while repository work remains fully traceable.

Last updated: **2026-08-20**

Repository: `https://github.com/sanskarIN/unitflow`

Branch: **`main`**

Current source version: **`2.0.12`**

Flutter build number: **`12`**

Latest inspected pre-handoff commit: **`3087fe93f992e634f36b62fe2b5a76b5af8cd3fe`** (`docs: align testing strategy with accessibility and platform builds`)

## Current release state

UnitFlow remains an enforced six-target Flutter project for:

- Android;
- iOS;
- Web;
- Windows;
- Linux;
- macOS.

The repository retains deterministic six-platform generation, all-or-nothing platform materialization automation, release-mode build jobs for all six targets, build artifact upload definitions, generated-platform inventory support, and repository validators that prevent target drift or partial committed platform sets.

The previous continuation hardened the Rust↔Flutter bridge contract with protocol/capability negotiation, fail-closed compatibility, real single/batch source APIs, stable unit-ID validation, a shared 256-target batch ceiling, fallback/native behavior parity, and cross-language release-consistency checks.

This continuation hardened accessibility behavior that can be implemented safely before native platform execution is available.

**Do not call `v2.0.12` a fully verified native/store release yet.** The latest inspected live `main` tree still does not contain the generated Android/iOS/Web/Windows/Linux/macOS project directories. Generated Rust↔Flutter bindings, runtime native-engine selection, native library packaging/loading, generated-boundary parity execution, native E2E evidence, full accessibility/performance review, signing/notarization, and final release-candidate verification remain open.

No `v2.0.12` tag was created.

## Accessibility hardening completed in this continuation

### 1. Central reduced-motion policy

`apps/unitflow_app/lib/app/theme/app_theme.dart` now contains `AppMotion` alongside the existing spacing/radius/breakpoint/theme tokens.

The policy provides:

- `modalSurfaceStyle(BuildContext)` — returns `AnimationStyle.noAnimation` when `MediaQuery.disableAnimations` is active;
- `routeDuration(BuildContext, Duration)` — returns zero duration when reduced motion is requested.

This gives future modal/custom-transition code one shared accessibility policy instead of duplicating platform checks in individual screens.

### 2. About navigation now respects reduced motion

`apps/unitflow_app/lib/app/app_shell.dart` no longer always relies on the default animated Material route for the About page.

When the platform requests disabled animations:

- the route uses a zero-duration `PageRouteBuilder`;
- forward and reverse transition durations both resolve through `AppMotion`;
- normal Material navigation remains unchanged otherwise.

### 3. Batch modal now respects reduced motion

`apps/unitflow_app/lib/features/converter/presentation/converter_screen.dart` now supplies the shared motion policy to `showModalBottomSheet` through `sheetAnimationStyle`.

When reduced motion is active, the batch-results modal does not force the normal sheet entrance/exit animation.

### 4. Converter pin state is semantic, not icon-only

The converter's pin/unpin controls now expose an explicit semantic toggled state in addition to visible icons/labels.

Both the compact action and current-pair action are wrapped with merged semantics so assistive technology can distinguish the on/off state rather than receiving only a generic button name.

### 5. Converter selectors expose semantic context

The reusable converter dropdown wrapper now exposes:

- the field label;
- the currently selected display value;
- the existing interactive dropdown subtree.

This improves the source/category/target context available to screen readers without changing conversion behavior.

### 6. Conversion result is no longer a keystroke live region

The result panel previously set `liveRegion: true` whenever a conversion result existed.

Because UnitFlow recalculates while the user types, that could cause repeated screen-reader announcements on every keystroke and contradicted the accessibility documentation's conservative-announcement policy.

The result remains a semantic container with a stable result description and selectable/copyable output, but is no longer configured as a continuously updating live region.

### 7. Accessibility regression test added

New tracked test:

- `apps/unitflow_app/test/accessibility_smoke_test.dart`

It covers:

- reduced-motion modal style resolving to zero animation duration;
- reduced-motion route duration resolving to zero;
- converter pin control exposing semantic toggle state;
- semantic state changing from unpinned to pinned after interaction.

This is automated source/widget evidence only. It does not replace real TalkBack/VoiceOver, keyboard/focus, contrast, touch-target, or large-text review.

### 8. Repository inventory updated

`docs/repository-inventory.md` now includes the new accessibility smoke test so exact tracked-file inventory validation remains synchronized.

### 9. Accessibility documentation expanded

`docs/accessibility.md` now documents:

- implemented source-level safeguards;
- the centralized reduced-motion policy;
- semantic pin state;
- semantic selector context;
- conservative conversion-result announcements;
- automated coverage boundaries;
- manual release review requirements;
- explicit warning that widget/source tests are not a completed accessibility audit.

### 10. Testing documentation corrected and expanded

`docs/testing.md` now includes accessibility safeguards in the project quality strategy and documents `accessibility_smoke_test.dart`.

It also fixes stale platform-workflow wording: `.github/workflows/platform-smoke.yml` retains its historical name but is now documented correctly as a committed-first six-platform **release-mode build matrix** with transition-time generation fallback and artifact upload, not merely temporary debug scaffold smoke testing.

### 11. Roadmap and changelog updated

`ROADMAP.md` now marks source-level reduced-motion/semantic safeguards and widget smoke coverage complete while keeping the real manual accessibility audit open.

`CHANGELOG.md` records:

- accessibility smoke coverage;
- shared reduced-motion behavior;
- semantic pin/selector improvements;
- removal of excessive live-region announcements.

## Bridge hardening retained from the previous continuation

The current tree still includes all source-level bridge hardening completed immediately before this accessibility pass:

- bridge protocol version `1`;
- backend metadata;
- required capability set:
  - `convert`;
  - `batchConvert`;
  - `canonicalDecimalText`;
- Flutter fail-closed compatibility validation;
- stable protocol/capability mismatch failures;
- stable unit-ID syntax validation;
- actual Flutter single and batch bridge source interfaces;
- Rust ordered batch conversion;
- shared 256-target batch ceiling across Rust bridge, Flutter bridge DTO, and Dart fallback;
- bounded lazy-iterable consumption in the fallback;
- Rust/Flutter regression coverage;
- repository release-consistency checks that lock protocol/capabilities/batch ceiling across code/docs/fixture/fallback.

Generated bindings and production runtime native-engine selection still do not exist and must not be implied from these source contracts.

## Live platform-tree inspection

The live `apps/unitflow_app` directory was re-inspected after this accessibility continuation.

It currently contains only:

```text
analysis_options.yaml
l10n.yaml
lib/
pubspec.yaml
test/
```

The following generated project directories are still absent:

```text
android/
ios/
web/
windows/
linux/
macos/
```

Therefore the repository is still in its intended **generation-ready** state rather than a committed-platform **materialized** state.

Do not claim all six generated platform projects are committed until live `main` contains all six together.

## Verification evidence and limitations

### Connected GitHub evidence

All changes in this continuation were written directly to live `main` through the connected GitHub integration.

The live branch was re-read after the work. Before this handoff update, `main` pointed to:

```text
3087fe93f992e634f36b62fe2b5a76b5af8cd3fe
```

with the requested commit identity visible as:

```text
Sanskar <sanskarin@outlook.in>
```

The repository's generated platform directories remained absent on that inspected tree.

### Local execution limitation

This continuation does not claim local output for:

- `dart format`;
- `flutter analyze`;
- `flutter test`;
- `cargo fmt`;
- `cargo clippy`;
- `cargo test`;
- Android/iOS/Web/Windows/Linux/macOS release builds.

The connected environment used for repository writes does not provide trustworthy local Flutter/Rust/native build execution for this repository. Source changes, tests, workflow definitions, and documentation are implementation evidence, not proof that those commands passed.

### Accessibility evidence boundary

The new widget tests and source changes prove the intended source contract only.

They do **not** prove:

- TalkBack behavior on Android;
- VoiceOver behavior on iOS/macOS;
- Windows Narrator behavior;
- Linux screen-reader behavior;
- browser assistive-technology behavior;
- keyboard/focus traversal on every desktop target;
- contrast compliance under every rendered theme state;
- large-text behavior on real devices;
- touch-target behavior on native builds.

Those remain release-candidate evidence requirements.

## Remaining blockers before `v2.0.12` can be called fully release-verified

1. Materialize, review, and commit all six Flutter platform directories plus `.metadata` together.
2. Run and review the six-platform release build matrix against the committed platform projects.
3. Fix every target-specific build failure surfaced by real runner execution.
4. Generate the actual Rust↔Flutter binding layer around the existing bridge service.
5. Implement one-time runtime engine selection using fail-closed protocol/capability negotiation.
6. Reconcile the current synchronous presentation-facing conversion engine with the future generated native bridge without stale-result races or silent mid-session fallback.
7. Package/load the Rust native library on Android/iOS/Windows/Linux/macOS where Rust authority is claimed.
8. Execute Rust-vs-Dart parity through the generated binding boundary.
9. Add rendered primary UI integration tests and native E2E journeys.
10. Perform real screen-reader, keyboard/focus, large-text, contrast, reduced-motion, and touch-target review.
11. Record performance/search/batch/native profiling baselines where release decisions need them.
12. Produce final icons/splash/screenshots/demo media from verified builds.
13. Validate Android production signing and Apple signing/provisioning/notarization without committing credentials.
14. Complete clean-clone and downloaded-artifact release-candidate verification.
15. Complete the final release checklist.
16. Only then create and verify the exact `v2.0.12` tag.

## Exact next continuation priority

1. Inspect live `main` for the six generated platform directories and any new GitHub Actions evidence first.
2. If platform projects remain absent, execute the materialization workflow from an Actions-capable context or run the bootstrap scripts with Flutter installed; commit all six generated targets together and regenerate the platform inventory.
3. Fix every actual cross-platform build failure surfaced by execution.
4. Integrate a reviewed Rust↔Flutter binding generator around `BridgeService::info()`, `convert()`, and `batch_convert()`.
5. Implement one-time startup engine selection that fails closed on bridge incompatibility and never silently changes engines midway through a calculation/session.
6. Execute generated-boundary parity including malformed metadata, exact 256-target behavior, rounding ties, affine temperature conversions, and safe failures.
7. Add representative large-text widget coverage and continue native accessibility review once platform builds are executable.
8. Continue native E2E/performance/release-candidate evidence.

## Commits created in this accessibility continuation

- `21a73ad4` — `app: centralize reduced-motion policy`
- `d965d501` — `app: respect reduced motion for about navigation`
- `77be7951` — `app: harden converter accessibility semantics`
- `411f6828` — `test: add accessibility and reduced-motion smoke coverage`
- `a41d3e72` — `docs: inventory accessibility smoke coverage`
- `5384eab0` — `docs: record automated accessibility safeguards`
- `390bccb4` — `docs: advance accessibility hardening roadmap`
- `0812395c` — `docs: record accessibility hardening`
- `3087fe93` — `docs: align testing strategy with accessibility and platform builds`

This handoff update follows those commits.

## Previous bridge-hardening continuation

The immediately preceding continuation ended with:

- `96f52f10` — `docs: record bridge hardening continuation`

and contains the protocol/capability/batch-bound bridge hardening summarized above.

## Commit identity note

Requested identity remains:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

The live branch metadata for the inspected commits shows that identity.

## Handoff rules

For future continuation work:

1. inspect live `main` before trusting this file;
2. prefer compiler/test/workflow evidence over source/workflow definitions;
3. keep all six platform targets synchronized;
4. never accept a partially committed platform-project set;
5. regenerate `docs/platform-file-inventory.md` whenever generated platform files change;
6. preserve bridge protocol/capability/batch-limit parity across Rust, Flutter bridge, deterministic fallback, fixtures, and docs;
7. never silently switch calculation engines after startup selection;
8. preserve reduced-motion behavior for new modal/custom transitions;
9. do not treat automated accessibility tests as a manual accessibility audit;
10. keep production signing credentials out of source control;
11. update this file after meaningful work;
12. do not tag or call `v2.0.12` release-verified while evidence blockers remain open.
