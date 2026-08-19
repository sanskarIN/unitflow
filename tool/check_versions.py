#!/usr/bin/env python3
"""Validate UnitFlow release and Flutter Rust Bridge version consistency."""

from __future__ import annotations

import re
import sys
import tomllib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CARGO_TOML = ROOT / "Cargo.toml"
PUBSPEC = ROOT / "apps/unitflow_app/pubspec.yaml"
PINNED_FILES = (
    ROOT / ".github/workflows/ci.yml",
    ROOT / ".github/workflows/format-audit.yml",
    ROOT / ".github/workflows/release.yml",
    ROOT / "docs/bridge.md",
    ROOT / "docs/testing.md",
    ROOT / "docs/verification.md",
    ROOT / "tool/generate_bridge.sh",
    ROOT / "tool/integrate_native_bridge.sh",
    ROOT / "tool/verify_release_candidate.sh",
)

PUBSPEC_VERSION_RE = re.compile(r"(?m)^version:\s*([^\s#]+)\s*$")
PUBSPEC_FRB_RE = re.compile(r"(?m)^\s{2}flutter_rust_bridge:\s*([^\s#]+)\s*$")
CODEGEN_PIN_RE = re.compile(r"flutter_rust_bridge_codegen\s+--version\s+([^\s`]+)")
DOCUMENTED_PIN_RE = re.compile(r"flutter_rust_bridge_codegen\s+--version\s+([^\s`]+)")


def load_workspace_versions() -> tuple[str, str]:
    with CARGO_TOML.open("rb") as handle:
        cargo = tomllib.load(handle)
    package = cargo.get("workspace", {}).get("package", {})
    dependencies = cargo.get("workspace", {}).get("dependencies", {})
    version = package.get("version")
    frb = dependencies.get("flutter_rust_bridge")
    if not isinstance(version, str) or not isinstance(frb, str):
        raise ValueError("Cargo.toml must define workspace package and FRB versions")
    return version, frb


def load_pubspec_versions() -> tuple[str, str]:
    text = PUBSPEC.read_text(encoding="utf-8")
    version_match = PUBSPEC_VERSION_RE.search(text)
    frb_match = PUBSPEC_FRB_RE.search(text)
    if version_match is None or frb_match is None:
        raise ValueError("pubspec.yaml must define application and FRB versions")
    return version_match.group(1), frb_match.group(1)


def flutter_semver(pubspec_version: str) -> str:
    return pubspec_version.split("+", 1)[0]


def check_codegen_pins(expected: str) -> list[str]:
    failures: list[str] = []
    for path in PINNED_FILES:
        if not path.exists():
            failures.append(f"missing pinned-version file: {path.relative_to(ROOT)}")
            continue
        text = path.read_text(encoding="utf-8")
        matches = CODEGEN_PIN_RE.findall(text)
        if not matches:
            # Documentation may mention the generator version without a literal install command.
            matches = DOCUMENTED_PIN_RE.findall(text)
        for actual in matches:
            if actual != expected:
                failures.append(
                    f"{path.relative_to(ROOT)} pins flutter_rust_bridge_codegen {actual}; expected {expected}"
                )
    return failures


def main() -> int:
    failures: list[str] = []
    try:
        workspace_version, workspace_frb = load_workspace_versions()
        flutter_version, flutter_frb = load_pubspec_versions()
    except (OSError, UnicodeDecodeError, tomllib.TOMLDecodeError, ValueError) as error:
        print(f"Version consistency check failed to parse configuration: {error}", file=sys.stderr)
        return 2

    if flutter_semver(flutter_version) != workspace_version:
        failures.append(
            "Flutter application version "
            f"{flutter_semver(flutter_version)} does not match Rust workspace version {workspace_version}"
        )
    if flutter_frb != workspace_frb:
        failures.append(
            f"Flutter FRB dependency {flutter_frb} does not match Rust workspace FRB dependency {workspace_frb}"
        )
    failures.extend(check_codegen_pins(workspace_frb))

    if failures:
        print("Version consistency failures:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print(
        "Version consistency passed: "
        f"UnitFlow {workspace_version}, flutter_rust_bridge {workspace_frb}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
