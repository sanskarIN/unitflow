#!/usr/bin/env python3
"""Check release/schema/protocol/toolchain declarations for repository drift."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def text(path: str) -> str:
    return (ROOT / path).read_text(encoding="utf-8")


def require(pattern: str, value: str, label: str, *, flags: int = 0) -> str:
    match = re.search(pattern, value, flags)
    if match is None:
        raise ValueError(f"Could not find {label}.")
    return match.group(1)


def main() -> int:
    errors: list[str] = []
    cargo = text("Cargo.toml")

    cargo_version = require(
        r"\[workspace\.package\][\s\S]*?^version\s*=\s*\"([^\"]+)\"",
        cargo,
        "workspace package version",
        flags=re.MULTILINE,
    )
    cargo_rust_version = require(
        r"\[workspace\.package\][\s\S]*?^rust-version\s*=\s*\"([^\"]+)\"",
        cargo,
        "workspace Rust version",
        flags=re.MULTILINE,
    )
    flutter_version = require(
        r"^version:\s*([^+\s]+)(?:\+\d+)?\s*$",
        text("apps/unitflow_app/pubspec.yaml"),
        "Flutter package version",
        flags=re.MULTILINE,
    )
    about_version = require(
        r"appVersion\s*=\s*'([^']+)'",
        text("apps/unitflow_app/lib/features/settings/presentation/about_screen.dart"),
        "About screen version",
    )

    for label, candidate in (
        ("Flutter package", flutter_version),
        ("About screen", about_version),
    ):
        if candidate != cargo_version:
            errors.append(
                f"{label} version {candidate!r} does not match workspace version {cargo_version!r}."
            )

    changelog = text("CHANGELOG.md")
    if f"[{cargo_version}]" not in changelog:
        errors.append(f"CHANGELOG.md has no [{cargo_version}] section.")

    setup_rust_version = require(
        r"declares Rust `([^`]+)` as its minimum supported Rust version",
        text("docs/setup.md"),
        "documented minimum Rust version",
    )
    if setup_rust_version != cargo_rust_version:
        errors.append(
            "docs/setup.md minimum Rust version "
            f"{setup_rust_version!r} does not match Cargo.toml {cargo_rust_version!r}."
        )

    dart_schema = int(
        require(
            r"schemaVersion\s*=\s*(\d+)",
            text("apps/unitflow_app/lib/core/persistence/user_state.dart"),
            "Dart local-state schema version",
        )
    )
    documented_schema = int(
        require(
            r"Current schema version:\s*`(\d+)`",
            text("docs/data-format.md"),
            "documented local-state schema version",
        )
    )
    if dart_schema != documented_schema:
        errors.append(
            f"Data schema docs report {documented_schema}, Dart code reports {dart_schema}."
        )

    fixture = json.loads(text("fixtures/bridge_parity_v1.json"))
    fixture_protocol = fixture.get("protocolVersion")
    documented_protocol = int(
        require(
            r"Current protocol version:\s*`(\d+)`",
            text("docs/bridge-protocol.md"),
            "documented bridge protocol version",
        )
    )
    if fixture_protocol != documented_protocol:
        errors.append(
            f"Bridge fixture protocol {fixture_protocol!r} does not match documented protocol {documented_protocol}."
        )

    if errors:
        print("Release consistency validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        "Release consistency validation passed: "
        f"version={cargo_version}, rust={cargo_rust_version}, "
        f"schema={dart_schema}, bridge_protocol={documented_protocol}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
