import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/format/decimal_format.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('user state round-trips through backup JSON', () {
    final repository = MemoryUserStateRepository();
    final state = UserState(
      theme: ThemePreference.dark,
      notation: DecimalNotation.engineering,
      roundingMode: DecimalRoundingMode.halfAwayFromZero,
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
    expect(restored.roundingMode, DecimalRoundingMode.halfAwayFromZero);
    expect(restored.decimalPlaces, 8);
    expect(restored.favoriteUnitIds, contains('meter'));
    expect(restored.pinnedPairs.single.toUnitId, 'kilometer');
    expect(restored.customUnits.single.id, 'double_meter');
  });

  test('schema version 1 migrates to nearest-even rounding', () {
    final repository = MemoryUserStateRepository();
    const legacy = '{'
        '"schemaVersion":1,'
        '"theme":"system",'
        '"notation":"plain",'
        '"decimalPlaces":12,'
        '"useGrouping":true,'
        '"onboardingComplete":true,'
        '"favoriteUnitIds":[],'
        '"pinnedPairs":[],'
        '"recents":[],'
        '"customUnits":[]'
        '}';

    final restored = repository.importJson(legacy);

    expect(restored.roundingMode, DecimalRoundingMode.nearestEven);
    expect(restored.toJson()['schemaVersion'], UserState.schemaVersion);
    expect(restored.toJson()['roundingMode'], 'nearestEven');
  });

  test('invalid schema version is rejected', () {
    final repository = MemoryUserStateRepository();
    expect(
      () => repository.importJson('{"schemaVersion":999}'),
      throwsFormatException,
    );
  });

  test('invalid schema 2 rounding mode is rejected', () {
    final repository = MemoryUserStateRepository();
    const invalid = '{'
        '"schemaVersion":2,'
        '"theme":"system",'
        '"notation":"plain",'
        '"roundingMode":"not-a-mode",'
        '"decimalPlaces":12,'
        '"useGrouping":true,'
        '"onboardingComplete":true,'
        '"favoriteUnitIds":[],'
        '"pinnedPairs":[],'
        '"recents":[],'
        '"customUnits":[]'
        '}';
    expect(() => repository.importJson(invalid), throwsFormatException);
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

  test('backup rejects more recent conversions than the import limit', () {
    final repository = MemoryUserStateRepository();
    final backup = _emptyBackup()
      ..['recents'] = List<Object?>.generate(
        UserState.maxImportedRecents + 1,
        (index) => <String, Object?>{
          'input': '$index',
          'fromUnitId': 'meter',
          'toUnitId': 'kilometer',
          'createdAt': DateTime.utc(2026, 8, 19).toIso8601String(),
        },
      );

    expect(
      () => repository.importJson(jsonEncode(backup)),
      throwsFormatException,
    );
  });

  test('backup rejects more favorites than the import limit', () {
    final repository = MemoryUserStateRepository();
    final backup = _emptyBackup()
      ..['favoriteUnitIds'] = List<Object?>.generate(
        UserState.maxImportedFavorites + 1,
        (index) => 'unit_$index',
      );

    expect(
      () => repository.importJson(jsonEncode(backup)),
      throwsFormatException,
    );
  });
}

Map<String, Object?> _emptyBackup() => <String, Object?>{
  'schemaVersion': UserState.schemaVersion,
  'theme': 'system',
  'notation': 'plain',
  'roundingMode': 'nearestEven',
  'decimalPlaces': 12,
  'useGrouping': true,
  'onboardingComplete': true,
  'favoriteUnitIds': <Object?>[],
  'pinnedPairs': <Object?>[],
  'recents': <Object?>[],
  'customUnits': <Object?>[],
};
