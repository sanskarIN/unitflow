#!/usr/bin/env python3
"""Validate that a release tag matches UnitFlow's workspace release version."""

from __future__ import annotations

import os
import sys

from check_versions import load_workspace_versions


def expected_tag(version: str) -> str:
    return f"v{version}"


def validate_tag(tag: str, version: str) -> None:
    expected = expected_tag(version)
    if tag != expected:
        raise ValueError(f"release tag {tag!r} does not match expected {expected!r}")


def main(argv: list[str] | None = None) -> int:
    args = sys.argv[1:] if argv is None else argv
    if len(args) > 1:
        print("usage: check_release_tag.py [tag]", file=sys.stderr)
        return 2

    tag = args[0] if args else os.environ.get("GITHUB_REF_NAME", "")
    if not tag:
        print("Release tag is required as an argument or GITHUB_REF_NAME.", file=sys.stderr)
        return 2

    try:
        version, _ = load_workspace_versions()
        validate_tag(tag, version)
    except (OSError, UnicodeDecodeError, ValueError) as error:
        print(f"Release tag validation failed: {error}", file=sys.stderr)
        return 1

    print(f"Release tag {tag} matches workspace version {version}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
