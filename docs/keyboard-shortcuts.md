# Keyboard shortcuts

UnitFlow provides application-level navigation shortcuts on desktop and web while preserving normal text-field editing behavior.

| Action | Windows/Linux | macOS |
| --- | --- | --- |
| Convert | `Ctrl+1` | `Cmd+1` |
| Batch | `Ctrl+2` | `Cmd+2` |
| Library | `Ctrl+3` | `Cmd+3` |
| History | `Ctrl+4` | `Cmd+4` |
| Settings | `Ctrl+,` | `Cmd+,` |

## Accessibility expectations

Shortcuts are conveniences, not the only way to reach a feature. Every destination remains available through `NavigationBar` on compact layouts and `NavigationRail` on wider layouts.

Interactive controls should have visible labels or tooltips, participate in focus traversal, and expose understandable semantics. Text entry must continue to support platform-standard selection, copy, paste, undo, and editing shortcuts.

## Adding shortcuts

When adding a shortcut:

1. keep it consistent with common platform expectations;
2. do not shadow essential browser or assistive-technology shortcuts without a compelling reason;
3. retain a visible navigation/control alternative;
4. update the Settings accessibility section and this file;
5. add a widget test where the action has meaningful state or navigation behavior.
