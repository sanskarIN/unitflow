#!/usr/bin/env python3
"""Regenerate the tracked Flutter platform scaffold inventory from the Git index."""

from __future__ import annotations

import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INVENTORY = ROOT / "docs" / "platform-file-inventory.md"
APP_PREFIX = "apps/unitflow_app/"
PLATFORM_PREFIXES = tuple(
    f"{APP_PREFIX}{platform}/"
    for platform in ("android", "ios", "web", "windows", "linux", "macos")
)
METADATA_PATH = f"{APP_PREFIX}.metadata"
START = "<!-- UNITFLOW_PLATFORM_FILES_START -->"
END = "<!-- UNITFLOW_PLATFORM_FILES_END -->"


def indexed_files() -> list[str]:
    process = subprocess.run(
        ["git", "ls-files", "--cached", "-z"],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    return sorted(
        item.decode("utf-8")
        for item in process.stdout.split(b"\0")
        if item
    )


def platform_files() -> list[str]:
    return [
        path
        for path in indexed_files()
        if path == METADATA_PATH or path.startswith(PLATFORM_PREFIXES)
    ]


def generated_section(paths: list[str]) -> str:
    if not paths:
        return "\nNo Flutter platform scaffold files are committed yet.\n"
    lines = [
        f"- `{path}` — Flutter-generated cross-platform scaffold file."
        for path in paths
    ]
    return "\n" + "\n".join(lines) + "\n"


def main() -> int:
    source = INVENTORY.read_text(encoding="utf-8")
    if START not in source or END not in source:
        raise SystemExit(
            "docs/platform-file-inventory.md is missing generated section markers"
        )

    before, remainder = source.split(START, 1)
    _, after = remainder.split(END, 1)
    paths = platform_files()
    rendered = before + START + generated_section(paths) + END + after
    INVENTORY.write_text(rendered, encoding="utf-8")
    print(f"Updated platform inventory with {len(paths)} tracked scaffold files.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
