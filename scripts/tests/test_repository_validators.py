from __future__ import annotations

import importlib.util
import json
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
repository_inventory = load_module(
    "check_repository_inventory", "scripts/check_repository_inventory.py"
)
platform_inventory = load_module(
    "update_platform_inventory", "scripts/update_platform_inventory.py"
)


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

    def test_rust_bridge_protocol_matches_fixture_and_docs(self) -> None:
        fixture = json.loads(
            release_consistency.text("fixtures/bridge_parity_v1.json")
        )
        documented = int(
            release_consistency.require(
                r"Current protocol version:\s*`(\d+)`",
                release_consistency.text("docs/bridge-protocol.md"),
                "documented bridge protocol version",
            )
        )
        rust_source = int(
            release_consistency.require(
                r"BRIDGE_PROTOCOL_VERSION:\s*u32\s*=\s*(\d+)",
                release_consistency.text("crates/unitflow_core/src/bridge.rs"),
                "Rust bridge protocol version",
            )
        )
        self.assertEqual(fixture["protocolVersion"], documented)
        self.assertEqual(rust_source, documented)


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


class RepositoryInventoryTests(unittest.TestCase):
    def test_inventory_parser_documents_repository_and_platform_support(self) -> None:
        documented = repository_inventory.documented_files()
        self.assertIn("docs/repository-inventory.md", documented)
        self.assertIn("scripts/check_repository_inventory.py", documented)
        self.assertIn("docs/platform-file-inventory.md", documented)
        self.assertIn("scripts/update_platform_inventory.py", documented)
        self.assertIn(".github/workflows/materialize-platforms.yml", documented)

    def test_inventory_entries_are_unique(self) -> None:
        documented = repository_inventory.documented_files()
        self.assertEqual(len(documented), len(set(documented)))

    def test_generated_platform_entries_use_inventory_format(self) -> None:
        section = platform_inventory.generated_section(
            ["apps/unitflow_app/android/app/build.gradle.kts"]
        )
        self.assertIn(
            "- `apps/unitflow_app/android/app/build.gradle.kts` — Flutter-generated cross-platform scaffold file.",
            section,
        )

    def test_platform_inventory_targets_all_six_platforms(self) -> None:
        for platform in ("android", "ios", "web", "windows", "linux", "macos"):
            prefix = f"apps/unitflow_app/{platform}/"
            self.assertIn(prefix, platform_inventory.PLATFORM_PREFIXES)


if __name__ == "__main__":
    unittest.main()
