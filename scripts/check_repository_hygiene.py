#!/usr/bin/env python3
"""Validate critical repository files and reject commonly accidental tracked artifacts."""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[1]

REQUIRED_FILES = (
    ".env.example",
    ".gitignore",
    "Cargo.toml",
    "README.md",
    "ROADMAP.md",
    "CHANGELOG.md",
    "CONTRIBUTING.md",
    "SECURITY.md",
    "PRIVACY.md",
    "SUPPORT.md",
    "CODE_OF_CONDUCT.md",
    "LICENSE",
    "what_changed.md",
    ".github/dependabot.yml",
    ".github/workflows/ci.yml",
    ".github/workflows/codeql.yml",
    ".github/workflows/dependency-review.yml",
    ".github/workflows/platform-smoke.yml",
    ".github/workflows/release.yml",
    "apps/unitflow_app/pubspec.yaml",
    "apps/unitflow_app/l10n.yaml",
    "apps/unitflow_app/lib/l10n/app_en.arb",
    "docs/README.md",
    "docs/architecture.md",
    "docs/bridge.md",
    "docs/bridge-protocol.md",
    "docs/data-format.md",
    "docs/dependencies.md",
    "docs/diagnostics.md",
    "docs/localization.md",
    "docs/native-platforms.md",
    "docs/platform-smoke.md",
    "docs/release.md",
    "docs/release-checklist.md",
    "docs/setup.md",
    "docs/testing.md",
    "docs/threat-model.md",
    "scripts/check_markdown_links.py",
    "scripts/check_release_consistency.py",
    "scripts/check_release_tag.py",
    "scripts/check_repository_hygiene.py",
    "scripts/tests/test_repository_validators.py",
    "scripts/verify.sh",
    "scripts/verify.ps1",
)

FORBIDDEN_SUFFIXES = (
    ".jks",
    ".keystore",
    ".p12",
    ".mobileprovision",
)

FORBIDDEN_PARTS = (
    "/.dart_tool/",
    "/build/",
    "/target/",
    "/lib/l10n/generated/",
)


def tracked_files() -> list[str]:
    process = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    return [
        value.decode("utf-8")
        for value in process.stdout.split(b"\0")
        if value
    ]


def main() -> int:
    errors: list[str] = []

    for relative in REQUIRED_FILES:
        if not (ROOT / relative).is_file():
            errors.append(f"required file is missing: {relative}")

    try:
        tracked = tracked_files()
    except (subprocess.CalledProcessError, FileNotFoundError) as error:
        print(f"Repository hygiene validation could not inspect Git files: {error}", file=sys.stderr)
        return 2

    for path in tracked:
        normalized = f"/{path.replace('\\', '/')}"
        lower_path = path.lower()
        file_name = PurePosixPath(path.replace("\\", "/")).name.lower()

        if file_name == ".env":
            errors.append(f"forbidden local environment file is tracked: {path}")
        if file_name.startswith(".env.") and file_name != ".env.example":
            errors.append(f"unexpected environment file is tracked: {path}")
        if lower_path.endswith(FORBIDDEN_SUFFIXES):
            errors.append(f"potential signing/credential artifact is tracked: {path}")
        if any(part in normalized for part in FORBIDDEN_PARTS):
            errors.append(f"generated/build artifact is tracked: {path}")

    if errors:
        print("Repository hygiene validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        f"Repository hygiene validation passed: {len(REQUIRED_FILES)} required files, "
        f"{len(tracked)} tracked paths inspected."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
