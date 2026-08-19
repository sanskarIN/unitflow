#!/usr/bin/env python3
"""Validate UnitFlow release, Flutter bundle, and bridge version consistency."""

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
FLUTTER_VERSION_RE = re.compile(r"^(\d+)\.(\d+)\.(\d+)\+(\d+)$")
CODEGEN_PIN_RE = re.compile(r"flutter_rust_bridge_codegen\s+--version\s+([^\s`]+)")


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


def release_core_version(release_version: str) -> str:
    return release_version.split("-", 1)[0].split("+", 1)[0]


def flutter_build_name(pubspec_version: str) -> str:
    match = FLUTTER_VERSION_RE.fullmatch(pubspec_version)
    if match is None:
        raise ValueError(
            "Flutter version must use an Apple-compatible numeric build name and build number, "
            "for example 0.1.0+1"
        )
    return ".".join(match.groups()[:3])


def check_codegen_pins(expected: str) -> list[str]:
    failures: list[str] = []
    for path in PINNED_FILES:
        if not path.exists():
            failures.append(f"missing pinned-version file: {path.relative_to(ROOT)}")
            continue
        text = path.read_text(encoding="utf-8")
        for actual in CODEGEN_PIN_RE.findall(text):
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
        flutter_name = flutter_build_name(flutter_version)
    except (OSError, UnicodeDecodeError, tomllib.TOMLDecodeError, ValueError) as error:
        print(f"Version consistency check failed to parse configuration: {error}", file=sys.stderr)
        return 2

    workspace_core = release_core_version(workspace_version)
    if flutter_name != workspace_core:
        failures.append(
            f"Flutter build name {flutter_name} does not match release core version {workspace_core} "
            f"from Rust workspace version {workspace_version}"
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
        f"release {workspace_version}, Flutter {flutter_version}, flutter_rust_bridge {workspace_frb}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
