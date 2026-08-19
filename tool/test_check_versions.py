#!/usr/bin/env python3
"""Regression tests for UnitFlow version consistency helpers."""

from __future__ import annotations

import unittest

from check_versions import (
    check_codegen_pins,
    flutter_semver,
    load_pubspec_versions,
    load_workspace_versions,
)


class VersionConsistencyTests(unittest.TestCase):
    def test_flutter_build_metadata_is_not_part_of_release_semver(self) -> None:
        self.assertEqual(flutter_semver("0.1.0-alpha.1+7"), "0.1.0-alpha.1")
        self.assertEqual(flutter_semver("1.2.3"), "1.2.3")

    def test_repository_release_versions_match(self) -> None:
        workspace_version, workspace_frb = load_workspace_versions()
        flutter_version, flutter_frb = load_pubspec_versions()

        self.assertEqual(flutter_semver(flutter_version), workspace_version)
        self.assertEqual(flutter_frb, workspace_frb)

    def test_codegen_install_pins_match_workspace_dependency(self) -> None:
        _, workspace_frb = load_workspace_versions()
        self.assertEqual(check_codegen_pins(workspace_frb), [])


if __name__ == "__main__":
    unittest.main()
