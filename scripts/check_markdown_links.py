#!/usr/bin/env python3
"""Validate repository-local Markdown links without third-party dependencies."""

from __future__ import annotations

import re
import sys
from pathlib import Path
from urllib.parse import unquote, urlparse

ROOT = Path(__file__).resolve().parents[1]
LINK_PATTERN = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
IGNORED_DIRS = {".git", ".dart_tool", "build", "target"}


def markdown_files() -> list[Path]:
    return sorted(
        path
        for path in ROOT.rglob("*.md")
        if not any(part in IGNORED_DIRS for part in path.relative_to(ROOT).parts)
    )


def local_target(raw_target: str) -> str | None:
    target = raw_target.strip()
    if not target or target.startswith("#"):
        return None

    # Strip an optional Markdown title from the common `path "title"` form.
    if " \"" in target:
        target = target.split(" \"", 1)[0]
    elif " '" in target:
        target = target.split(" '", 1)[0]

    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1]

    parsed = urlparse(target)
    if parsed.scheme or parsed.netloc:
        return None

    path = unquote(parsed.path)
    return path or None


def main() -> int:
    errors: list[str] = []
    checked = 0

    for markdown in markdown_files():
        text = markdown.read_text(encoding="utf-8")
        for match in LINK_PATTERN.finditer(text):
            target = local_target(match.group(1))
            if target is None:
                continue

            checked += 1
            candidate = (markdown.parent / target).resolve()
            try:
                candidate.relative_to(ROOT)
            except ValueError:
                errors.append(
                    f"{markdown.relative_to(ROOT)}: link escapes repository: {target}"
                )
                continue

            if not candidate.exists():
                line = text.count("\n", 0, match.start()) + 1
                errors.append(
                    f"{markdown.relative_to(ROOT)}:{line}: missing local target: {target}"
                )

    if errors:
        print("Markdown link validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        f"Markdown link validation passed: {len(markdown_files())} files, "
        f"{checked} local links checked."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
