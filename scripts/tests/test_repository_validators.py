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
platform_support = load_module(
    "check_platform_support", "scripts/check_platform_support.py"
)
accessibility_contract = load_module(
    "check_accessibility_contract", "scripts/check_accessibility_contract.py"
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

    def test_bridge_protocol_matches_fixture_docs_rust_and_flutter(self) -> None:
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
        flutter_source = int(
            release_consistency.require(
                r"nativeBridgeProtocolVersion\s*=\s*(\d+)",
                release_consistency.text(
                    "apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart"
                ),
                "Flutter bridge protocol version",
            )
        )
        self.assertEqual(fixture["protocolVersion"], documented)
        self.assertEqual(rust_source, documented)
        self.assertEqual(flutter_source, documented)

    def test_bridge_capabilities_match_docs_rust_and_flutter(self) -> None:
        rust, flutter, documented = release_consistency.declared_bridge_capabilities()
        expected = {"convert", "batchConvert", "canonicalDecimalText"}
        self.assertEqual(rust, expected)
        self.assertEqual(flutter, expected)
        self.assertEqual(documented, expected)

    def test_bridge_batch_limits_match_all_execution_contracts(self) -> None:
        rust, flutter_bridge, flutter_fallback, documented = (
            release_consistency.declared_bridge_batch_limits()
        )
        self.assertEqual(rust, 256)
        self.assertEqual(flutter_bridge, 256)
        self.assertEqual(flutter_fallback, 256)
        self.assertEqual(documented, 256)

    def test_release_consistency_accepts_current_tree(self) -> None:
        self.assertEqual(release_consistency.main(), 0)


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
        self.assertIn("scripts/check_platform_support.py", documented)
        self.assertIn("scripts/check_accessibility_contract.py", documented)
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


class AccessibilityContractTests(unittest.TestCase):
    def test_current_tree_satisfies_accessibility_source_contract(self) -> None:
        self.assertEqual(accessibility_contract.validate(), [])

    def test_all_modal_surfaces_are_discovered_and_guarded(self) -> None:
        calls = accessibility_contract.modal_calls()
        self.assertGreaterEqual(len(calls), 4)
        self.assertTrue(any(call.kind == "dialog" for call in calls))
        self.assertTrue(any(call.kind == "bottomSheet" for call in calls))
        for call in calls:
            expected = (
                "animationStyle: AppMotion.modalSurfaceStyle(context)"
                if call.kind == "dialog"
                else "sheetAnimationStyle: AppMotion.modalSurfaceStyle(context)"
            )
            self.assertIn(expected, call.header, call.path)

    def test_accessibility_validator_main_accepts_current_tree(self) -> None:
        self.assertEqual(accessibility_contract.main(), 0)


class PlatformSupportTests(unittest.TestCase):
    def test_support_contract_targets_exactly_six_platforms(self) -> None:
        self.assertEqual(
            platform_support.PLATFORMS,
            ("android", "ios", "web", "windows", "linux", "macos"),
        )

    def test_each_platform_has_a_release_build_command(self) -> None:
        self.assertEqual(set(platform_support.BUILD_COMMANDS), set(platform_support.PLATFORMS))
        for command in platform_support.BUILD_COMMANDS.values():
            self.assertIn("--release", command)

    def test_repository_satisfies_cross_platform_contract(self) -> None:
        self.assertEqual(platform_support.validate(), [])


if __name__ == "__main__":
    unittest.main()
