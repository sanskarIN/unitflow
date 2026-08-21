# UnitFlow — Development Handoff

This file is the primary continuation checkpoint for future UnitFlow development sessions so chat responses can stay short while repository work remains fully traceable.

Last updated: **2026-08-21**

Repository: `https://github.com/sanskarIN/unitflow`

Branch: **`main`**

Current source version: **`2.0.12`**

Flutter build number: **`12`**

Latest inspected pre-handoff commit: **`1494ec56d614dc9a0649272b658f004e9c8f46c0`** (`docs: record navigation state synchronization fix`)

## Current release state

UnitFlow remains an enforced six-target Flutter project for:

- Android;
- iOS;
- Web;
- Windows;
- Linux;
- macOS.

The repository retains deterministic six-platform generation, all-or-nothing platform materialization automation, release-mode build jobs for all six targets, build artifact upload definitions, generated-platform inventory support, and repository validators that prevent target drift or partial committed platform sets.

The Rust↔Flutter source bridge contract remains hardened with protocol/capability negotiation, fail-closed compatibility, real single/batch source APIs, stable unit-ID validation, a shared 256-target batch ceiling, fallback/native behavior parity, and cross-language release-consistency checks.

The accessibility source contract is now materially stronger than the previous handoff: reduced motion, converter and batch selector semantics, adaptive compact/large-text behavior, representative 200% widget coverage, and both Ctrl/Cmd primary-navigation shortcut families are guarded by tests and source validation.

This continuation also fixed a functional shared-state UI defect: Converter and Batch previously owned independent `TextEditingController` values that could visibly diverge from the shared `ConverterController`. Both screens now synchronize externally changed input, and widget coverage locks Converter↔Batch synchronization plus History-to-Converter restoration.

**Do not call `v2.0.12` a fully verified native/store release yet.** The latest inspected live `main` tree still does not contain the generated Android/iOS/Web/Windows/Linux/macOS project directories. Generated Rust↔Flutter bindings, runtime native-engine selection, native library packaging/loading, generated-boundary parity execution, native E2E evidence, full real-platform accessibility/performance review, signing/notarization, and final release-candidate verification remain open.

No `v2.0.12` tag was created in this continuation.

## Work completed in this continuation

### 1. Batch selectors now expose semantic label and selected value

`apps/unitflow_app/lib/features/converter/presentation/batch_screen.dart` now gives its reusable category/source dropdown wrapper the same semantic context already used by the main converter:

- field label;
- selected display value;
- interactive dropdown subtree.

This closes a screen-reader context mismatch between Converter and Batch.

### 2. Compact 200% text coverage expanded across remaining primary surfaces

`apps/unitflow_app/test/accessibility_smoke_test.dart` now includes representative compact `390×844` rendering with a `2.0` text scale for:

- Converter;
- Batch;
- Library;
- History;
- Settings;
- Onboarding;
- About;
- the custom-unit dialog;
- the converter batch-results modal.

The tests assert that no surfaced layout exception is produced in those deterministic widget configurations. They remain source/widget evidence and do not replace real-device review.

### 3. Converter modal batch rows are large-text resilient

The converter's modal batch-results sheet no longer relies on a `ListTile.trailing` value column.

A dedicated adaptive `_BatchResultListItem` now:

- uses a normal unit/value row when space and text scale permit;
- stacks unit metadata above the result when width is below `420` or enlarged text reaches the configured threshold;
- keeps result text selectable;
- uses directional end alignment for the stacked result value.

The converter education-row heading was also given flexible width so the icon/title row is less fragile under enlargement.

### 4. The accessibility repository gate now protects the new behavior

`scripts/check_accessibility_contract.py` now additionally requires:

- the Batch screen accessibility boundary;
- semantic label/selected-value context for Batch dropdowns;
- the converter adaptive batch-result row boundary;
- a large-text adaptation check in that boundary;
- the compact 200% batch-modal regression test;
- every Ctrl+1/2/3/4/comma AppShell binding;
- every Cmd+1/2/3/4/comma AppShell binding;
- corresponding Ctrl and Command navigation smoke coverage.

The validator remains wired into the existing Bash/PowerShell verification, CI, release, materialization, and repository-hygiene paths.

### 5. Ctrl and Command navigation shortcuts now have widget regressions

`apps/unitflow_app/test/navigation_smoke_test.dart` now exercises both modifier families implemented by `AppShell`:

- Ctrl+1 → Convert;
- Ctrl+2 → Batch;
- Ctrl+3 → Library;
- Ctrl+4 → History;
- Ctrl+, → Settings;
- Cmd+1 → Convert;
- Cmd+2 → Batch;
- Cmd+3 → Library;
- Cmd+4 → History;
- Cmd+, → Settings.

The existing navigation-test controllers are also disposed through test teardown so the smoke tests do not leave controller lifecycle noise behind.

### 6. Fixed stale visible input across Converter and Batch

The main Converter and Batch widgets share one `ConverterController`, but each previously initialized its own `TextEditingController` once and never synchronized that field again.

This meant the underlying conversion state could be correct while the visible text field showed an older value after editing the other workspace or restoring History.

Both `ConverterScreen` and `BatchScreen` now:

- initialize their text controller in `initState`;
- listen to the shared `ConverterController`;
- update the visible field only when its text differs from shared input;
- collapse selection to the end after an external update;
- detach/re-attach correctly if the supplied controller instance changes;
- remove the listener during `dispose`.

Programmatic synchronization does not call the field's `onChanged`, so it does not feed the value back recursively through the shared controller.

### 7. Rendered cross-workspace and History restoration tests added

`navigation_smoke_test.dart` now verifies two important UI-state journeys:

1. enter a value in Converter → navigate to Batch → Batch displays the same value → edit it in Batch → navigate back → Converter displays the new value;
2. pre-record a valid recent conversion → navigate to History → open that recent entry → Converter becomes active and visibly displays the saved original input.

These tests protect the actual rendered text-controller synchronization path rather than only checking domain/controller state.

### 8. Accessibility/testing/release documentation synchronized

Updated documentation now reflects the implemented source and widget evidence:

- `docs/accessibility.md` documents batch selector semantics, adaptive batch-modal rows, compact 200% coverage, and Ctrl/Cmd shortcut regression coverage;
- `docs/testing.md` documents navigation shortcut tests, Converter↔Batch input synchronization, History restoration, and the stronger accessibility source gate;
- `ROADMAP.md` records automated reduced-motion, semantic, and large-text hardening while keeping real-platform accessibility review open;
- `CHANGELOG.md` records the expanded accessibility coverage, keyboard navigation tests, adaptive modal behavior, and stale-input synchronization fix.

## Important accessibility work already present before this continuation

The live branch entered this continuation with additional accessibility hardening beyond the older handoff, including:

- onboarding reduced-motion page transitions and indicator duration handling;
- repository enforcement for onboarding reduced-motion behavior;
- large-text-resilient custom-unit form actions;
- compact-layout-resilient Library and History headers;
- text-scale-resilient Settings section headers;
- initial compact large-text widget smoke coverage.

Representative immediately preceding commits included:

- `bf2756f2` — `app: respect reduced motion during onboarding`
- `fb9772da` — `build: enforce onboarding reduced-motion contract`
- `ef7a15ba` — `app: make custom unit form large-text resilient`
- `50e11b6f` — `app: make library header compact-layout resilient`
- `8c2afc1f` — `app: make history header compact-layout resilient`
- `c8eb2880` — `app: make settings section headers text-scale resilient`
- `948a3fc5` — `test: add compact large-text layout coverage`

Future continuations must inspect live `main` first because this handoff can become stale as soon as another session commits.

## Bridge hardening retained

The current tree still includes the source-level bridge hardening completed in earlier continuations:

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
- Rust/Flutter source regression coverage;
- repository release-consistency checks that lock protocol/capabilities/batch ceiling across code/docs/fixture/fallback.

Generated bindings and production runtime native-engine selection still do not exist and must not be implied from these source contracts.

## Live platform-tree inspection

The live `apps/unitflow_app` directory was re-inspected on **2026-08-21** after the source changes above.

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

All commits listed in this continuation were written directly to live `main` through the connected GitHub integration and then re-read through the same integration.

Immediately before this handoff-file update, the latest inspected commit was:

```text
1494ec56d614dc9a0649272b658f004e9c8f46c0
```

The GitHub connector's recent-commit result does not expose author-email metadata for these commits, so this checkpoint does not claim that the requested commit email was independently re-verified from commit metadata. The requested identity remains documented below for environments that expose `git config`/author controls.

### Local execution limitation

This continuation does not claim successful local output for:

- `python3 scripts/check_accessibility_contract.py` against a local clone;
- repository validator unit tests against a local clone;
- `dart format`;
- `flutter analyze`;
- `flutter test`;
- `cargo fmt`;
- `cargo clippy`;
- `cargo test`;
- Android/iOS/Web/Windows/Linux/macOS release builds.

A direct clone attempt from the available execution container could not resolve `github.com`, and the connected GitHub integration is a repository API rather than a full local Flutter/Rust/native build environment. Therefore source changes, committed tests, validator definitions, and documentation are implementation evidence, not proof that those commands passed.

### GitHub Actions evidence boundary

A successful final-candidate full CI/release-build matrix was not established in this continuation. Do not infer green GitHub Actions merely because workflow definitions and source validators are present.

### Accessibility evidence boundary

The source contracts and widget tests do **not** prove:

- TalkBack behavior on Android;
- VoiceOver behavior on iOS/macOS;
- Windows Narrator behavior;
- Linux screen-reader behavior;
- browser assistive-technology behavior;
- complete keyboard focus traversal and visible-focus quality on every desktop target;
- contrast compliance under every rendered theme state;
- large-text behavior on real devices and every locale;
- touch-target behavior on native builds;
- modal focus trapping/restoration on real assistive-technology stacks.

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
9. Add native end-to-end primary journeys after reviewed platform projects/bindings exist.
10. Perform real screen-reader, full keyboard/focus, large-text, contrast, reduced-motion, modal-focus, and touch-target review.
11. Record performance/search/batch/native profiling baselines where release decisions need them.
12. Produce final icons/splash/screenshots/demo media from verified builds.
13. Validate Android production signing and Apple signing/provisioning/notarization without committing credentials.
14. Complete clean-clone and downloaded-artifact release-candidate verification.
15. Complete the final release checklist.
16. Only then create and verify the exact `v2.0.12` tag.

## Exact next continuation priority

1. Inspect live `main` for new commits, all six generated platform directories, and any final-candidate GitHub Actions evidence before trusting this checkpoint.
2. If platform projects remain absent, execute `.github/workflows/materialize-platforms.yml` from an Actions-capable context or run the repository bootstrap scripts with Flutter installed; commit all six generated targets plus `.metadata` together and regenerate `docs/platform-file-inventory.md`.
3. Run the repository validators, Flutter quality gates, Rust quality gates, and six-platform release builds against that committed tree; fix every real failure surfaced by execution.
4. Integrate a reviewed Rust↔Flutter binding generator around `BridgeService::info()`, `convert()`, and `batch_convert()`.
5. Implement one-time startup engine selection that fails closed on bridge incompatibility and never silently changes engines midway through a calculation/session.
6. Execute generated-boundary parity including malformed metadata, exact 256-target behavior, rounding ties, affine temperature conversions, and safe failures.
7. Continue rendered UI integration coverage around persistence/import/custom-unit journeys once the native execution environment is available.
8. Perform native accessibility/performance/release-candidate evidence and only then prepare the exact release tag.

## Commits created in this continuation

- `46e1676b` — `app: expose batch selector semantics`
- `c3b39e6d` — `test: cover batch semantics and remaining large-text screens`
- `9f40db61` — `test: target localized converter heading`
- `5a2534b1` — `docs: record expanded accessibility regression coverage`
- `7b3ec99c` — `build: enforce batch accessibility and large-text coverage`
- `5162a045` — `docs: advance automated accessibility hardening roadmap`
- `ed1142b0` — `app: harden converter batch results for large text`
- `c5fc84cb` — `test: cover large-text converter batch modal`
- `6c83cc6e` — `build: require batch-modal large-text regression`
- `38182124` — `docs: document large-text batch modal behavior`
- `dcab78cb` — `docs: align testing strategy with large-text coverage`
- `3ae53ed6` — `docs: record expanded accessibility hardening`
- `ee2ff235` — `test: dispose navigation smoke controllers`
- `69d73127` — `test: cover desktop navigation shortcuts`
- `db891e96` — `test: cover macOS navigation shortcuts`
- `59451d29` — `build: enforce keyboard navigation coverage`
- `84d6b00a` — `docs: record keyboard shortcut regression coverage`
- `ef70c575` — `fix: synchronize converter input from shared state`
- `9c987a1c` — `fix: synchronize batch input from shared state`
- `466f05d1` — `test: cover converter batch input synchronization`
- `5915ffc6` — `test: cover history input restoration`
- `95a7e513` — `docs: record navigation and input-sync regressions`
- `1494ec56` — `docs: record navigation state synchronization fix`

This handoff update follows those commits.

## Requested commit identity

For environments that expose local Git author configuration, the requested identity remains:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

Do not claim this was reconfigured through the GitHub connector unless the connector exposes author controls or commit metadata that proves it.

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
9. preserve semantic label/value context for new selector abstractions;
10. preserve visible text-field synchronization whenever shared controller state can be changed externally;
11. keep Ctrl and Cmd primary-navigation behavior synchronized when destinations change;
12. do not treat automated accessibility tests as a manual accessibility audit;
13. keep production signing credentials out of source control;
14. update this file after meaningful work;
15. do not tag or call `v2.0.12` release-verified while evidence blockers remain open.
