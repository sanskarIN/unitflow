import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/format/decimal_format.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('user state round-trips through backup JSON', () {
    final repository = MemoryUserStateRepository();
    final state = UserState(
      theme: ThemePreference.dark,
      notation: DecimalNotation.engineering,
      decimalPlaces: 8,
      onboardingComplete: true,
      favoriteUnitIds: <String>{'meter'},
      pinnedPairs: const <PinnedPair>[
        PinnedPair(
          category: UnitCategory.length,
          fromUnitId: 'meter',
          toUnitId: 'kilometer',
        ),
      ],
      customUnits: const <CustomUnitData>[
        CustomUnitData(
          id: 'double_meter',
          category: UnitCategory.length,
          name: 'Double Meter',
          symbol: 'dmx',
          scale: '2',
          offset: '0',
        ),
      ],
    );

    final encoded = repository.exportJson(state);
    final restored = repository.importJson(encoded);

    expect(restored.theme, ThemePreference.dark);
    expect(restored.notation, DecimalNotation.engineering);
    expect(restored.decimalPlaces, 8);
    expect(restored.favoriteUnitIds, contains('meter'));
    expect(restored.pinnedPairs.single.toUnitId, 'kilometer');
    expect(restored.customUnits.single.id, 'double_meter');
  });

  test('invalid schema version is rejected', () {
    final repository = MemoryUserStateRepository();
    expect(
      () => repository.importJson('{"schemaVersion":999}'),
      throwsFormatException,
    );
  });

  test('custom units reject built-in style formula with zero scale', () {
    const unit = CustomUnitData(
      id: 'bad_scale',
      category: UnitCategory.length,
      name: 'Bad scale',
      symbol: 'bad',
      scale: '0',
      offset: '0',
    );
    expect(unit.toUnitDefinition, throwsFormatException);
  });
}
