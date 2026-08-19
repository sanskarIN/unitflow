#!/usr/bin/env python3
"""Validate UnitFlow release, Flutter bundle, UI, and bridge version consistency."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CARGO_TOML = ROOT / "Cargo.toml"
PUBSPEC = ROOT / "apps/unitflow_app/pubspec.yaml"
ABOUT_SCREEN = (
    ROOT
    / "apps/unitflow_app/lib/features/settings/presentation/about_screen.dart"
)
PINNED_FILES = (
    ROOT / ".github/workflows/ci.yml",
    ROOT / ".github/workflows/format-audit.yml",
    ROOT / ".github/workflows/release.yml",
    ROOT / "docs/bridge.md",
    ROOT / "docs/release.md",
    ROOT / "docs/testing.md",
    ROOT / "docs/verification.md",
    ROOT / "tool/generate_bridge.sh",
    ROOT / "tool/integrate_native_bridge.sh",
    ROOT / "tool/verify_release_candidate.sh",
)

PUBSPEC_VERSION_RE = re.compile(r"(?m)^version:\s*([^\s#]+)\s*$")
PUBSPEC_FRB_RE = re.compile(r"(?m)^\s{2}flutter_rust_bridge:\s*([^\s#]+)\s*$")
ABOUT_VERSION_RE = re.compile(r"static const appVersion\s*=\s*'([^']+)'\s*;")
FLUTTER_VERSION_RE = re.compile(r"^(\d+)\.(\d+)\.(\d+)\+(\d+)$")
CODEGEN_PIN_RE = re.compile(r"flutter_rust_bridge_codegen\s+--version\s+([^\s`]+)")


def _toml_section(text: str, name: str) -> str:
    pattern = re.compile(
        rf"(?ms)^\[{re.escape(name)}\]\s*(.*?)(?=^\[|\Z)",
    )
    match = pattern.search(text)
    if match is None:
        raise ValueError(f"Cargo.toml is missing [{name}]")
    return match.group(1)


def _toml_string(section: str, key: str) -> str:
    match = re.search(
        rf'(?m)^{re.escape(key)}\s*=\s*"([^"]+)"\s*$',
        section,
    )
    if match is None:
        raise ValueError(f"Cargo.toml is missing string value {key}")
    return match.group(1)


def load_workspace_versions() -> tuple[str, str]:
    text = CARGO_TOML.read_text(encoding="utf-8")
    package = _toml_section(text, "workspace.package")
    dependencies = _toml_section(text, "workspace.dependencies")
    return (
        _toml_string(package, "version"),
        _toml_string(dependencies, "flutter_rust_bridge"),
    )


def load_pubspec_versions() -> tuple[str, str]:
    text = PUBSPEC.read_text(encoding="utf-8")
    version_match = PUBSPEC_VERSION_RE.search(text)
    frb_match = PUBSPEC_FRB_RE.search(text)
    if version_match is None or frb_match is None:
        raise ValueError("pubspec.yaml must define application and FRB versions")
    return version_match.group(1), frb_match.group(1)


def load_about_version() -> str:
    text = ABOUT_SCREEN.read_text(encoding="utf-8")
    match = ABOUT_VERSION_RE.search(text)
    if match is None:
        raise ValueError("AboutScreen must define appVersion")
    return match.group(1)


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
        about_version = load_about_version()
        flutter_name = flutter_build_name(flutter_version)
    except (OSError, UnicodeDecodeError, ValueError) as error:
        print(f"Version consistency check failed to parse configuration: {error}", file=sys.stderr)
        return 2

    workspace_core = release_core_version(workspace_version)
    if flutter_name != workspace_core:
        failures.append(
            f"Flutter build name {flutter_name} does not match release core version {workspace_core} "
            f"from Rust workspace version {workspace_version}"
        )
    if about_version != workspace_version:
        failures.append(
            f"About version {about_version} does not match Rust workspace release {workspace_version}"
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
