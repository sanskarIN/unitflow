import '../../../core/bridge/native_conversion_bridge.dart';
import '../../../core/math/exact_decimal.dart';
import 'conversion_engine.dart';
import 'unit_models.dart';

/// Backend selected once for a conversion session.
enum ConversionSessionBackend { dartFallback, rustNative }

/// Sticky runtime conversion router.
///
/// Native compatibility is evaluated exactly once in [select]. If Rust is not
/// available or its startup contract is incompatible, the session uses the
/// deterministic Dart engine. Once Rust is selected, runtime native failures
/// are surfaced and never trigger a silent mid-session fallback.
final class ConversionSession {
  ConversionSession._({
    required ConversionEngine fallbackEngine,
    required NativeConversionBridge? nativeBridge,
    required this.backend,
    required this.backendId,
    required this.fallbackReasonCode,
  }) : _fallbackEngine = fallbackEngine,
       _nativeBridge = nativeBridge;

  factory ConversionSession.select({
    NativeConversionBridge? nativeBridge,
    ConversionEngine? fallbackEngine,
  }) {
    final fallback = fallbackEngine ?? ExactConversionEngine();
    if (nativeBridge == null) {
      return ConversionSession._(
        fallbackEngine: fallback,
        nativeBridge: null,
        backend: ConversionSessionBackend.dartFallback,
        backendId: 'dart-fallback',
        fallbackReasonCode: 'native_unavailable',
      );
    }

    try {
      final info = nativeBridge.info.validatedCopy();
      info.requireCompatible();
      return ConversionSession._(
        fallbackEngine: fallback,
        nativeBridge: nativeBridge,
        backend: ConversionSessionBackend.rustNative,
        backendId: info.backendId,
        fallbackReasonCode: null,
      );
    } on NativeBridgeFailure catch (failure) {
      return ConversionSession._(
        fallbackEngine: fallback,
        nativeBridge: null,
        backend: ConversionSessionBackend.dartFallback,
        backendId: 'dart-fallback',
        fallbackReasonCode: failure.code,
      );
    } on FormatException {
      return ConversionSession._(
        fallbackEngine: fallback,
        nativeBridge: null,
        backend: ConversionSessionBackend.dartFallback,
        backendId: 'dart-fallback',
        fallbackReasonCode: 'metadata_invalid',
      );
    } on Exception {
      return ConversionSession._(
        fallbackEngine: fallback,
        nativeBridge: null,
        backend: ConversionSessionBackend.dartFallback,
        backendId: 'dart-fallback',
        fallbackReasonCode: 'startup_failed',
      );
    }
  }

  final ConversionEngine _fallbackEngine;
  final NativeConversionBridge? _nativeBridge;

  final ConversionSessionBackend backend;
  final String backendId;
  final String? fallbackReasonCode;

  bool get usesNative => backend == ConversionSessionBackend.rustNative;

  Future<ConversionResult> convert({
    required ExactDecimal value,
    required String fromUnitId,
    required String toUnitId,
    int decimalPlaces = 12,
    DecimalRoundingMode rounding = DecimalRoundingMode.nearestEven,
  }) async {
    final bridge = _nativeBridge;
    if (bridge == null) {
      return _fallbackEngine.convert(
        value: value,
        fromUnitId: fromUnitId,
        toUnitId: toUnitId,
        decimalPlaces: decimalPlaces,
        rounding: rounding,
      );
    }

    final pair = _resolvePair(fromUnitId, toUnitId);
    _validateDecimalPlaces(decimalPlaces);
    final request = NativeBridgeConversionRequest(
      value: value.toCanonicalString(),
      fromUnitId: fromUnitId,
      toUnitId: toUnitId,
      decimalPlaces: decimalPlaces,
      roundMode: _nativeRoundMode(rounding),
    );
    request.toMap();

    final NativeBridgeConversionResponse rawResponse;
    try {
      rawResponse = await bridge.convert(request);
    } on NativeBridgeFailure {
      rethrow;
    } on Exception {
      throw const NativeBridgeFailure(
        code: 'backend_failure',
        message: 'The native conversion backend failed during conversion.',
      );
    }

    final response = _requireValidResponse(rawResponse);
    _requireMatchingResponse(response, request);
    return ConversionResult(
      input: ExactDecimal.parse(response.input),
      output: ExactDecimal.parse(response.output),
      from: pair.$1,
      to: pair.$2,
    );
  }

  Future<List<ConversionResult>> batchConvert({
    required ExactDecimal value,
    required String fromUnitId,
    required Iterable<String> toUnitIds,
    int decimalPlaces = 12,
    DecimalRoundingMode rounding = DecimalRoundingMode.nearestEven,
  }) async {
    final targets = toUnitIds.take(maxBatchConversionTargets + 1).toList(growable: false);
    if (targets.length > maxBatchConversionTargets) {
      throw const ConversionFailure('Batch conversion supports at most 256 target units.');
    }

    final bridge = _nativeBridge;
    if (bridge == null) {
      return _fallbackEngine.batchConvert(
        value: value,
        fromUnitId: fromUnitId,
        toUnitIds: targets,
        decimalPlaces: decimalPlaces,
        rounding: rounding,
      );
    }

    _validateDecimalPlaces(decimalPlaces);
    final pairs = targets.map((target) => _resolvePair(fromUnitId, target)).toList(growable: false);
    final request = NativeBridgeBatchConversionRequest(
      value: value.toCanonicalString(),
      fromUnitId: fromUnitId,
      targetUnitIds: targets,
      decimalPlaces: decimalPlaces,
      roundMode: _nativeRoundMode(rounding),
    );
    request.toMap();

    final List<NativeBridgeConversionResponse> rawResponses;
    try {
      rawResponses = await bridge.batchConvert(request);
    } on NativeBridgeFailure {
      rethrow;
    } on Exception {
      throw const NativeBridgeFailure(
        code: 'backend_failure',
        message: 'The native conversion backend failed during batch conversion.',
      );
    }

    final responses = rawResponses.map(_requireValidResponse).toList(growable: false);
    if (responses.length != targets.length) {
      throw const NativeBridgeFailure(
        code: 'response_mismatch',
        message: 'The native conversion backend returned an unexpected batch size.',
      );
    }

    return List<ConversionResult>.generate(responses.length, (index) {
      final response = responses[index];
      _requireMatchingResponse(
        response,
        NativeBridgeConversionRequest(
          value: request.value,
          fromUnitId: request.fromUnitId,
          toUnitId: targets[index],
          decimalPlaces: request.decimalPlaces,
          roundMode: request.roundMode,
        ),
      );
      return ConversionResult(
        input: ExactDecimal.parse(response.input),
        output: ExactDecimal.parse(response.output),
        from: pairs[index].$1,
        to: pairs[index].$2,
      );
    }, growable: false);
  }

  (UnitDefinition, UnitDefinition) _resolvePair(String fromUnitId, String toUnitId) {
    final from = _fallbackEngine.catalog.byId(fromUnitId);
    final to = _fallbackEngine.catalog.byId(toUnitId);
    if (from == null) {
      throw ConversionFailure('Unknown source unit: $fromUnitId');
    }
    if (to == null) {
      throw ConversionFailure('Unknown target unit: $toUnitId');
    }
    if (from.category != to.category) {
      throw ConversionFailure('Units must belong to the same category.');
    }
    return (from, to);
  }
}

NativeBridgeConversionResponse _requireValidResponse(
  NativeBridgeConversionResponse response,
) {
  try {
    return NativeBridgeConversionResponse.fromMap(<String, Object?>{
      'input': response.input,
      'output': response.output,
      'fromUnitId': response.fromUnitId,
      'toUnitId': response.toUnitId,
    });
  } on FormatException {
    throw const NativeBridgeFailure(
      code: 'invalid_response',
      message: 'The native conversion backend returned an invalid response.',
    );
  }
}

void _requireMatchingResponse(
  NativeBridgeConversionResponse response,
  NativeBridgeConversionRequest request,
) {
  if (response.input != request.value ||
      response.fromUnitId != request.fromUnitId ||
      response.toUnitId != request.toUnitId) {
    throw const NativeBridgeFailure(
      code: 'response_mismatch',
      message: 'The native conversion backend returned mismatched conversion metadata.',
    );
  }
}

NativeBridgeRoundMode _nativeRoundMode(DecimalRoundingMode mode) => switch (mode) {
  DecimalRoundingMode.nearestEven => NativeBridgeRoundMode.nearestEven,
  DecimalRoundingMode.halfAwayFromZero => NativeBridgeRoundMode.halfAwayFromZero,
  DecimalRoundingMode.towardZero => NativeBridgeRoundMode.towardZero,
  DecimalRoundingMode.awayFromZero => NativeBridgeRoundMode.awayFromZero,
  DecimalRoundingMode.floor => NativeBridgeRoundMode.floor,
  DecimalRoundingMode.ceiling => NativeBridgeRoundMode.ceiling,
};

void _validateDecimalPlaces(int decimalPlaces) {
  if (decimalPlaces < 0 || decimalPlaces > 28) {
    throw const ConversionFailure('Decimal places must be between 0 and 28.');
  }
}
