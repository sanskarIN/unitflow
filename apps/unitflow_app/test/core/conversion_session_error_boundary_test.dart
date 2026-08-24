import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/bridge/native_conversion_bridge.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/domain/conversion_session.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

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

  test('fallback session accepts catalog synchronization as a no-op', () async {
    final session = ConversionSession.select();

    await session.synchronizeCustomUnits(<UnitDefinition>[_doubleMeter]);
    expect(session.usesNative, isFalse);
    expect(session.supportsCatalogSync, isFalse);
  });

  test('native session fails explicitly when catalog sync is unsupported', () async {
    final session = ConversionSession.select(
      nativeBridge: _ThrowingRuntimeBridge(throwInBatch: false),
    );

    await expectLater(
      session.synchronizeCustomUnits(<UnitDefinition>[_doubleMeter]),
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'catalog_sync_unsupported',
        ),
      ),
    );
    expect(session.usesNative, isTrue);
  });

  test('catalog sync canonicalizes validated custom-unit decimals', () async {
    final bridge = _CatalogSyncBridge();
    final session = ConversionSession.select(nativeBridge: bridge);

    await session.synchronizeCustomUnits(<UnitDefinition>[_doubleMeter]);

    expect(session.supportsCatalogSync, isTrue);
    expect(bridge.syncCalls, 1);
    expect(bridge.lastSnapshot, hasLength(1));
    final encoded = bridge.lastSnapshot.single.toMap();
    expect(encoded['id'], 'double_meter');
    expect(encoded['category'], 'length');
    expect(encoded['scale'], '2');
    expect(encoded['offset'], '0');
  });

  test('catalog sync adapter Error is classified without changing backend', () async {
    final bridge = _CatalogSyncBridge(throwOnSync: true);
    final session = ConversionSession.select(nativeBridge: bridge);

    await expectLater(
      session.synchronizeCustomUnits(<UnitDefinition>[_doubleMeter]),
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'catalog_sync_failed',
        ),
      ),
    );
    expect(session.usesNative, isTrue);
  });

  test('catalog sync rejects built-in definitions before adapter invocation', () async {
    final bridge = _CatalogSyncBridge();
    final session = ConversionSession.select(nativeBridge: bridge);
    final builtIn = UnitDefinition(
      id: 'synthetic_builtin',
      category: UnitCategory.length,
      name: 'Synthetic built in',
      symbol: 'sb',
      scale: ExactDecimal.one,
    );

    await expectLater(
      session.synchronizeCustomUnits(<UnitDefinition>[builtIn]),
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'invalid_catalog_snapshot',
        ),
      ),
    );
    expect(bridge.syncCalls, 0);
  });
}

final _doubleMeter = UnitDefinition(
  id: 'double_meter',
  category: UnitCategory.length,
  name: 'Double meter',
  symbol: 'dm2',
  scale: ExactDecimal.parse('2.0'),
  offset: ExactDecimal.zero,
  aliases: const <String>['double metre'],
  description: 'Synthetic test unit.',
  isBuiltIn: false,
);

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

final class _CatalogSyncBridge implements NativeCatalogSyncBridge {
  _CatalogSyncBridge({this.throwOnSync = false});

  final bool throwOnSync;
  int syncCalls = 0;
  List<NativeBridgeCustomUnit> lastSnapshot = const <NativeBridgeCustomUnit>[];

  @override
  NativeBridgeInfo get info => _validInfo;

  @override
  Future<void> replaceCustomUnits(List<NativeBridgeCustomUnit> customUnits) async {
    syncCalls += 1;
    if (throwOnSync) {
      throw StateError('synthetic catalog adapter error');
    }
    lastSnapshot = List<NativeBridgeCustomUnit>.unmodifiable(customUnits);
  }

  @override
  Future<NativeBridgeConversionResponse> convert(
    NativeBridgeConversionRequest request,
  ) async => NativeBridgeConversionResponse(
    input: request.value,
    output: request.value,
    fromUnitId: request.fromUnitId,
    toUnitId: request.toUnitId,
  );

  @override
  Future<List<NativeBridgeConversionResponse>> batchConvert(
    NativeBridgeBatchConversionRequest request,
  ) async => request.targetUnitIds
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
