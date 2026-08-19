# Accessibility

UnitFlow should remain usable with touch, keyboard, screen readers, zoom, and high-contrast system settings.

## Current practices

- Material controls with visible labels rather than icon-only meaning where practical.
- `Semantics` labels on swap and unit-selection actions.
- Responsive layouts that move from horizontal to vertical controls on narrow screens.
- Selectable conversion output.
- System light/dark theme support.
- Error text attached to the numeric input field.
- Touch targets provided by standard Material components.

## Review checklist

For user-facing changes verify:

- meaningful focus order
- controls usable without a pointer
- screen-reader labels describe purpose, not appearance
- text remains readable at increased text scale
- no information conveyed by color alone
- error states are textual and discoverable
- dialogs have clear titles and close/cancel actions
- result updates remain understandable without animation

## Target

Before 1.0, perform a dedicated audit against current WCAG guidance and Flutter accessibility recommendations, then track any deviations as issues with reproducible steps.
