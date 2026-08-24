import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/bridge/native_conversion_bridge.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('collection cleanup actions preserve unrelated state', () async {
    final initial = UserState(
      onboardingComplete: true,
      favoriteUnitIds: <String>{'meter'},
      pinnedPairs: const <PinnedPair>[
        PinnedPair(
          category: UnitCategory.length,
          fromUnitId: 'meter',
          toUnitId: 'kilometer',
        ),
      ],
      recents: <RecentConversion>[
        RecentConversion(
          input: '12',
          fromUnitId: 'meter',
          toUnitId: 'kilometer',
          createdAt: DateTime.utc(2026, 8, 19),
        ),
      ],
    );
    final controller = AppController(
      repository: MemoryUserStateRepository(initial),
    );
    await controller.initialize();

    await controller.clearRecents();
    expect(controller.state.recents, isEmpty);
    expect(controller.state.favoriteUnitIds, contains('meter'));
    expect(controller.state.pinnedPairs, hasLength(1));

    await controller.clearFavorites();
    expect(controller.state.favoriteUnitIds, isEmpty);
    expect(controller.state.pinnedPairs, hasLength(1));

    await controller.clearPinnedPairs();
    expect(controller.state.pinnedPairs, isEmpty);
    expect(controller.state.onboardingComplete, isTrue);
  });

  test('removing a custom unit removes dangling user references', () async {
    const custom = CustomUnitData(
      id: 'double_meter',
      category: UnitCategory.length,
      name: 'Double Meter',
      symbol: 'dmx',
      scale: '2',
      offset: '0',
    );
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(
          onboardingComplete: true,
          customUnits: const <CustomUnitData>[custom],
          favoriteUnitIds: <String>{'double_meter'},
          pinnedPairs: const <PinnedPair>[
            PinnedPair(
              category: UnitCategory.length,
              fromUnitId: 'double_meter',
              toUnitId: 'meter',
            ),
          ],
          recents: <RecentConversion>[
            RecentConversion(
              input: '2',
              fromUnitId: 'double_meter',
              toUnitId: 'meter',
              createdAt: DateTime.utc(2026, 8, 19),
            ),
          ],
        ),
      ),
    );
    await controller.initialize();

    await controller.removeCustomUnit('double_meter');

    expect(controller.engine.catalog.byId('double_meter'), isNull);
    expect(controller.state.customUnits, isEmpty);
    expect(controller.state.favoriteUnitIds, isEmpty);
    expect(controller.state.pinnedPairs, isEmpty);
    expect(controller.state.recents, isEmpty);
  });

  test('custom catalog changes start a fresh synchronized native session', () async {
    const custom = CustomUnitData(
      id: 'double_meter',
      category: UnitCategory.length,
      name: 'Double Meter',
      symbol: 'dmx',
      scale: '2',
      offset: '0',
    );
    var loadCalls = 0;
    final bridges = <_CatalogSyncBridge>[];
    final controller = AppController(
      repository: MemoryUserStateRepository(UserState(onboardingComplete: true)),
      nativeBridgeLoader: () async {
        loadCalls += 1;
        final bridge = _CatalogSyncBridge();
        bridges.add(bridge);
        return bridge;
      },
    );

    await controller.initialize();
    expect(loadCalls, 1);
    expect(controller.conversionSession.usesNative, isTrue);
    expect(bridges.single.syncCalls, 0);

    await controller.addCustomUnit(custom);
    expect(loadCalls, 2);
    expect(controller.conversionSession.usesNative, isTrue);
    expect(bridges.last.syncCalls, 1);
    expect(bridges.last.lastSnapshot.single.id, 'double_meter');

    await controller.removeCustomUnit('double_meter');
    expect(loadCalls, 3);
    expect(controller.conversionSession.usesNative, isTrue);
    expect(bridges.last.syncCalls, 0);
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

final class _CatalogSyncBridge implements NativeCatalogSyncBridge {
  int syncCalls = 0;
  List<NativeBridgeCustomUnit> lastSnapshot = const <NativeBridgeCustomUnit>[];

  @override
  NativeBridgeInfo get info => _validInfo;

  @override
  Future<void> replaceCustomUnits(List<NativeBridgeCustomUnit> customUnits) async {
    syncCalls += 1;
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
