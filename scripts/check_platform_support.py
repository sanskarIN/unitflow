#!/usr/bin/env python3
"""Validate UnitFlow's six-platform Flutter support contract."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
APP = ROOT / "apps" / "unitflow_app"
PLATFORMS = ("android", "ios", "web", "windows", "linux", "macos")
BUILD_WORKFLOW = ROOT / ".github" / "workflows" / "platform-smoke.yml"
MATERIALIZE_WORKFLOW = ROOT / ".github" / "workflows" / "materialize-platforms.yml"
BOOTSTRAP_BASH = ROOT / "scripts" / "bootstrap_platforms.sh"
BOOTSTRAP_POWERSHELL = ROOT / "scripts" / "bootstrap_platforms.ps1"
PLATFORM_INVENTORY = ROOT / "docs" / "platform-file-inventory.md"

BUILD_COMMANDS = {
    "android": "flutter build appbundle --release",
    "ios": "flutter build ios --release --no-codesign",
    "web": "flutter build web --release",
    "windows": "flutter build windows --release",
    "linux": "flutter build linux --release",
    "macos": "flutter build macos --release",
}


def text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _platform_directories_present() -> set[str]:
    return {platform for platform in PLATFORMS if (APP / platform).is_dir()}


def _unconditional_dart_io_imports() -> list[str]:
    offenders: list[str] = []
    lib_dir = APP / "lib"
    if not lib_dir.is_dir():
        return offenders

    for path in sorted(lib_dir.rglob("*.dart")):
        source = path.read_text(encoding="utf-8")
        # A plain dart:io import makes the containing library unavailable on Web.
        # Conditional imports are intentionally not matched by this exact pattern.
        if re.search(r"^import\s+['\"]dart:io['\"]\s*;", source, re.MULTILINE):
            offenders.append(path.relative_to(ROOT).as_posix())
    return offenders


def validate() -> list[str]:
    errors: list[str] = []

    required_files = (
        BUILD_WORKFLOW,
        MATERIALIZE_WORKFLOW,
        BOOTSTRAP_BASH,
        BOOTSTRAP_POWERSHELL,
        PLATFORM_INVENTORY,
    )
    for path in required_files:
        if not path.is_file():
            errors.append(f"missing cross-platform support file: {path.relative_to(ROOT)}")

    if errors:
        return errors

    build_workflow = text(BUILD_WORKFLOW)
    materialize_workflow = text(MATERIALIZE_WORKFLOW)
    bootstrap_bash = text(BOOTSTRAP_BASH)
    bootstrap_powershell = text(BOOTSTRAP_POWERSHELL)

    for platform in PLATFORMS:
        if not re.search(rf"^  {re.escape(platform)}:\s*$", build_workflow, re.MULTILINE):
            errors.append(f"cross-platform workflow has no {platform} job")

        build_command = BUILD_COMMANDS[platform]
        if build_command not in build_workflow:
            errors.append(
                f"cross-platform workflow does not run expected {platform} release build: {build_command}"
            )

        if platform not in materialize_workflow:
            errors.append(f"materialization workflow does not reference {platform}")
        if platform not in bootstrap_bash:
            errors.append(f"Bash platform bootstrap does not reference {platform}")
        if platform not in bootstrap_powershell:
            errors.append(f"PowerShell platform bootstrap does not reference {platform}")

    present = _platform_directories_present()
    if present and present != set(PLATFORMS):
        missing = sorted(set(PLATFORMS) - present)
        errors.append(
            "platform projects are only partially committed; missing: " + ", ".join(missing)
        )

    io_offenders = _unconditional_dart_io_imports()
    if io_offenders:
        errors.append(
            "shared Flutter libraries contain unconditional dart:io imports that break Web: "
            + ", ".join(io_offenders)
        )

    return errors


def main() -> int:
    errors = validate()
    if errors:
        print("Cross-platform support validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    present = _platform_directories_present()
    state = "materialized" if present == set(PLATFORMS) else "generation-ready"
    print(
        "Cross-platform support validation passed: "
        f"targets={','.join(PLATFORMS)}, platform_state={state}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
