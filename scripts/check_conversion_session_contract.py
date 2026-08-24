#!/usr/bin/env python3
"""Validate sticky conversion-session routing and async publication safeguards."""

from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SOURCE_PATH = ROOT / "apps/unitflow_app/lib/features/converter/domain/conversion_session.dart"
TEST_PATH = ROOT / "apps/unitflow_app/test/core/conversion_session_test.dart"
ERROR_BOUNDARY_TEST_PATH = (
    ROOT / "apps/unitflow_app/test/core/conversion_session_error_boundary_test.dart"
)
LATEST_SOURCE_PATH = (
    ROOT / "apps/unitflow_app/lib/features/converter/domain/latest_conversion_request.dart"
)
LATEST_TEST_PATH = ROOT / "apps/unitflow_app/test/core/latest_conversion_request_test.dart"
APP_CONTROLLER_PATH = ROOT / "apps/unitflow_app/lib/app/app_controller.dart"
APP_CONTROLLER_TEST_PATH = ROOT / "apps/unitflow_app/test/app_controller_test.dart"
CONVERTER_CONTROLLER_PATH = (
    ROOT / "apps/unitflow_app/lib/features/converter/presentation/converter_controller.dart"
)
CONVERTER_CONTROLLER_TEST_PATH = ROOT / "apps/unitflow_app/test/converter_controller_test.dart"
VALIDATOR_COMMAND = "check_conversion_session_contract.py"


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
    error_boundary_tests = read_required(
        ERROR_BOUNDARY_TEST_PATH,
        "conversion-session adapter error-boundary regression test",
        errors,
    )
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
    app_controller = read_required(
        APP_CONTROLLER_PATH,
        "application controller conversion-session integration",
        errors,
    )
    app_controller_tests = read_required(
        APP_CONTROLLER_TEST_PATH,
        "application controller conversion-session regression test",
        errors,
    )
    converter_controller = read_required(
        CONVERTER_CONTROLLER_PATH,
        "converter controller session routing",
        errors,
    )
    converter_controller_tests = read_required(
        CONVERTER_CONTROLLER_TEST_PATH,
        "converter controller native routing regression test",
        errors,
    )

    source_requirements = (
        ("static Future<ConversionSession> bootstrap", "one-shot native bridge bootstrap"),
        ("final bridge = await loadNativeBridge();", "single native bridge load attempt"),
        ("reasonCode: 'native_load_failed'", "stable native load failure reason"),
        ("factory ConversionSession.select", "one-time backend selection factory"),
        ("factory ConversionSession._fallback", "centralized fallback construction"),
        ("nativeBridge.info.validatedCopy()", "startup metadata structural revalidation"),
        ("info.requireCompatible();", "fail-closed startup compatibility check"),
        ("ConversionSessionBackend.dartFallback", "Dart fallback backend"),
        ("ConversionSessionBackend.rustNative", "Rust native backend"),
        ("final NativeConversionBridge? _nativeBridge;", "immutable selected native bridge"),
        ("final ConversionSessionBackend backend;", "immutable backend selection"),
        ("final String backendId;", "stable selected backend identifier"),
        ("final String? fallbackReasonCode;", "stable fallback reason code"),
        ("Future<void> synchronizeCustomUnits", "native custom catalog synchronization"),
        ("bridge is! NativeCatalogSyncBridge", "explicit catalog sync capability boundary"),
        ("code: 'catalog_sync_unsupported'", "stable unsupported catalog sync classification"),
        ("code: 'catalog_sync_failed'", "stable catalog sync adapter failure classification"),
        ("initialCustomUnits", "bootstrap custom catalog input"),
        ("await session.synchronizeCustomUnits(customUnits);", "fail-closed startup catalog synchronization"),
        ("request.toMap();", "request boundary validation"),
        ("_requireValidResponse(rawResponse)", "single-response structural validation"),
        ("rawResponses.map(_requireValidResponse)", "batch response structural validation"),
        ("_requireMatchingResponse(response, request);", "single-response identity validation"),
        ("responses.length != targets.length", "batch response cardinality validation"),
        ("code: 'invalid_response'", "stable invalid-response failure"),
        ("code: 'response_mismatch'", "stable response mismatch failure"),
        ("code: 'backend_failure'", "stable backend-failure classification"),
        ("on NativeBridgeFailure {\n      rethrow;", "native runtime failure propagation"),
    )
    for needle, label in source_requirements:
        require_contains(source, needle, label, errors)

    if source.count("on NativeBridgeFailure {\n      rethrow;") < 2:
        errors.append(
            "ConversionSession must propagate native failures for both single and batch routes."
        )

    if source.count("on Object {") < 4:
        errors.append(
            "ConversionSession must contain loader/startup, catalog-sync, single-route, and batch-route Error objects at native boundaries."
        )

    if source.count("_nativeBridge = nativeBridge") != 1:
        errors.append(
            "ConversionSession native bridge must be assigned only during construction."
        )

    if source.count("await loadNativeBridge()") != 1:
        errors.append("ConversionSession bootstrap must load the native bridge exactly once.")

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
        "bootstrap loads a compatible native bridge exactly once",
        "bootstrap treats a missing loaded bridge as native unavailable",
        "bootstrap load failure falls back once without later retry",
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

    error_boundary_test_requirements = (
        "startup adapter error fails closed before native selection",
        "single adapter Error is classified as backend failure",
        "batch adapter Error is classified as backend failure",
        "bootstrap synchronizes custom units before exposing native session",
        "bootstrap fails closed when selected native backend cannot sync catalog",
    )
    for name in error_boundary_test_requirements:
        require_contains(
            error_boundary_tests,
            name,
            f"adapter error-boundary regression test {name}",
            errors,
        )

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

    app_controller_requirements = (
        ("ConversionSession get conversionSession", "public active session accessor"),
        ("NativeConversionBridgeLoader _nativeBridgeLoader", "injected native bridge loader"),
        ("Future<void> _refreshConversionSession", "catalog-aware session refresh boundary"),
        ("++_sessionRefreshGeneration", "monotonic session refresh generation"),
        ("generation != _sessionRefreshGeneration", "stale session refresh suppression"),
        ("_conversionSession = ConversionSession.select(fallbackEngine: engine);", "immediate catalog-matched fallback replacement"),
        ("initialCustomUnits: state.customUnits.map", "persisted custom catalog bootstrap synchronization"),
    )
    for needle, label in app_controller_requirements:
        require_contains(app_controller, needle, label, errors)

    require_contains(
        app_controller_tests,
        "custom catalog changes start a fresh synchronized native session",
        "application-controller catalog refresh regression",
        errors,
    )

    converter_controller_requirements = (
        ("LatestConversionRequest _latestConversionRequest", "single conversion stale-result gate"),
        ("LatestConversionRequest _latestBatchRequest", "batch conversion stale-result gate"),
        ("_latestConversionRequest.invalidate();", "single request invalidation on recompute"),
        ("_latestBatchRequest.invalidate();", "batch request invalidation on recompute"),
        ("final session = _appController.conversionSession;", "active session routing"),
        ("if (session.usesNative)", "native authoritative async routing boundary"),
        ("operation: () => session.convert", "native single conversion execution"),
        ("operation: () => session.batchConvert", "native batch conversion execution"),
        ("_result = null;", "native single failure preview invalidation"),
        ("_batchResults = const <ConversionResult>[];", "native batch failure preview invalidation"),
        ("_latestConversionRequest.dispose();", "single gate lifecycle disposal"),
        ("_latestBatchRequest.dispose();", "batch gate lifecycle disposal"),
    )
    for needle, label in converter_controller_requirements:
        require_contains(converter_controller, needle, label, errors)

    require_contains(
        converter_controller_tests,
        "older native conversion completion cannot overwrite newer input",
        "controller stale-native-completion regression",
        errors,
    )

    verification_wiring = (
        ("scripts/verify.sh", "Bash verification"),
        ("scripts/verify.ps1", "PowerShell verification"),
        (".github/workflows/ci.yml", "CI workflow"),
        (".github/workflows/release.yml", "release workflow"),
        (".github/workflows/materialize-platforms.yml", "platform materialization workflow"),
        ("scripts/check_repository_hygiene.py", "repository hygiene required-file contract"),
    )
    for relative, label in verification_wiring:
        wiring_source = read_required(ROOT / relative, label, errors)
        require_contains(
            wiring_source,
            VALIDATOR_COMMAND,
            f"{label} conversion-session validator wiring",
            errors,
        )

    if errors:
        print("Conversion-session contract validation failed:", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1

    print(
        "Conversion-session contract validation passed: one-shot native loading, sticky "
        "startup routing, catalog synchronization, contained adapter Errors, structural "
        "metadata/response validation, response identity checks, batch ordering, runtime "
        "no-fallback behavior, app-owned session refresh, controller-level stale-result "
        "suppression, and verification wiring are guarded."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
