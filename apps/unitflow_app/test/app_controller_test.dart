import 'dart:async';

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
    expect(bridges.single.syncCalls, 1);
    expect(bridges.single.lastSnapshot, isEmpty);

    await controller.addCustomUnit(custom);
    expect(loadCalls, 2);
    expect(controller.conversionSession.usesNative, isTrue);
    expect(bridges.last.syncCalls, 1);
    expect(bridges.last.lastSnapshot.single.id, 'double_meter');

    await controller.removeCustomUnit('double_meter');
    expect(loadCalls, 3);
    expect(controller.conversionSession.usesNative, isTrue);
    expect(bridges.last.syncCalls, 1);
    expect(bridges.last.lastSnapshot, isEmpty);
  });

  test('dispose suppresses a late native-session initialization completion', () async {
    final loader = Completer<NativeConversionBridge?>();
    final controller = AppController(
      repository: MemoryUserStateRepository(UserState(onboardingComplete: true)),
      nativeBridgeLoader: () => loader.future,
    );

    final initialization = controller.initialize();
    await Future<void>.delayed(Duration.zero);
    controller.dispose();
    loader.complete(null);

    await expectLater(initialization, completes);
    expect(controller.isReady, isFalse);
  });

  test('initialize coalesces concurrent callers into one native load', () async {
    final loader = Completer<NativeConversionBridge?>();
    var loadCalls = 0;
    final controller = AppController(
      repository: MemoryUserStateRepository(UserState(onboardingComplete: true)),
      nativeBridgeLoader: () {
        loadCalls += 1;
        return loader.future;
      },
    );

    final first = controller.initialize();
    final second = controller.initialize();
    await Future<void>.delayed(Duration.zero);
    expect(loadCalls, 1);

    loader.complete(null);
    await Future.wait<void>(<Future<void>>[first, second]);
    expect(controller.isReady, isTrue);
    controller.dispose();
  });

  test('ordinary write failure is contained and later writes still run', () async {
    final repository = _FailOnceSaveRepository();
    final controller = AppController(repository: repository);
    addTearDown(controller.dispose);
    await controller.initialize();

    await expectLater(controller.setTheme(ThemePreference.dark), completes);
    expect(
      controller.warning,
      'Changes could not be saved to local storage. Please try again.',
    );

    controller.clearWarning();
    await controller.setTheme(ThemePreference.light);
    final restored = await repository.load();
    expect(restored.theme, ThemePreference.light);
    expect(controller.warning, isNull);
  });

  test('backup import persistence failure rolls back active state and propagates', () async {
    final repository = _AlwaysFailSaveRepository();
    final controller = AppController(repository: repository);
    addTearDown(controller.dispose);
    await controller.initialize();
    final payload = MemoryUserStateRepository().exportJson(
      UserState(onboardingComplete: true, theme: ThemePreference.dark),
    );

    await expectLater(controller.importState(payload), throwsStateError);
    expect(controller.state.theme, ThemePreference.system);
    expect(
      controller.warning,
      'Changes could not be saved to local storage. Please try again.',
    );
  });

  test('custom units cannot exceed the persisted and native snapshot limit', () async {
    final customUnits = List<CustomUnitData>.generate(
      UserState.maxImportedCustomUnits,
      (index) => CustomUnitData(
        id: 'custom_$index',
        category: UnitCategory.length,
        name: 'Custom $index',
        symbol: 'u$index',
        scale: '1',
        offset: '0',
      ),
      growable: false,
    );
    final repository = MemoryUserStateRepository(
      UserState(onboardingComplete: true, customUnits: customUnits),
    );
    final controller = AppController(repository: repository);
    addTearDown(controller.dispose);
    await controller.initialize();

    expect(controller.state.customUnits, hasLength(UserState.maxImportedCustomUnits));
    await expectLater(
      controller.addCustomUnit(
        const CustomUnitData(
          id: 'custom_overflow',
          category: UnitCategory.length,
          name: 'Overflow',
          symbol: 'ov',
          scale: '1',
          offset: '0',
        ),
      ),
      throwsStateError,
    );
    expect(controller.state.customUnits, hasLength(UserState.maxImportedCustomUnits));

    final roundTrip = repository.importJson(controller.exportState());
    expect(roundTrip.customUnits, hasLength(UserState.maxImportedCustomUnits));
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

final class _FailOnceSaveRepository implements UserStateRepository {
  final MemoryUserStateRepository _delegate = MemoryUserStateRepository();
  bool _shouldFail = true;

  @override
  Future<UserState> load() => _delegate.load();

  @override
  Future<void> save(UserState state) async {
    if (_shouldFail) {
      _shouldFail = false;
      throw StateError('simulated first save failure');
    }
    await _delegate.save(state);
  }

  @override
  Future<void> clear() => _delegate.clear();

  @override
  String exportJson(UserState state) => _delegate.exportJson(state);

  @override
  UserState importJson(String content) => _delegate.importJson(content);
}

final class _AlwaysFailSaveRepository implements UserStateRepository {
  final MemoryUserStateRepository _delegate = MemoryUserStateRepository();

  @override
  Future<UserState> load() => _delegate.load();

  @override
  Future<void> save(UserState state) async {
    throw StateError('simulated save failure');
  }

  @override
  Future<void> clear() => _delegate.clear();

  @override
  String exportJson(UserState state) => _delegate.exportJson(state);

  @override
  UserState importJson(String content) => _delegate.importJson(content);
}
