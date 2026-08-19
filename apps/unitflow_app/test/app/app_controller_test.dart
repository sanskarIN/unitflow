import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  late MemoryUserStateRepository repository;
  late AppController controller;

  setUp(() async {
    repository = MemoryUserStateRepository(
      UserState(onboardingComplete: true),
    );
    controller = AppController(repository: repository);
    await controller.initialize();
  });

  tearDown(() {
    controller.dispose();
  });

  test('favorites persist through the repository', () async {
    await controller.toggleFavorite('meter');
    expect(controller.state.favoriteUnitIds, contains('meter'));

    final restored = await repository.load();
    expect(restored.favoriteUnitIds, contains('meter'));

    await controller.toggleFavorite('meter');
    expect(controller.state.favoriteUnitIds, isNot(contains('meter')));
  });

  test('pinned pair can be added and removed', () async {
    const pair = PinnedPair(
      category: UnitCategory.length,
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
    );

    await controller.togglePinnedPair(pair);
    expect(controller.isPairPinned(pair), isTrue);
    expect(
      controller.state.pinnedPairs.single.storageValue,
      'length|meter|kilometer',
    );

    await controller.togglePinnedPair(pair);
    expect(controller.isPairPinned(pair), isFalse);
    expect(controller.state.pinnedPairs, isEmpty);
  });

  test('history is bounded and can be restored', () async {
    for (var index = 0; index < 60; index++) {
      await controller.recordRecent(
        input: index.toString(),
        fromUnitId: 'meter',
        toUnitId: 'kilometer',
      );
    }

    expect(controller.state.recents, hasLength(50));
    final snapshot = controller.state.recents;

    await controller.clearHistory();
    expect(controller.state.recents, isEmpty);

    await controller.restoreHistory(snapshot);
    expect(controller.state.recents, hasLength(50));
  });

  test('conversion settings persist through the repository', () async {
    await controller.setRoundingMode(DecimalRoundingMode.ceiling);
    await controller.setDecimalPlaces(4);
    await controller.setUseGrouping(false);

    final restored = await repository.load();
    expect(restored.roundingMode, DecimalRoundingMode.ceiling);
    expect(restored.decimalPlaces, 4);
    expect(restored.useGrouping, isFalse);
  });

  test('reduced motion preference persists through the repository', () async {
    await controller.setReduceMotion(true);

    final restored = await repository.load();
    expect(controller.state.reduceMotion, isTrue);
    expect(restored.reduceMotion, isTrue);
  });

  test('valid custom unit becomes available to conversion engine', () async {
    const custom = CustomUnitData(
      id: 'double_meter',
      category: UnitCategory.length,
      name: 'Double Meter',
      symbol: 'dmx',
      scale: '2',
      offset: '0',
    );

    await controller.addCustomUnit(custom);
    final unit = controller.engine.catalog.byId('double_meter');
    expect(unit, isNotNull);
    expect(unit!.isBuiltIn, isFalse);

    await controller.removeCustomUnit('double_meter');
    expect(controller.engine.catalog.byId('double_meter'), isNull);
  });

  test('removing custom unit cleans favorites pins and history references', () async {
    const custom = CustomUnitData(
      id: 'double_meter',
      category: UnitCategory.length,
      name: 'Double Meter',
      symbol: 'dmx',
      scale: '2',
      offset: '0',
    );
    const pair = PinnedPair(
      category: UnitCategory.length,
      fromUnitId: 'meter',
      toUnitId: 'double_meter',
    );

    await controller.addCustomUnit(custom);
    await controller.toggleFavorite(custom.id);
    await controller.togglePinnedPair(pair);
    await controller.recordRecent(
      input: '5',
      fromUnitId: 'meter',
      toUnitId: custom.id,
    );

    expect(controller.state.favoriteUnitIds, contains(custom.id));
    expect(controller.state.pinnedPairs, hasLength(1));
    expect(controller.state.recents, hasLength(1));

    await controller.removeCustomUnit(custom.id);

    expect(controller.state.favoriteUnitIds, isNot(contains(custom.id)));
    expect(controller.state.pinnedPairs, isEmpty);
    expect(controller.state.recents, isEmpty);
    expect(controller.engine.catalog.byId(custom.id), isNull);
  });

  test('initialization prunes stale persisted unit references', () async {
    controller.dispose();
    repository = MemoryUserStateRepository(
      UserState(
        onboardingComplete: true,
        favoriteUnitIds: <String>{'meter', 'missing_unit'},
        pinnedPairs: const <PinnedPair>[
          PinnedPair(
            category: UnitCategory.length,
            fromUnitId: 'meter',
            toUnitId: 'kilometer',
          ),
          PinnedPair(
            category: UnitCategory.length,
            fromUnitId: 'meter',
            toUnitId: 'missing_unit',
          ),
        ],
        recents: <RecentConversion>[
          RecentConversion(
            input: '1',
            fromUnitId: 'meter',
            toUnitId: 'kilometer',
            createdAt: DateTime.utc(2026, 1, 1),
          ),
          RecentConversion(
            input: '2',
            fromUnitId: 'meter',
            toUnitId: 'missing_unit',
            createdAt: DateTime.utc(2026, 1, 2),
          ),
        ],
      ),
    );
    controller = AppController(repository: repository);

    await controller.initialize();

    expect(controller.state.favoriteUnitIds, <String>{'meter'});
    expect(controller.state.pinnedPairs, hasLength(1));
    expect(controller.state.pinnedPairs.single.toUnitId, 'kilometer');
    expect(controller.state.recents, hasLength(1));
    expect(controller.state.recents.single.toUnitId, 'kilometer');
  });

  test('custom unit cannot replace a built-in stable id', () async {
    const custom = CustomUnitData(
      id: 'meter',
      category: UnitCategory.length,
      name: 'Replacement Meter',
      symbol: 'rm',
      scale: '2',
      offset: '0',
    );

    expect(() => controller.addCustomUnit(custom), throwsArgumentError);
  });

  test('invalid import preserves current state', () async {
    await controller.toggleFavorite('meter');
    final before = controller.state;

    expect(
      () => controller.importState('{"schemaVersion":999}'),
      throwsFormatException,
    );

    expect(controller.state.favoriteUnitIds, before.favoriteUnitIds);
    expect(controller.state.onboardingComplete, before.onboardingComplete);
  });
}
