import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('controller rejects custom units beyond the portable backup limit', () async {
    final initialUnits = List<CustomUnitData>.generate(
      UserState.maxCustomUnits,
      (index) => CustomUnitData(
        id: 'custom_$index',
        category: UnitCategory.length,
        name: 'Custom $index',
        symbol: 'c$index',
        scale: '${index + 1}',
        offset: '0',
      ),
    );
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(
          onboardingComplete: true,
          customUnits: initialUnits,
        ),
      ),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    const overflow = CustomUnitData(
      id: 'overflow_unit',
      category: UnitCategory.length,
      name: 'Overflow Unit',
      symbol: 'overflow',
      scale: '1',
      offset: '0',
    );

    expect(() => controller.addCustomUnit(overflow), throwsStateError);
    expect(controller.state.customUnits, hasLength(UserState.maxCustomUnits));
  });

  test('controller persists normalized custom unit text', () async {
    final repository = MemoryUserStateRepository(
      UserState(onboardingComplete: true),
    );
    final controller = AppController(repository: repository);
    addTearDown(controller.dispose);
    await controller.initialize();

    const input = CustomUnitData(
      id: 'double_meter',
      category: UnitCategory.length,
      name: ' Double Meter ',
      symbol: ' dmx ',
      scale: '2.00',
      offset: '0.00',
      aliases: <String>[' double ', 'DOUBLE', 'two meters'],
      description: ' Example unit. ',
    );

    await controller.addCustomUnit(input);
    final persisted = (await repository.load()).customUnits.single;

    expect(persisted.name, 'Double Meter');
    expect(persisted.symbol, 'dmx');
    expect(persisted.scale, '2');
    expect(persisted.offset, '0');
    expect(persisted.aliases, <String>['double', 'two meters']);
    expect(persisted.description, 'Example unit.');
  });
}
