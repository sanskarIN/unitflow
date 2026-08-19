#!/usr/bin/env python3
"""Regression tests for UnitFlow release tag validation."""

from __future__ import annotations

import unittest

from check_release_tag import expected_tag, validate_tag


class ReleaseTagTests(unittest.TestCase):
    def test_expected_tag_prefixes_workspace_version(self) -> None:
        self.assertEqual(expected_tag("0.1.0-alpha.1"), "v0.1.0-alpha.1")

    def test_matching_tag_is_accepted(self) -> None:
        validate_tag("v0.1.0-alpha.1", "0.1.0-alpha.1")

    def test_mismatched_tag_is_rejected(self) -> None:
        with self.assertRaises(ValueError):
            validate_tag("v0.1.0", "0.1.0-alpha.1")


if __name__ == "__main__":
    unittest.main()
