#!/usr/bin/env python3
"""Verify that relative links in tracked Markdown files resolve inside the repository."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parents[1]
LINK = re.compile(r"(?<!!)\[[^\]]*\]\(([^)]+)\)")
EXTERNAL_PREFIXES = ("http://", "https://", "mailto:", "tel:", "#")


def markdown_files() -> list[Path]:
    try:
        output = subprocess.check_output(
            ["git", "ls-files", "-z", "*.md"], cwd=ROOT, stderr=subprocess.STDOUT
        )
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"documentation link check could not enumerate files: {error}", file=sys.stderr)
        raise SystemExit(2) from error
    return [
        ROOT / raw.decode("utf-8", errors="surrogateescape")
        for raw in output.split(b"\0")
        if raw
    ]


def normalize_target(raw: str) -> str | None:
    target = raw.strip()
    if not target or target.startswith(EXTERNAL_PREFIXES):
        return None
    if target.startswith("<") and target.endswith(">"):
        target = target[1:-1]
    if " " in target and not target.startswith("./") and not target.startswith("../"):
        # Markdown permits an optional title after a URL. Keep the URL token only.
        target = target.split(" ", 1)[0]
    target = target.split("#", 1)[0].split("?", 1)[0]
    return unquote(target) or None


def main() -> int:
    failures: list[str] = []
    for document in markdown_files():
        try:
            text = document.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            failures.append(f"{document.relative_to(ROOT)}: not valid UTF-8")
            continue
        for match in LINK.finditer(text):
            target = normalize_target(match.group(1))
            if target is None:
                continue
            candidate = (document.parent / target).resolve()
            try:
                candidate.relative_to(ROOT)
            except ValueError:
                failures.append(
                    f"{document.relative_to(ROOT)}: link escapes repository: {target}"
                )
                continue
            if not candidate.exists():
                line = text.count("\n", 0, match.start()) + 1
                failures.append(
                    f"{document.relative_to(ROOT)}:{line}: missing target: {target}"
                )

    if failures:
        print("Broken internal documentation links:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        return 1

    print("Internal Markdown links resolve successfully.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
