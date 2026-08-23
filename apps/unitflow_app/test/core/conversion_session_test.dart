import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/bridge/native_conversion_bridge.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/data/unit_catalog.dart';
import 'package:unitflow/features/converter/domain/conversion_engine.dart';
import 'package:unitflow/features/converter/domain/conversion_session.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('session selects deterministic fallback when native bridge is absent', () async {
    final session = ConversionSession.select();

    expect(session.backend, ConversionSessionBackend.dartFallback);
    expect(session.backendId, 'dart-fallback');
    expect(session.fallbackReasonCode, 'native_unavailable');
    expect(session.usesNative, isFalse);

    final result = await session.convert(
      value: ExactDecimal.parse('1000'),
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
    );
    expect(result.output.toCanonicalString(), '1');
  });

  test('session selects compatible Rust bridge and forwards exact request data', () async {
    final bridge = _FakeNativeBridge(
      convertHandler: (request) => NativeBridgeConversionResponse(
        input: request.value,
        output: '0.002',
        fromUnitId: request.fromUnitId,
        toUnitId: request.toUnitId,
      ),
    );
    final session = ConversionSession.select(nativeBridge: bridge);

    expect(session.backend, ConversionSessionBackend.rustNative);
    expect(session.backendId, 'rust-core');
    expect(session.fallbackReasonCode, isNull);
    expect(session.usesNative, isTrue);

    final result = await session.convert(
      value: ExactDecimal.parse('2'),
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
      decimalPlaces: 6,
      rounding: DecimalRoundingMode.halfAwayFromZero,
    );

    expect(bridge.convertCalls, 1);
    expect(bridge.lastConversionRequest?.value, '2');
    expect(bridge.lastConversionRequest?.decimalPlaces, 6);
    expect(
      bridge.lastConversionRequest?.roundMode,
      NativeBridgeRoundMode.halfAwayFromZero,
    );
    expect(result.output.toCanonicalString(), '0.002');
  });

  test('incompatible startup metadata fails closed to Dart fallback', () async {
    final bridge = _FakeNativeBridge(
      info: const NativeBridgeInfo(
        protocolVersion: 2,
        backendId: 'rust-core',
        capabilities: <String>{
          'convert',
          'batchConvert',
          'canonicalDecimalText',
        },
      ),
    );
    final session = ConversionSession.select(nativeBridge: bridge);

    expect(session.backend, ConversionSessionBackend.dartFallback);
    expect(session.fallbackReasonCode, 'protocol_mismatch');

    final result = await session.convert(
      value: ExactDecimal.parse('100'),
      fromUnitId: 'centimeter',
      toUnitId: 'meter',
    );
    expect(result.output.toCanonicalString(), '1');
    expect(bridge.convertCalls, 0);
  });

  test('direct malformed startup metadata is structurally revalidated', () async {
    final bridge = _FakeNativeBridge(
      info: const NativeBridgeInfo(
        protocolVersion: nativeBridgeProtocolVersion,
        backendId: 'Rust Core',
        capabilities: <String>{
          'convert',
          'batchConvert',
          'canonicalDecimalText',
        },
      ),
    );
    final session = ConversionSession.select(nativeBridge: bridge);

    expect(session.backend, ConversionSessionBackend.dartFallback);
    expect(session.backendId, 'dart-fallback');
    expect(session.fallbackReasonCode, 'metadata_invalid');

    final result = await session.convert(
      value: ExactDecimal.parse('1000'),
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
    );
    expect(result.output.toCanonicalString(), '1');
    expect(bridge.convertCalls, 0);
  });

  test('native runtime failure never silently changes the selected backend', () async {
    final fallback = _CountingFallbackEngine();
    final bridge = _FakeNativeBridge(throwOnConvert: true);
    final session = ConversionSession.select(
      nativeBridge: bridge,
      fallbackEngine: fallback,
    );

    await expectLater(
      session.convert(
        value: ExactDecimal.parse('1'),
        fromUnitId: 'meter',
        toUnitId: 'kilometer',
      ),
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'native_runtime_failure',
        ),
      ),
    );

    expect(session.backend, ConversionSessionBackend.rustNative);
    expect(session.usesNative, isTrue);
    expect(fallback.convertCalls, 0);
  });

  test('malformed native payload is classified as invalid response', () async {
    final fallback = _CountingFallbackEngine();
    final bridge = _FakeNativeBridge(
      convertHandler: (request) => NativeBridgeConversionResponse(
        input: request.value,
        output: '01.0',
        fromUnitId: request.fromUnitId,
        toUnitId: request.toUnitId,
      ),
    );
    final session = ConversionSession.select(
      nativeBridge: bridge,
      fallbackEngine: fallback,
    );

    await expectLater(
      session.convert(
        value: ExactDecimal.parse('1'),
        fromUnitId: 'meter',
        toUnitId: 'kilometer',
      ),
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'invalid_response',
        ),
      ),
    );

    expect(session.backend, ConversionSessionBackend.rustNative);
    expect(fallback.convertCalls, 0);
  });

  test('unexpected native exception is classified as backend failure', () async {
    final bridge = _FakeNativeBridge(
      convertHandler: (request) => throw StateError('synthetic adapter failure'),
    );
    final session = ConversionSession.select(nativeBridge: bridge);

    await expectLater(
      session.convert(
        value: ExactDecimal.parse('1'),
        fromUnitId: 'meter',
        toUnitId: 'kilometer',
      ),
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'backend_failure',
        ),
      ),
    );
  });

  test('session rejects native response metadata that does not match request', () async {
    final bridge = _FakeNativeBridge(
      convertHandler: (request) => NativeBridgeConversionResponse(
        input: request.value,
        output: '1',
        fromUnitId: request.fromUnitId,
        toUnitId: 'centimeter',
      ),
    );
    final session = ConversionSession.select(nativeBridge: bridge);

    await expectLater(
      session.convert(
        value: ExactDecimal.parse('1'),
        fromUnitId: 'meter',
        toUnitId: 'kilometer',
      ),
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'response_mismatch',
        ),
      ),
    );
  });

  test('native batch preserves target order and reconstructs typed results', () async {
    final bridge = _FakeNativeBridge(
      batchHandler: (request) => <NativeBridgeConversionResponse>[
        NativeBridgeConversionResponse(
          input: request.value,
          output: '200',
          fromUnitId: request.fromUnitId,
          toUnitId: request.targetUnitIds[0],
        ),
        NativeBridgeConversionResponse(
          input: request.value,
          output: '2000',
          fromUnitId: request.fromUnitId,
          toUnitId: request.targetUnitIds[1],
        ),
      ],
    );
    final session = ConversionSession.select(nativeBridge: bridge);

    final results = await session.batchConvert(
      value: ExactDecimal.parse('2'),
      fromUnitId: 'meter',
      toUnitIds: const <String>['centimeter', 'millimeter'],
    );

    expect(bridge.batchCalls, 1);
    expect(results.map((result) => result.to.id), <String>['centimeter', 'millimeter']);
    expect(results.map((result) => result.output.toCanonicalString()), <String>['200', '2000']);
  });

  test('native batch rejects reordered response metadata', () async {
    final bridge = _FakeNativeBridge(
      batchHandler: (request) => <NativeBridgeConversionResponse>[
        NativeBridgeConversionResponse(
          input: request.value,
          output: '2000',
          fromUnitId: request.fromUnitId,
          toUnitId: request.targetUnitIds[1],
        ),
        NativeBridgeConversionResponse(
          input: request.value,
          output: '200',
          fromUnitId: request.fromUnitId,
          toUnitId: request.targetUnitIds[0],
        ),
      ],
    );
    final session = ConversionSession.select(nativeBridge: bridge);

    await expectLater(
      session.batchConvert(
        value: ExactDecimal.parse('2'),
        fromUnitId: 'meter',
        toUnitIds: const <String>['centimeter', 'millimeter'],
      ),
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'response_mismatch',
        ),
      ),
    );
  });

  test('session enforces shared batch ceiling before invoking native bridge', () async {
    final bridge = _FakeNativeBridge();
    final session = ConversionSession.select(nativeBridge: bridge);

    await expectLater(
      session.batchConvert(
        value: ExactDecimal.parse('1'),
        fromUnitId: 'meter',
        toUnitIds: List<String>.filled(maxBatchConversionTargets + 1, 'centimeter'),
      ),
      throwsA(isA<ConversionFailure>()),
    );
    expect(bridge.batchCalls, 0);
  });
}

final class _FakeNativeBridge implements NativeConversionBridge {
  _FakeNativeBridge({
    this.info = const NativeBridgeInfo(
      protocolVersion: nativeBridgeProtocolVersion,
      backendId: 'rust-core',
      capabilities: <String>{
        'convert',
        'batchConvert',
        'canonicalDecimalText',
      },
    ),
    this.convertHandler,
    this.batchHandler,
    this.throwOnConvert = false,
  });

  @override
  final NativeBridgeInfo info;
  final NativeBridgeConversionResponse Function(NativeBridgeConversionRequest request)?
  convertHandler;
  final List<NativeBridgeConversionResponse> Function(
    NativeBridgeBatchConversionRequest request,
  )?
  batchHandler;
  final bool throwOnConvert;

  int convertCalls = 0;
  int batchCalls = 0;
  NativeBridgeConversionRequest? lastConversionRequest;

  @override
  Future<NativeBridgeConversionResponse> convert(
    NativeBridgeConversionRequest request,
  ) async {
    convertCalls += 1;
    lastConversionRequest = request;
    if (throwOnConvert) {
      throw const NativeBridgeFailure(
        code: 'native_runtime_failure',
        message: 'Synthetic native runtime failure.',
      );
    }
    final handler = convertHandler;
    return handler?.call(request) ??
        NativeBridgeConversionResponse(
          input: request.value,
          output: request.value,
          fromUnitId: request.fromUnitId,
          toUnitId: request.toUnitId,
        );
  }

  @override
  Future<List<NativeBridgeConversionResponse>> batchConvert(
    NativeBridgeBatchConversionRequest request,
  ) async {
    batchCalls += 1;
    final handler = batchHandler;
    if (handler != null) {
      return handler(request);
    }
    return request.targetUnitIds
        .map(
          (target) => NativeBridgeConversionResponse(
            input: request.value,
            output: request.value,
            fromUnitId: request.fromUnitId,
            toUnitId: target,
          ),
        )
        .toList(growable: false);
  }
}

final class _CountingFallbackEngine implements ConversionEngine {
  _CountingFallbackEngine() : _delegate = ExactConversionEngine();

  final ExactConversionEngine _delegate;
  int convertCalls = 0;
  int batchCalls = 0;

  @override
  UnitCatalog get catalog => _delegate.catalog;

  @override
  ConversionResult convert({
    required ExactDecimal value,
    required String fromUnitId,
    required String toUnitId,
    int decimalPlaces = 12,
    DecimalRoundingMode rounding = DecimalRoundingMode.nearestEven,
  }) {
    convertCalls += 1;
    return _delegate.convert(
      value: value,
      fromUnitId: fromUnitId,
      toUnitId: toUnitId,
      decimalPlaces: decimalPlaces,
      rounding: rounding,
    );
  }

  @override
  List<ConversionResult> batchConvert({
    required ExactDecimal value,
    required String fromUnitId,
    required Iterable<String> toUnitIds,
    int decimalPlaces = 12,
    DecimalRoundingMode rounding = DecimalRoundingMode.nearestEven,
  }) {
    batchCalls += 1;
    return _delegate.batchConvert(
      value: value,
      fromUnitId: fromUnitId,
      toUnitIds: toUnitIds,
      decimalPlaces: decimalPlaces,
      rounding: rounding,
    );
  }
}
