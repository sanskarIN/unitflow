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
