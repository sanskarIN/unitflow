import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/bridge/native_conversion_bridge.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/domain/conversion_session.dart';

void main() {
  test('startup adapter error fails closed before native selection', () {
    final session = ConversionSession.select(nativeBridge: _ThrowingInfoBridge());

    expect(session.usesNative, isFalse);
    expect(session.backendId, 'dart-fallback');
    expect(session.fallbackReasonCode, 'startup_failed');
  });

  test('single adapter Error is classified as backend failure', () async {
    final session = ConversionSession.select(
      nativeBridge: _ThrowingRuntimeBridge(throwInBatch: false),
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
          'backend_failure',
        ),
      ),
    );
    expect(session.usesNative, isTrue);
  });

  test('batch adapter Error is classified as backend failure', () async {
    final session = ConversionSession.select(
      nativeBridge: _ThrowingRuntimeBridge(throwInBatch: true),
    );

    await expectLater(
      session.batchConvert(
        value: ExactDecimal.parse('1'),
        fromUnitId: 'meter',
        toUnitIds: const <String>['kilometer'],
      ),
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'backend_failure',
        ),
      ),
    );
    expect(session.usesNative, isTrue);
  });
}

const _validInfo = NativeBridgeInfo(
  protocolVersion: nativeBridgeProtocolVersion,
  backendId: 'rust-core',
  capabilities: <String>{
    nativeBridgeCapabilityConvert,
    nativeBridgeCapabilityBatchConvert,
    nativeBridgeCapabilityCanonicalDecimalText,
  },
);

final class _ThrowingInfoBridge implements NativeConversionBridge {
  @override
  NativeBridgeInfo get info => throw StateError('synthetic startup adapter error');

  @override
  Future<NativeBridgeConversionResponse> convert(
    NativeBridgeConversionRequest request,
  ) => throw UnsupportedError('not selected');

  @override
  Future<List<NativeBridgeConversionResponse>> batchConvert(
    NativeBridgeBatchConversionRequest request,
  ) => throw UnsupportedError('not selected');
}

final class _ThrowingRuntimeBridge implements NativeConversionBridge {
  const _ThrowingRuntimeBridge({required this.throwInBatch});

  final bool throwInBatch;

  @override
  NativeBridgeInfo get info => _validInfo;

  @override
  Future<NativeBridgeConversionResponse> convert(
    NativeBridgeConversionRequest request,
  ) {
    if (!throwInBatch) {
      throw StateError('synthetic single adapter error');
    }
    throw UnsupportedError('single path not used');
  }

  @override
  Future<List<NativeBridgeConversionResponse>> batchConvert(
    NativeBridgeBatchConversionRequest request,
  ) {
    if (throwInBatch) {
      throw StateError('synthetic batch adapter error');
    }
    throw UnsupportedError('batch path not used');
  }
}
