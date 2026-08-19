#!/usr/bin/env python3
"""Regression tests for UnitFlow version consistency helpers."""

from __future__ import annotations

import unittest

from check_versions import (
    check_codegen_pins,
    flutter_build_name,
    load_pubspec_versions,
    load_workspace_versions,
    release_core_version,
)


class VersionConsistencyTests(unittest.TestCase):
    def test_release_core_ignores_prerelease_and_build_metadata(self) -> None:
        self.assertEqual(release_core_version("0.1.0-alpha.1"), "0.1.0")
        self.assertEqual(release_core_version("1.2.3+meta"), "1.2.3")

    def test_flutter_version_requires_numeric_build_name_and_number(self) -> None:
        self.assertEqual(flutter_build_name("0.1.0+7"), "0.1.0")
        with self.assertRaises(ValueError):
            flutter_build_name("0.1.0-alpha.1+7")
        with self.assertRaises(ValueError):
            flutter_build_name("0.1.0")

    def test_repository_release_versions_match_platform_policy(self) -> None:
        workspace_version, workspace_frb = load_workspace_versions()
        flutter_version, flutter_frb = load_pubspec_versions()

        self.assertEqual(
            flutter_build_name(flutter_version),
            release_core_version(workspace_version),
        )
        self.assertEqual(flutter_frb, workspace_frb)

    def test_codegen_install_pins_match_workspace_dependency(self) -> None:
        _, workspace_frb = load_workspace_versions()
        self.assertEqual(check_codegen_pins(workspace_frb), [])


if __name__ == "__main__":
    unittest.main()
