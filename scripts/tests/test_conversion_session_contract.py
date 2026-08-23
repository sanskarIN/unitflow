from __future__ import annotations

import importlib.util
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def load_validator():
    path = ROOT / "scripts/check_conversion_session_contract.py"
    spec = importlib.util.spec_from_file_location("check_conversion_session_contract", path)
    if spec is None or spec.loader is None:
        raise RuntimeError("Could not load conversion-session validator")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


validator = load_validator()


class ConversionSessionContractTests(unittest.TestCase):
    def test_current_tree_satisfies_conversion_session_contract(self) -> None:
        self.assertEqual(validator.main(), 0)

    def test_native_bridge_is_assigned_only_during_session_construction(self) -> None:
        source = validator.SOURCE_PATH.read_text(encoding="utf-8")
        self.assertEqual(source.count("_nativeBridge = nativeBridge"), 1)
        self.assertIn("final NativeConversionBridge? _nativeBridge;", source)

    def test_single_and_batch_native_failures_are_rethrown(self) -> None:
        source = validator.SOURCE_PATH.read_text(encoding="utf-8")
        self.assertGreaterEqual(
            source.count("on NativeBridgeFailure {\n      rethrow;"),
            2,
        )

    def test_regression_suite_covers_no_mid_session_fallback(self) -> None:
        tests = validator.TEST_PATH.read_text(encoding="utf-8")
        self.assertIn(
            "native runtime failure never silently changes the selected backend",
            tests,
        )
        self.assertIn("expect(fallback.convertCalls, 0);", tests)

    def test_latest_request_source_rejects_stale_generations(self) -> None:
        source = validator.LATEST_SOURCE_PATH.read_text(encoding="utf-8")
        self.assertIn("final requestGeneration = ++_generation;", source)
        self.assertGreaterEqual(source.count("requestGeneration != _generation"), 2)
        self.assertIn("void invalidate()", source)
        self.assertIn("void dispose()", source)

    def test_latest_request_tests_cover_stale_success_and_failure(self) -> None:
        tests = validator.LATEST_TEST_PATH.read_text(encoding="utf-8")
        self.assertIn("newer request prevents older success from publishing", tests)
        self.assertIn("stale failure is ignored after a newer request starts", tests)
        self.assertIn(
            "success callback failures are not relabeled as operation failures",
            tests,
        )


if __name__ == "__main__":
    unittest.main()
