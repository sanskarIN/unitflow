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

## Responsive review widths

Manually review representative compact, medium, and expanded widths rather than designing to one phone size.

## Text and locale

Do not hard-code layouts that assume short English labels. UI strings must be localization-ready and allow larger text. Symbols should not be the only accessible name for a unit.

## Automated tests

Widget tests should validate critical semantics and absence of obvious layout exceptions at representative dimensions. Automated checks complement rather than replace manual screen-reader/keyboard review.

## Release evidence

Record accessibility review notes in `what_changed.md` before stable releases, including platforms actually reviewed and any known limitations.
