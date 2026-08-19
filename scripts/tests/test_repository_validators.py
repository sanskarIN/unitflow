from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load_module(name: str, relative_path: str):
    spec = importlib.util.spec_from_file_location(name, ROOT / relative_path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load {relative_path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


markdown_links = load_module("check_markdown_links", "scripts/check_markdown_links.py")
release_consistency = load_module(
    "check_release_consistency", "scripts/check_release_consistency.py"
)
release_tag = load_module("check_release_tag", "scripts/check_release_tag.py")


class MarkdownLinkParserTests(unittest.TestCase):
    def test_external_links_are_ignored(self) -> None:
        self.assertIsNone(markdown_links.local_target("https://example.com/docs"))

    def test_fragment_only_links_are_ignored(self) -> None:
        self.assertIsNone(markdown_links.local_target("#section"))

    def test_local_fragment_returns_file_path(self) -> None:
        self.assertEqual(
            markdown_links.local_target("../README.md#getting-started"),
            "../README.md",
        )

    def test_markdown_title_is_removed(self) -> None:
        self.assertEqual(
            markdown_links.local_target('setup.md "Setup guide"'),
            "setup.md",
        )


class ReleaseConsistencyHelperTests(unittest.TestCase):
    def test_require_returns_first_capture(self) -> None:
        self.assertEqual(
            release_consistency.require(r"version=(\d+)", "version=2", "version"),
            "2",
        )

    def test_require_rejects_missing_value(self) -> None:
        with self.assertRaises(ValueError):
            release_consistency.require(r"version=(\d+)", "missing", "version")


class ReleaseTagTests(unittest.TestCase):
    def test_workspace_version_is_semver_style(self) -> None:
        self.assertRegex(
            release_tag.workspace_version(),
            r"^\d+\.\d+\.\d+(?:-[0-9A-Za-z.-]+)?$",
        )

    def test_matching_tag_passes(self) -> None:
        version = release_tag.workspace_version()
        self.assertEqual(release_tag.main(["check_release_tag.py", f"v{version}"]), 0)

    def test_mismatched_tag_fails(self) -> None:
        version = release_tag.workspace_version()
        self.assertEqual(
            release_tag.main(["check_release_tag.py", f"not-v{version}"]),
            1,
        )

    def test_missing_tag_is_usage_error(self) -> None:
        self.assertEqual(release_tag.main(["check_release_tag.py"]), 2)


if __name__ == "__main__":
    unittest.main()
