#!/usr/bin/env python3
"""Regression tests for repository JSON/ARB validation helpers."""

from __future__ import annotations

import json
import unittest

from check_data_files import DuplicateKeyError, reject_duplicate_keys


class RejectDuplicateKeysTests(unittest.TestCase):
    def test_accepts_unique_object_keys(self) -> None:
        decoded = json.loads(
            '{"schemaVersion":2,"nested":{"value":true}}',
            object_pairs_hook=reject_duplicate_keys,
        )
        self.assertEqual(decoded["schemaVersion"], 2)
        self.assertEqual(decoded["nested"]["value"], True)

    def test_rejects_duplicate_root_key(self) -> None:
        with self.assertRaises(DuplicateKeyError):
            json.loads(
                '{"schemaVersion":1,"schemaVersion":2}',
                object_pairs_hook=reject_duplicate_keys,
            )

    def test_rejects_duplicate_nested_key(self) -> None:
        with self.assertRaises(DuplicateKeyError):
            json.loads(
                '{"nested":{"value":1,"value":2}}',
                object_pairs_hook=reject_duplicate_keys,
            )


if __name__ == "__main__":
    unittest.main()
