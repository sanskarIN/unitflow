#!/usr/bin/env python3
"""Validate source-level accessibility safeguards that must not silently regress."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from typing import NamedTuple

ROOT = Path(__file__).resolve().parents[1]
APP_LIB = ROOT / "apps" / "unitflow_app" / "lib"
APP_THEME = APP_LIB / "app" / "theme" / "app_theme.dart"
APP_SHELL = APP_LIB / "app" / "app_shell.dart"
CONVERTER_SCREEN = (
    APP_LIB / "features" / "converter" / "presentation" / "converter_screen.dart"
)
BATCH_SCREEN = APP_LIB / "features" / "converter" / "presentation" / "batch_screen.dart"
ONBOARDING_SCREEN = (
    APP_LIB / "features" / "onboarding" / "presentation" / "onboarding_screen.dart"
)
ACCESSIBILITY_TEST = ROOT / "apps" / "unitflow_app" / "test" / "accessibility_smoke_test.dart"
NAVIGATION_TEST = ROOT / "apps" / "unitflow_app" / "test" / "navigation_smoke_test.dart"
VERIFY_BASH = ROOT / "scripts" / "verify.sh"
VERIFY_POWERSHELL = ROOT / "scripts" / "verify.ps1"
CI_WORKFLOW = ROOT / ".github" / "workflows" / "ci.yml"
RELEASE_WORKFLOW = ROOT / ".github" / "workflows" / "release.yml"
MATERIALIZE_WORKFLOW = ROOT / ".github" / "workflows" / "materialize-platforms.yml"
HYGIENE_VALIDATOR = ROOT / "scripts" / "check_repository_hygiene.py"
VALIDATOR_TOKEN = "scripts/check_accessibility_contract.py"


class ModalCall(NamedTuple):
    path: str
    kind: str
    header: str


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def modal_calls() -> list[ModalCall]:
    calls: list[ModalCall] = []
    if not APP_LIB.is_dir():
        return calls

    call_pattern = re.compile(
        r"\b(showDialog(?:<[^>]+>)?|showModalBottomSheet(?:<[^>]+>)?)\s*\("
    )
    for path in sorted(APP_LIB.rglob("*.dart")):
        source = text(path)
        for match in call_pattern.finditer(source):
            # Motion policy arguments are deliberately required before `builder:` so
            # this check remains simple, deterministic, and independent of a Dart parser.
            segment = source[match.start() : match.start() + 1600]
            header = segment.split("builder:", 1)[0]
            calls.append(
                ModalCall(
                    path=path.relative_to(ROOT).as_posix(),
                    kind="dialog" if match.group(1).startswith("showDialog") else "bottomSheet",
                    header=header,
                )
            )
    return calls


def validate() -> list[str]:
    errors: list[str] = []
    required_files = (
        APP_THEME,
        APP_SHELL,
        CONVERTER_SCREEN,
        BATCH_SCREEN,
        ONBOARDING_SCREEN,
        ACCESSIBILITY_TEST,
        NAVIGATION_TEST,
        VERIFY_BASH,
        VERIFY_POWERSHELL,
        CI_WORKFLOW,
        RELEASE_WORKFLOW,
        MATERIALIZE_WORKFLOW,
        HYGIENE_VALIDATOR,
    )
    for path in required_files:
        if not path.is_file():
            errors.append(f"missing accessibility contract file: {path.relative_to(ROOT)}")

    if errors:
        return errors

    theme = text(APP_THEME)
    if "abstract final class AppMotion" not in theme:
        errors.append("AppMotion accessibility policy is missing from app_theme.dart")
    if "MediaQuery.disableAnimationsOf(context)" not in theme:
        errors.append("AppMotion does not consult MediaQuery.disableAnimationsOf(context)")
    if "AnimationStyle.noAnimation" not in theme:
        errors.append("AppMotion does not expose a no-animation modal policy")

    for call in modal_calls():
        expected = (
            "animationStyle: AppMotion.modalSurfaceStyle(context)"
            if call.kind == "dialog"
            else "sheetAnimationStyle: AppMotion.modalSurfaceStyle(context)"
        )
        if expected not in call.header:
            errors.append(
                f"{call.path} contains a {call.kind} that does not apply the shared reduced-motion policy"
            )

    shell = text(APP_SHELL)
    if "MediaQuery.disableAnimationsOf(context)" not in shell:
        errors.append("AppShell custom navigation does not check the reduced-motion preference")
    if "AppMotion.routeDuration" not in shell:
        errors.append("AppShell custom navigation does not use the shared route-duration policy")
    for modifier in ("control", "meta"):
        for key in ("digit1", "digit2", "digit3", "digit4", "comma"):
            token = f"SingleActivator(LogicalKeyboardKey.{key}, {modifier}: true)"
            if token not in shell:
                errors.append(
                    f"AppShell is missing the {modifier} keyboard navigation binding for {key}"
                )

    converter = text(CONVERTER_SCREEN)
    if "liveRegion: true" in converter:
        errors.append("converter result must not become a keystroke-driven live region")
    if converter.count("toggled: isPinned") < 2:
        errors.append("converter pin controls do not both expose semantic toggled state")
    if "Semantics(\n    container: true,\n    label: label," not in converter:
        errors.append("converter labeled dropdowns do not expose explicit semantic context")
    if "class _BatchResultListItem" not in converter:
        errors.append("converter batch modal is missing its adaptive result-row boundary")
    if "MediaQuery.textScalerOf(context).scale(16) >= 24" not in converter:
        errors.append("converter batch modal does not adapt its result rows for large text")

    batch = text(BATCH_SCREEN)
    if "class _BatchField<T>" not in batch:
        errors.append("batch field accessibility boundary is missing")
    if "Semantics(\n    container: true,\n    label: label," not in batch:
        errors.append("batch labeled dropdowns do not expose explicit semantic context")
    if "value: value == null ? null : labelFor(value as T)," not in batch:
        errors.append("batch labeled dropdowns do not expose their selected semantic value")

    onboarding = text(ONBOARDING_SCREEN)
    for token, message in (
        (
            "MediaQuery.disableAnimationsOf(context)",
            "onboarding does not check the reduced-motion preference",
        ),
        (
            "_pageController.jumpToPage(_page + 1)",
            "onboarding does not provide a non-animated page transition",
        ),
        (
            "duration: AppMotion.routeDuration(",
            "onboarding page indicators do not use the shared reduced-motion duration policy",
        ),
    ):
        if token not in onboarding:
            errors.append(message)

    test_source = text(ACCESSIBILITY_TEST)
    for token in (
        "disableAnimations: true",
        "hasToggledState: true",
        "isToggled: false",
        "isToggled: true",
        "widget.properties.value == 'Length'",
        "textScaleFactorTestValue = 2.0",
        "ConverterScreen(controller: converterController)",
        "BatchScreen(controller: converterController)",
        "converter batch modal survives compact 200% text",
        "OnboardingScreen(appController: controller)",
        "const AboutScreen()",
    ):
        if token not in test_source:
            errors.append(f"accessibility smoke coverage is missing expected assertion token: {token}")

    navigation_test = text(NAVIGATION_TEST)
    for token in (
        "desktop control shortcuts switch primary destinations",
        "macOS command shortcuts switch primary destinations",
        "LogicalKeyboardKey.controlLeft",
        "LogicalKeyboardKey.metaLeft",
        "LogicalKeyboardKey.comma",
    ):
        if token not in navigation_test:
            errors.append(f"navigation shortcut coverage is missing expected token: {token}")

    for path in (VERIFY_BASH, VERIFY_POWERSHELL, CI_WORKFLOW, RELEASE_WORKFLOW, MATERIALIZE_WORKFLOW):
        if VALIDATOR_TOKEN not in text(path):
            errors.append(
                f"accessibility validator is not wired into {path.relative_to(ROOT).as_posix()}"
            )

    if VALIDATOR_TOKEN not in text(HYGIENE_VALIDATOR):
        errors.append("repository hygiene does not require the accessibility validator")

    return errors


def main() -> int:
    errors = validate()
    if errors:
        print("Accessibility source-contract validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    calls = modal_calls()
    dialogs = sum(call.kind == "dialog" for call in calls)
    sheets = sum(call.kind == "bottomSheet" for call in calls)
    print(
        "Accessibility source-contract validation passed: "
        f"dialogs={dialogs}, modal_bottom_sheets={sheets}, reduced_motion=enforced."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
