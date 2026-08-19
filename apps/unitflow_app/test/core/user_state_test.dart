import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/format/decimal_format.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('user state JSON round-trips preferences and collections', () {
    final UserState original = UserState(
      theme: ThemePreference.dark,
      notation: DecimalNotation.scientific,
      decimalPlaces: 6,
      useGrouping: false,
      onboardingComplete: true,
      favoriteUnitIds: <String>{'meter', 'kilometer'},
      pinnedPairs: const <PinnedPair>[
        PinnedPair(
          category: UnitCategory.length,
          fromUnitId: 'meter',
          toUnitId: 'kilometer',
        ),
      ],
      recents: <RecentConversion>[
        RecentConversion(
          input: '12.5',
          fromUnitId: 'meter',
          toUnitId: 'kilometer',
          createdAt: DateTime.utc(2026, 8, 19, 2, 0),
        ),
      ],
      customUnits: const <CustomUnitData>[
        CustomUnitData(
          id: 'double_meter',
          category: UnitCategory.length,
          name: 'Double meter',
          symbol: 'dm2',
          scale: '2',
          offset: '0',
          aliases: <String>['double metre'],
          description: 'Two meters.',
        ),
      ],
    );

    final UserState decoded = UserState.fromJson(original.toJson());

    expect(decoded.theme, ThemePreference.dark);
    expect(decoded.notation, DecimalNotation.scientific);
    expect(decoded.decimalPlaces, 6);
    expect(decoded.useGrouping, isFalse);
    expect(decoded.onboardingComplete, isTrue);
    expect(decoded.favoriteUnitIds, containsAll(<String>['meter', 'kilometer']));
    expect(decoded.pinnedPairs.single.storageValue, 'length|meter|kilometer');
    expect(decoded.recents.single.input, '12.5');
    expect(decoded.customUnits.single.id, 'double_meter');
  });

  test('memory repository exports and imports valid state', () async {
    final MemoryUserStateRepository repository = MemoryUserStateRepository();
    final UserState state = UserState(
      onboardingComplete: true,
      decimalPlaces: 4,
      favoriteUnitIds: <String>{'meter'},
    );

    await repository.save(state);
    final UserState loaded = await repository.load();
    final String exported = repository.exportJson(loaded);
    final UserState imported = repository.importJson(exported);

    expect(imported.onboardingComplete, isTrue);
    expect(imported.decimalPlaces, 4);
    expect(imported.favoriteUnitIds, contains('meter'));
  });

  test('unsupported schema version is rejected', () {
    final Map<String, Object?> json = UserState().toJson();
    json['schemaVersion'] = 999;

    expect(() => UserState.fromJson(json), throwsFormatException);
  });

  test('custom units enforce scale and identifier validation', () {
    const CustomUnitData zeroScale = CustomUnitData(
      id: 'zero_scale',
      category: UnitCategory.length,
      name: 'Zero scale',
      symbol: 'zs',
      scale: '0',
      offset: '0',
    );
    const CustomUnitData invalidIdentifier = CustomUnitData(
      id: 'Invalid Identifier',
      category: UnitCategory.length,
      name: 'Identifier check',
      symbol: 'ic',
      scale: '1',
      offset: '0',
    );

    expect(zeroScale.toUnitDefinition, throwsFormatException);
    expect(invalidIdentifier.toUnitDefinition, throwsFormatException);
  });

  test('pinned pair parser rejects malformed storage values', () {
    expect(
      PinnedPair.tryParse('length|meter|kilometer')?.category,
      UnitCategory.length,
    );
    expect(PinnedPair.tryParse('length|meter'), isNull);
    expect(PinnedPair.tryParse('unknown|meter|kilometer'), isNull);
  });
}
