import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/format/decimal_format.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  late MemoryUserStateRepository repository;
  late AppController controller;

  setUp(() async {
    repository = MemoryUserStateRepository();
    controller = AppController(repository: repository);
    await controller.initialize();
  });

  tearDown(() {
    controller.dispose();
  });

  test('initializes from repository and becomes ready', () {
    expect(controller.isReady, isTrue);
    expect(controller.warning, isNull);
    expect(controller.engine.catalog.byId('meter'), isNotNull);
  });

  test('persists display settings', () async {
    await controller.setTheme(ThemePreference.dark);
    await controller.setNotation(DecimalNotation.engineering);
    await controller.setDecimalPlaces(5);
    await controller.setUseGrouping(false);

    final UserState loaded = await repository.load();
    expect(loaded.theme, ThemePreference.dark);
    expect(loaded.notation, DecimalNotation.engineering);
    expect(loaded.decimalPlaces, 5);
    expect(loaded.useGrouping, isFalse);
  });

  test('toggles favorites and pinned pairs', () async {
    const PinnedPair pair = PinnedPair(
      category: UnitCategory.length,
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
    );

    await controller.toggleFavorite('meter');
    await controller.togglePinnedPair(pair);

    expect(controller.state.favoriteUnitIds, contains('meter'));
    expect(controller.isPairPinned(pair), isTrue);

    await controller.toggleFavorite('meter');
    await controller.togglePinnedPair(pair);

    expect(controller.state.favoriteUnitIds, isNot(contains('meter')));
    expect(controller.isPairPinned(pair), isFalse);
  });

  test('records recent conversions without duplicate leading entries', () async {
    await controller.recordRecent(
      input: '1',
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
    );
    await controller.recordRecent(
      input: '1',
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
    );

    expect(controller.state.recents, hasLength(1));
  });

  test('adding and removing a custom unit rebuilds the catalog safely', () async {
    const CustomUnitData custom = CustomUnitData(
      id: 'double_meter',
      category: UnitCategory.length,
      name: 'Double meter',
      symbol: 'dm2',
      scale: '2',
      offset: '0',
    );

    await controller.addCustomUnit(custom);
    expect(controller.engine.catalog.byId('double_meter'), isNotNull);

    await controller.removeCustomUnit('double_meter');
    expect(controller.engine.catalog.byId('double_meter'), isNull);
  });

  test('import and export round-trip controller state', () async {
    await controller.setTheme(ThemePreference.dark);
    await controller.setDecimalPlaces(7);
    final String exported = controller.exportState();

    await controller.resetLocalData();
    expect(controller.state.theme, ThemePreference.system);

    await controller.importState(exported);
    expect(controller.state.theme, ThemePreference.dark);
    expect(controller.state.decimalPlaces, 7);
  });
}
