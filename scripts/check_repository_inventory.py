#!/usr/bin/env python3
"""Require every tracked file to be documented exactly once in repository inventories."""

from __future__ import annotations

import re
import subprocess
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
INVENTORIES = (
    ROOT / "docs" / "repository-inventory.md",
    ROOT / "docs" / "platform-file-inventory.md",
)
ENTRY_RE = re.compile(r"^- `([^`]+)`\s+—\s+.+$", re.MULTILINE)


def tracked_files() -> list[str]:
    process = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    return sorted(
        value.decode("utf-8")
        for value in process.stdout.split(b"\0")
        if value
    )


def documented_files() -> list[str]:
    documented: list[str] = []
    for inventory in INVENTORIES:
        if inventory.is_file():
            documented.extend(ENTRY_RE.findall(inventory.read_text(encoding="utf-8")))
    return documented


def main() -> int:
    missing_inventories = [
        inventory.relative_to(ROOT).as_posix()
        for inventory in INVENTORIES
        if not inventory.is_file()
    ]
    if missing_inventories:
        print("Repository inventory file(s) missing:", file=sys.stderr)
        for path in missing_inventories:
            print(f"- {path}", file=sys.stderr)
        return 1

    try:
        tracked = tracked_files()
    except (subprocess.CalledProcessError, FileNotFoundError) as error:
        print(
            f"Repository inventory validation could not inspect Git files: {error}",
            file=sys.stderr,
        )
        return 2

    documented = documented_files()
    counts = Counter(documented)
    duplicates = sorted(path for path, count in counts.items() if count != 1)
    tracked_set = set(tracked)
    documented_set = set(documented)
    missing = sorted(tracked_set - documented_set)
    stale = sorted(documented_set - tracked_set)

    if duplicates or missing or stale:
        print("Repository inventory validation failed:", file=sys.stderr)
        if duplicates:
            print("- duplicate inventory entries:", file=sys.stderr)
            for path in duplicates:
                print(f"  - {path}", file=sys.stderr)
        if missing:
            print("- tracked files missing from inventory:", file=sys.stderr)
            for path in missing:
                print(f"  - {path}", file=sys.stderr)
        if stale:
            print("- inventory entries that are not tracked files:", file=sys.stderr)
            for path in stale:
                print(f"  - {path}", file=sys.stderr)
        return 1

    print(
        "Repository inventory validation passed: "
        f"{len(tracked)} tracked files documented exactly once across "
        f"{len(INVENTORIES)} inventories."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
