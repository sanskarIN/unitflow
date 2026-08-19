import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('custom multiplicative unit participates in exact conversion', () async {
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );
    await controller.initialize();

    await controller.addCustomUnit(
      const CustomUnitData(
        id: 'double_meter',
        category: UnitCategory.length,
        name: 'Double Meter',
        symbol: 'dmx',
        scale: '2',
        offset: '0',
      ),
    );

    final result = controller.engine.convert(
      value: ExactDecimal.parse('3'),
      fromUnitId: 'double_meter',
      toUnitId: 'meter',
      decimalPlaces: 12,
    );

    expect(result.output, ExactDecimal.parse('6'));
  });

  test('custom affine unit applies scale and offset through base unit', () async {
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );
    await controller.initialize();

    await controller.addCustomUnit(
      const CustomUnitData(
        id: 'shifted_meter',
        category: UnitCategory.length,
        name: 'Shifted Meter',
        symbol: 'smx',
        scale: '2',
        offset: '10',
      ),
    );

    final result = controller.engine.convert(
      value: ExactDecimal.parse('4'),
      fromUnitId: 'shifted_meter',
      toUnitId: 'meter',
      decimalPlaces: 12,
    );

    expect(result.output, ExactDecimal.parse('18'));
  });

  test('custom unit cannot shadow a built-in stable identifier', () async {
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );
    await controller.initialize();

    expect(
      () => controller.addCustomUnit(
        const CustomUnitData(
          id: 'meter',
          category: UnitCategory.length,
          name: 'Shadow Meter',
          symbol: 'shadow',
          scale: '1',
          offset: '0',
        ),
      ),
      throwsArgumentError,
    );
  });

  test('backup restore rebuilds the custom-unit catalog before use', () async {
    final source = AppController(repository: MemoryUserStateRepository());
    await source.initialize();
    await source.addCustomUnit(
      const CustomUnitData(
        id: 'triple_meter',
        category: UnitCategory.length,
        name: 'Triple Meter',
        symbol: 'tmx',
        scale: '3',
        offset: '0',
      ),
    );
    final backup = source.exportState();

    final restored = AppController(repository: MemoryUserStateRepository());
    await restored.initialize();
    await restored.importState(backup);

    final result = restored.engine.convert(
      value: ExactDecimal.parse('2'),
      fromUnitId: 'triple_meter',
      toUnitId: 'meter',
      decimalPlaces: 12,
    );
    expect(result.output, ExactDecimal.parse('6'));
  });
}
