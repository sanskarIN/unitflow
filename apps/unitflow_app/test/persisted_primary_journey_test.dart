import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/format/decimal_format.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('primary state survives controller restart and remains usable', () async {
    final repository = MemoryUserStateRepository();
    final first = AppController(repository: repository);
    await first.initialize();

    await first.setTheme(ThemePreference.dark);
    await first.setNotation(DecimalNotation.engineering);
    await first.setRoundingMode(DecimalRoundingMode.halfAwayFromZero);
    await first.setDecimalPlaces(6);
    await first.setUseGrouping(false);
    await first.completeOnboarding();
    await first.toggleFavorite('meter');
    await first.togglePinnedPair(
      const PinnedPair(
        category: UnitCategory.length,
        fromUnitId: 'meter',
        toUnitId: 'centimeter',
      ),
    );
    await first.recordRecent(
      input: '12.5',
      fromUnitId: 'meter',
      toUnitId: 'centimeter',
    );
    await first.addCustomUnit(
      const CustomUnitData(
        id: 'double_meter',
        category: UnitCategory.length,
        name: 'Double Meter',
        symbol: 'dmx',
        scale: '2',
        offset: '0',
        aliases: <String>['double metre'],
        description: 'Two meters per custom unit.',
      ),
    );
    await first.toggleFavorite('double_meter');

    final restarted = AppController(repository: repository);
    await restarted.initialize();

    expect(restarted.state.theme, ThemePreference.dark);
    expect(restarted.state.notation, DecimalNotation.engineering);
    expect(
      restarted.state.roundingMode,
      DecimalRoundingMode.halfAwayFromZero,
    );
    expect(restarted.state.decimalPlaces, 6);
    expect(restarted.state.useGrouping, isFalse);
    expect(restarted.state.onboardingComplete, isTrue);
    expect(
      restarted.state.favoriteUnitIds,
      containsAll(<String>['meter', 'double_meter']),
    );
    expect(restarted.state.pinnedPairs, hasLength(1));
    expect(restarted.state.recents, hasLength(1));
    expect(restarted.state.recents.single.input, '12.5');
    expect(restarted.state.customUnits, hasLength(1));
    expect(restarted.engine.catalog.byId('double_meter'), isNotNull);

    final result = restarted.engine.convert(
      value: ExactDecimal.parse('3'),
      fromUnitId: 'double_meter',
      toUnitId: 'meter',
      decimalPlaces: restarted.state.decimalPlaces,
      rounding: restarted.state.roundingMode,
    );
    expect(result.output, ExactDecimal.parse('6'));
  });

  test('backup import survives restart and reset removes restored user data', () async {
    final sourceRepository = MemoryUserStateRepository();
    final source = AppController(repository: sourceRepository);
    await source.initialize();
    await source.completeOnboarding();
    await source.toggleFavorite('kilometer');
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

    final targetRepository = MemoryUserStateRepository();
    final target = AppController(repository: targetRepository);
    await target.initialize();
    await target.importState(backup);

    final restarted = AppController(repository: targetRepository);
    await restarted.initialize();
    expect(restarted.state.favoriteUnitIds, contains('kilometer'));
    expect(restarted.engine.catalog.byId('triple_meter'), isNotNull);

    await restarted.resetLocalData();

    final afterReset = AppController(repository: targetRepository);
    await afterReset.initialize();
    expect(afterReset.state.onboardingComplete, isTrue);
    expect(afterReset.state.favoriteUnitIds, isEmpty);
    expect(afterReset.state.pinnedPairs, isEmpty);
    expect(afterReset.state.recents, isEmpty);
    expect(afterReset.state.customUnits, isEmpty);
    expect(afterReset.engine.catalog.byId('triple_meter'), isNull);
  });
}
