import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('custom unit undo restores favorite pin history and conversion use', () async {
    final repository = MemoryUserStateRepository(
      UserState(onboardingComplete: true),
    );
    final controller = AppController(repository: repository);
    addTearDown(controller.dispose);
    await controller.initialize();

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
      input: '4',
      fromUnitId: 'meter',
      toUnitId: custom.id,
    );

    final snapshot = await controller.removeCustomUnit(custom.id);
    expect(snapshot, isNotNull);
    expect(controller.engine.catalog.byId(custom.id), isNull);
    expect(controller.state.favoriteUnitIds, isNot(contains(custom.id)));
    expect(controller.state.pinnedPairs, isEmpty);
    expect(controller.state.recents, isEmpty);

    await controller.restoreCustomUnit(snapshot!);

    expect(controller.engine.catalog.byId(custom.id), isNotNull);
    expect(controller.state.favoriteUnitIds, contains(custom.id));
    expect(controller.state.pinnedPairs.single.storageValue, pair.storageValue);
    expect(controller.state.recents.single.toUnitId, custom.id);

    final result = controller.engine.convert(
      value: ExactDecimal.parse('4'),
      fromUnitId: 'meter',
      toUnitId: custom.id,
      decimalPlaces: 12,
    );
    expect(result.output.toString(), '2');
  });
}
