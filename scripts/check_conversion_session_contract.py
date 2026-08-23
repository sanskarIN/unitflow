#!/usr/bin/env python3
"""Validate sticky conversion-session routing and async publication safeguards."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "apps/unitflow_app/lib/features/converter/domain/conversion_session.dart"
TEST_PATH = ROOT / "apps/unitflow_app/test/core/conversion_session_test.dart"
LATEST_SOURCE_PATH = (
    ROOT / "apps/unitflow_app/lib/features/converter/domain/latest_conversion_request.dart"
)
LATEST_TEST_PATH = ROOT / "apps/unitflow_app/test/core/latest_conversion_request_test.dart"


def require_contains(source: str, needle: str, label: str, errors: list[str]) -> None:
    if needle not in source:
        errors.append(f"Missing {label}: {needle!r}")


def read_required(path: Path, label: str, errors: list[str]) -> str:
    if not path.is_file():
        errors.append(f"Missing {label}: {path.relative_to(ROOT)}")
        return ""
    return path.read_text(encoding="utf-8")


def main() -> int:
    errors: list[str] = []
    source = read_required(SOURCE_PATH, "conversion-session source", errors)
    tests = read_required(TEST_PATH, "conversion-session regression test", errors)
    latest_source = read_required(
        LATEST_SOURCE_PATH,
        "latest-conversion request source",
        errors,
    )
    latest_tests = read_required(
        LATEST_TEST_PATH,
        "latest-conversion request regression test",
        errors,
    )

    source_requirements = (
        ("factory ConversionSession.select", "one-time backend selection factory"),
        ("nativeBridge.info.validatedCopy()", "startup metadata structural revalidation"),
        ("info.requireCompatible();", "fail-closed startup compatibility check"),
        ("ConversionSessionBackend.dartFallback", "Dart fallback backend"),
        ("ConversionSessionBackend.rustNative", "Rust native backend"),
        ("final NativeConversionBridge? _nativeBridge;", "immutable selected native bridge"),
        ("final ConversionSessionBackend backend;", "immutable backend selection"),
        ("final String backendId;", "stable selected backend identifier"),
        ("final String? fallbackReasonCode;", "stable fallback reason code"),
        ("request.toMap();", "request boundary validation"),
        ("_requireValidResponse(rawResponse)", "single-response structural validation"),
        ("rawResponses.map(_requireValidResponse)", "batch response structural validation"),
        ("_requireMatchingResponse(response, request);", "single-response identity validation"),
        ("responses.length != targets.length", "batch response cardinality validation"),
        ("code: 'invalid_response'", "stable invalid-response failure"),
        ("code: 'response_mismatch'", "stable response mismatch failure"),
        ("on NativeBridgeFailure {\n      rethrow;", "native runtime failure propagation"),
    )
    for needle, label in source_requirements:
        require_contains(source, needle, label, errors)

    if source.count("on NativeBridgeFailure {\n      rethrow;") < 2:
        errors.append(
            "ConversionSession must propagate native failures for both single and batch routes."
        )

    if source.count("_nativeBridge = nativeBridge") != 1:
        errors.append(
            "ConversionSession native bridge must be assigned only during construction."
        )

    for mode in (
        "nearestEven",
        "halfAwayFromZero",
        "towardZero",
        "awayFromZero",
        "floor",
        "ceiling",
    ):
        require_contains(
            source,
            f"DecimalRoundingMode.{mode} => NativeBridgeRoundMode.{mode}",
            f"rounding-mode mapping for {mode}",
            errors,
        )

    test_requirements = (
        "session selects deterministic fallback when native bridge is absent",
        "session selects compatible Rust bridge and forwards exact request data",
        "incompatible startup metadata fails closed to Dart fallback",
        "direct malformed startup metadata is structurally revalidated",
        "native runtime failure never silently changes the selected backend",
        "malformed native payload is classified as invalid response",
        "unexpected native exception is classified as backend failure",
        "session rejects native response metadata that does not match request",
        "native batch preserves target order and reconstructs typed results",
        "native batch rejects reordered response metadata",
        "session enforces shared batch ceiling before invoking native bridge",
    )
    for name in test_requirements:
        require_contains(tests, name, f"regression test {name}", errors)

    latest_source_requirements = (
        ("final class LatestConversionRequest", "latest-request coordinator"),
        ("final requestGeneration = ++_generation;", "monotonic request generation"),
        ("requestGeneration != _generation", "stale request rejection"),
        ("void invalidate()", "explicit in-flight invalidation"),
        ("void dispose()", "lifecycle invalidation"),
        ("if (_disposed)", "disposed-state guard"),
        ("onFailure(error, stackTrace);\n      return;", "operation failure publication boundary"),
        ("onSuccess(value);", "success publication boundary"),
    )
    for needle, label in latest_source_requirements:
        require_contains(latest_source, needle, label, errors)

    latest_test_requirements = (
        "newer request prevents older success from publishing",
        "stale failure is ignored after a newer request starts",
        "current failure is delivered with its stack trace",
        "success callback failures are not relabeled as operation failures",
        "failure callback exceptions propagate to the caller",
        "invalidate drops an in-flight result without disposing coordinator",
        "dispose drops pending work and rejects future requests",
        "generation increases monotonically for request and invalidation events",
    )
    for name in latest_test_requirements:
        require_contains(
            latest_tests,
            name,
            f"latest-request regression test {name}",
            errors,
        )

    if errors:
        print("Conversion-session contract validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        "Conversion-session contract validation passed: sticky startup routing, "
        "structural metadata/response validation, fail-closed negotiation, response "
        "identity checks, batch ordering, runtime no-fallback behavior, and latest-request "
        "race suppression are guarded."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
