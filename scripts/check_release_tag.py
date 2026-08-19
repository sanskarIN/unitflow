#!/usr/bin/env python3
"""Ensure a release tag exactly matches the repository package version."""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def workspace_version() -> str:
    cargo = (ROOT / "Cargo.toml").read_text(encoding="utf-8")
    match = re.search(
        r"\[workspace\.package\][\s\S]*?^version\s*=\s*\"([^\"]+)\"",
        cargo,
        re.MULTILINE,
    )
    if match is None:
        raise ValueError("Could not find workspace package version in Cargo.toml.")
    return match.group(1)


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("usage: check_release_tag.py <tag>", file=sys.stderr)
        return 2

    tag = argv[1].strip()
    version = workspace_version()
    expected = f"v{version}"

    if tag != expected:
        print(
            f"Release tag mismatch: received {tag!r}, expected {expected!r} "
            f"for workspace version {version!r}.",
            file=sys.stderr,
        )
        return 1

    print(f"Release tag validation passed: {tag} matches workspace version {version}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv))
