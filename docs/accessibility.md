# Accessibility

UnitFlow targets WCAG-oriented accessible behavior across mobile, desktop, and web.

## Requirements

- Every interactive element has a meaningful accessible name.
- Controls remain usable with keyboard-only navigation on desktop/web.
- Focus indicators are clearly visible.
- Status is never communicated by color alone.
- Text scaling does not hide primary actions or conversion output.
- Touch targets are comfortably sized.
- Light/dark themes maintain usable contrast.
- Motion respects reduced-motion preferences where the framework/platform exposes them.
- Validation messages identify the field/problem and do not rely only on icons.
- Dynamic conversion output is announced conservatively; avoid excessive screen-reader chatter on every keystroke.

## Implemented safeguards

The current source includes several accessibility-oriented defaults that are covered by regression tests where practical:

- converter pin/unpin controls expose a semantic toggled state in addition to their visible icon/label;
- converter source, target, and category dropdowns expose explicit semantic labels and selected values;
- batch category and source-unit dropdowns expose the same semantic label/selected-value contract instead of relying only on visible field decoration;
- conversion output remains selectable and has a stable semantic description without being configured as a live region on every keystroke;
- icon-only controls such as swap, copy, search, and the converter pin action have tooltips/accessibility names;
- desktop navigation exposes both Ctrl-based and macOS Command-based shortcuts for Convert, Batch, Library, History, and Settings, with widget regression coverage for both modifier families;
- modal batch surfaces use `MediaQuery.disableAnimations` through the centralized `AppMotion` policy and disable sheet animation when the platform requests reduced motion;
- converter modal batch-result rows stack the unit metadata above the selectable result on compact widths or enlarged text instead of forcing the result into a narrow trailing column;
- About navigation removes transition duration when reduced motion is requested;
- adaptive list/rail navigation avoids requiring pointer-only interaction;
- representative compact-width widget tests run at 200% text scaling across Converter, Batch, Library, History, Settings, Onboarding, About, the custom-unit dialog, and the converter batch-results modal and fail on surfaced layout exceptions.

`apps/unitflow_app/test/accessibility_smoke_test.dart` currently locks the reduced-motion policy, converter pin semantic-state contract, batch selector semantic context, representative compact 200% text-layout coverage, and the converter batch-results modal at that same text scale. `navigation_smoke_test.dart` separately exercises pointer navigation plus Ctrl/Cmd primary-destination shortcuts.

## Converter screen review

Verify:

1. category selector has a label and selected state;
2. source and target unit controls have distinct semantic labels;
3. swap button describes its action;
4. numeric field exposes validation text;
5. output can be selected/copied without requiring pointer precision;
6. favorite/pin state is announced;
7. tab order follows visual/logical order;
8. keyboard submit/escape behavior is predictable.

## Batch screen review

Verify:

1. category and source-unit selectors announce both their field label and selected value;
2. the numeric input exposes validation errors;
3. copy CSV/TSV/JSON actions are named and remain reachable without pointer-only input;
4. wide result tables remain horizontally reachable rather than clipping content;
5. batch result values remain selectable;
6. compact and enlarged-text layouts do not hide the export controls or selected input state;
7. converter modal batch rows remain readable and selectable when their unit metadata and value stack under compact/enlarged-text conditions.

## Responsive review widths

Manually review representative compact, medium, and expanded widths rather than designing to one phone size.

Automated compact 200% widget coverage is a regression gate for obvious layout exceptions; it is not evidence that large-text rendering is correct on every real platform. Before release, review at least one compact phone layout and one desktop/Web layout with enlarged system text.

## Text and locale

Do not hard-code layouts that assume short English labels. UI strings must be localization-ready and allow larger text. Symbols should not be the only accessible name for a unit.

The current automated large-text checks use the English localization as a deterministic baseline. Future locale additions should add representative longest-label coverage rather than assuming English is the worst case.

## Motion

Reduced motion is a platform accessibility preference, not a cosmetic setting. Code that introduces a new modal surface or custom route transition should consult the shared `AppMotion` policy or otherwise honor `MediaQuery.disableAnimations`.

Do not introduce looping decorative animation, forced parallax, or essential information that is only visible through motion.

## Automated tests

Widget tests should validate critical semantics and absence of obvious layout exceptions at representative dimensions. Automated checks complement rather than replace manual screen-reader/keyboard review.

Current automated coverage includes:

- semantic on/off state for the converter pin action;
- semantic label and selected-value context for batch selectors;
- zero-duration route and modal-surface policy under reduced-motion media settings;
- compact 390×844 layout smoke coverage at 200% text scaling for Converter, Batch, Library, History, Settings, Onboarding, About, and the custom-unit dialog;
- opening and rendering the converter batch-results modal at the same compact 200% text configuration;
- Ctrl+1/2/3/4/comma and Cmd+1/2/3/4/comma navigation across the five primary destinations.

Future release-candidate coverage should add target-specific semantics checks, full keyboard focus traversal tests where stable in Flutter test infrastructure, and representative long-localization text runs as native projects become executable.

## Manual release checklist

Before a stable release, record evidence for the platforms actually reviewed:

- screen reader/TalkBack/VoiceOver or equivalent semantics pass;
- keyboard-only navigation and visible focus;
- large text/text scaling;
- contrast in light and dark themes;
- reduced motion;
- touch-target sizing;
- modal/dialog focus and dismissal behavior.

## Release evidence

Record accessibility review notes in `what_changed.md` before stable releases, including platforms actually reviewed and any known limitations. Source-level safeguards and widget tests must not be described as a completed manual accessibility audit.
