#!/usr/bin/env python3
"""Fail CI when tracked source-like files contain common credential signatures.

This intentionally complements, rather than replaces, GitHub secret scanning. It uses
only the Python standard library so contributors can run it locally without setup.
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MAX_BYTES = 2 * 1024 * 1024

PATTERNS: tuple[tuple[str, re.Pattern[str]], ...] = (
    ("private key", re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----")),
    ("AWS access key", re.compile(r"\bAKIA[0-9A-Z]{16}\b")),
    ("GitHub token", re.compile(r"\bgh[pousr]_[A-Za-z0-9_]{20,}\b")),
    ("Google API key", re.compile(r"\bAIza[0-9A-Za-z_-]{35}\b")),
    ("Stripe live secret", re.compile(r"\bsk_live_[0-9A-Za-z]{20,}\b")),
    ("generic bearer token", re.compile(r"(?i)\bauthorization\s*[:=]\s*bearer\s+[A-Za-z0-9._~-]{20,}")),
)

SKIP_PREFIXES = (
    ".git/",
    "build/",
    "target/",
    ".dart_tool/",
    "apps/unitflow_app/build/",
    "apps/unitflow_app/.dart_tool/",
)


def tracked_files() -> list[Path]:
    try:
        output = subprocess.check_output(
            ["git", "ls-files", "-z"], cwd=ROOT, stderr=subprocess.STDOUT
        )
    except (OSError, subprocess.CalledProcessError) as error:
        print(f"secret scan could not enumerate tracked files: {error}", file=sys.stderr)
        raise SystemExit(2) from error

    paths: list[Path] = []
    for raw in output.split(b"\0"):
        if not raw:
            continue
        relative = raw.decode("utf-8", errors="surrogateescape").replace("\\", "/")
        if relative.startswith(SKIP_PREFIXES):
            continue
        paths.append(ROOT / relative)
    return paths


def readable_text(path: Path) -> str | None:
    try:
        if path.stat().st_size > MAX_BYTES:
            return None
        data = path.read_bytes()
    except OSError:
        return None
    if b"\0" in data:
        return None
    try:
        return data.decode("utf-8")
    except UnicodeDecodeError:
        return None


def main() -> int:
    findings: list[str] = []
    for path in tracked_files():
        text = readable_text(path)
        if text is None:
            continue
        relative = path.relative_to(ROOT).as_posix()
        for label, pattern in PATTERNS:
            for match in pattern.finditer(text):
                line = text.count("\n", 0, match.start()) + 1
                findings.append(f"{relative}:{line}: possible {label}")

    if findings:
        print("Potential secrets detected. Do not commit credentials or private keys:", file=sys.stderr)
        for finding in findings:
            print(f"  - {finding}", file=sys.stderr)
        return 1

    print("Repository secret-pattern scan passed.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
