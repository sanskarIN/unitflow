#!/usr/bin/env python3
"""Validate tracked JSON and ARB files with the Python standard library."""

from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]


class DuplicateKeyError(ValueError):
    """Raised when a JSON object repeats the same key."""


def reject_duplicate_keys(pairs: list[tuple[str, Any]]) -> dict[str, Any]:
    result: dict[str, Any] = {}
    for key, value in pairs:
        if key in result:
            raise DuplicateKeyError(f"duplicate object key {key!r}")
        result[key] = value
    return result


def tracked_data_files() -> list[Path]:
    try:
        output = subprocess.check_output(
            ["git", "ls-files", "-z", "*.json", "*.arb"],
            cwd=ROOT,
            stderr=subprocess.STDOUT,
        )
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"data-file check could not enumerate files: {error}", file=sys.stderr)
        raise SystemExit(2) from error
    return [
        ROOT / raw.decode("utf-8", errors="surrogateescape")
        for raw in output.split(b"\0")
        if raw
    ]


def main() -> int:
    failures: list[str] = []
    for path in tracked_data_files():
        relative = path.relative_to(ROOT).as_posix()
        try:
            with path.open("r", encoding="utf-8") as handle:
                json.load(handle, object_pairs_hook=reject_duplicate_keys)
        except (OSError, UnicodeDecodeError, json.JSONDecodeError, DuplicateKeyError) as error:
            failures.append(f"{relative}: {error}")

    if failures:
        print("Invalid JSON/ARB files:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print("Tracked JSON and ARB files are valid UTF-8 JSON with unique object keys.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
