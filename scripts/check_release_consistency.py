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


def declared_bridge_capabilities() -> tuple[set[str], set[str], set[str]]:
    rust_source = text("crates/unitflow_core/src/bridge.rs")
    flutter_source = text(
        "apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart"
    )
    protocol_docs = text("docs/bridge-protocol.md")

    rust_constants = dict(
        re.findall(
            r'^pub const (BRIDGE_CAPABILITY_[A-Z_]+): &str = "([^"]+)";$',
            rust_source,
            flags=re.MULTILINE,
        )
    )
    rust_list = require(
        r"BRIDGE_CAPABILITIES:\s*\[&str;\s*\d+\]\s*=\s*\[([\s\S]*?)\];",
        rust_source,
        "Rust bridge capability list",
    )
    rust_names = set(re.findall(r"\bBRIDGE_CAPABILITY_[A-Z_]+\b", rust_list))
    unknown_rust_names = rust_names - rust_constants.keys()
    if unknown_rust_names:
        raise ValueError(
            "Rust bridge capability list references undefined constants: "
            + ", ".join(sorted(unknown_rust_names))
        )
    rust_capabilities = {rust_constants[name] for name in rust_names}

    flutter_constants = dict(
        re.findall(
            r"^const String (nativeBridgeCapability[A-Za-z0-9]+)\s*=\s*'([^']+)';$",
            flutter_source,
            flags=re.MULTILINE,
        )
    )
    flutter_list = require(
        r"nativeBridgeRequiredCapabilities\s*=\s*<String>\{([\s\S]*?)\};",
        flutter_source,
        "Flutter bridge capability set",
    )
    flutter_names = set(
        re.findall(r"\bnativeBridgeCapability[A-Za-z0-9]+\b", flutter_list)
    )
    unknown_flutter_names = flutter_names - flutter_constants.keys()
    if unknown_flutter_names:
        raise ValueError(
            "Flutter bridge capability set references undefined constants: "
            + ", ".join(sorted(unknown_flutter_names))
        )
    flutter_capabilities = {flutter_constants[name] for name in flutter_names}

    documented_line = require(
        r"Current required capabilities:\s*([^\n]+)",
        protocol_docs,
        "documented bridge capabilities",
    )
    documented_capabilities = set(re.findall(r"`([^`]+)`", documented_line))

    return rust_capabilities, flutter_capabilities, documented_capabilities


def declared_bridge_batch_limits() -> tuple[int, int, int, int]:
    rust_limit = int(
        require(
            r"BRIDGE_MAX_BATCH_TARGETS:\s*usize\s*=\s*(\d+)",
            text("crates/unitflow_core/src/bridge.rs"),
            "Rust bridge batch target limit",
        )
    )
    flutter_bridge_limit = int(
        require(
            r"nativeBridgeMaxBatchTargets\s*=\s*(\d+)",
            text("apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart"),
            "Flutter bridge batch target limit",
        )
    )
    flutter_fallback_limit = int(
        require(
            r"maxBatchConversionTargets\s*=\s*(\d+)",
            text(
                "apps/unitflow_app/lib/features/converter/domain/conversion_engine.dart"
            ),
            "Flutter fallback batch target limit",
        )
    )
    documented_limit = int(
        require(
            r"Current maximum batch targets:\s*`(\d+)`",
            text("docs/bridge-protocol.md"),
            "documented bridge batch target limit",
        )
    )
    return rust_limit, flutter_bridge_limit, flutter_fallback_limit, documented_limit


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
    rust_bridge_protocol = int(
        require(
            r"BRIDGE_PROTOCOL_VERSION:\s*u32\s*=\s*(\d+)",
            text("crates/unitflow_core/src/bridge.rs"),
            "Rust bridge protocol version",
        )
    )
    dart_bridge_protocol = int(
        require(
            r"nativeBridgeProtocolVersion\s*=\s*(\d+)",
            text("apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart"),
            "Flutter bridge protocol version",
        )
    )
    if fixture_protocol != documented_protocol:
        errors.append(
            f"Bridge fixture protocol {fixture_protocol!r} does not match documented protocol {documented_protocol}."
        )
    if rust_bridge_protocol != documented_protocol:
        errors.append(
            "Rust bridge protocol "
            f"{rust_bridge_protocol} does not match documented protocol {documented_protocol}."
        )
    if dart_bridge_protocol != documented_protocol:
        errors.append(
            "Flutter bridge protocol "
            f"{dart_bridge_protocol} does not match documented protocol {documented_protocol}."
        )

    rust_capabilities, flutter_capabilities, documented_capabilities = (
        declared_bridge_capabilities()
    )
    if not documented_capabilities:
        errors.append("Bridge protocol documentation declares no required capabilities.")
    if rust_capabilities != documented_capabilities:
        errors.append(
            "Rust bridge capabilities "
            f"{sorted(rust_capabilities)!r} do not match documentation "
            f"{sorted(documented_capabilities)!r}."
        )
    if flutter_capabilities != documented_capabilities:
        errors.append(
            "Flutter bridge capabilities "
            f"{sorted(flutter_capabilities)!r} do not match documentation "
            f"{sorted(documented_capabilities)!r}."
        )

    (
        rust_batch_limit,
        flutter_bridge_batch_limit,
        flutter_fallback_batch_limit,
        documented_batch_limit,
    ) = declared_bridge_batch_limits()
    if documented_batch_limit <= 0:
        errors.append("Bridge batch target limit must be positive.")
    if rust_batch_limit != documented_batch_limit:
        errors.append(
            f"Rust bridge batch limit {rust_batch_limit} does not match documentation {documented_batch_limit}."
        )
    if flutter_bridge_batch_limit != documented_batch_limit:
        errors.append(
            "Flutter bridge batch limit "
            f"{flutter_bridge_batch_limit} does not match documentation {documented_batch_limit}."
        )
    if flutter_fallback_batch_limit != documented_batch_limit:
        errors.append(
            "Flutter fallback batch limit "
            f"{flutter_fallback_batch_limit} does not match documentation {documented_batch_limit}."
        )

    if errors:
        print("Release consistency validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        "Release consistency validation passed: "
        f"version={cargo_version}, rust={cargo_rust_version}, "
        f"schema={dart_schema}, bridge_protocol={documented_protocol}, "
        f"bridge_capabilities={','.join(sorted(documented_capabilities))}, "
        f"bridge_batch_limit={documented_batch_limit}."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
