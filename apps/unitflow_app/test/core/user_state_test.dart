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

  test('custom units reject aliases that become blank after trimming', () {
    const unit = CustomUnitData(
      id: 'blank_alias',
      category: UnitCategory.length,
      name: 'Blank alias',
      symbol: 'ba',
      scale: '1',
      offset: '0',
      aliases: <String>['   '],
    );

    expect(unit.toUnitDefinition, throwsFormatException);
  });

  test('custom aliases trim and deduplicate case-insensitively like Rust', () {
    const unit = CustomUnitData(
      id: 'alias_parity',
      category: UnitCategory.length,
      name: 'Alias parity',
      symbol: 'ap',
      scale: '1',
      offset: '0',
      aliases: <String>[' metre ', 'METRE', 'meter alias'],
    );

    final definition = unit.toUnitDefinition();
    expect(definition.aliases, <String>['metre', 'meter alias']);
  });

  test('backup rejects custom unit with whitespace-only alias', () {
    final repository = MemoryUserStateRepository();
    final backup = _emptyBackup()
      ..['customUnits'] = <Object?>[
        <String, Object?>{
          'id': 'blank_alias',
          'category': 'length',
          'name': 'Blank alias',
          'symbol': 'ba',
          'scale': '1',
          'offset': '0',
          'aliases': <Object?>['   '],
          'description': '',
        },
      ];

    expect(
      () => repository.importJson(jsonEncode(backup)),
      throwsFormatException,
    );
  });

  test('memory repository rejects oversized backup payloads', () {
    final repository = MemoryUserStateRepository();
    final oversized = List<String>.filled(1_000_001, 'x').join();

    expect(
      () => repository.importJson(oversized),
      throwsA(
        isA<FormatException>().having(
          (error) => error.message,
          'message',
          'UnitFlow import size is invalid.',
        ),
      ),
    );
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

  test('backup rejects more pinned pairs than the import limit', () {
    final repository = MemoryUserStateRepository();
    final backup = _emptyBackup()
      ..['pinnedPairs'] = List<Object?>.filled(
        UserState.maxImportedPinnedPairs + 1,
        'length|meter|kilometer',
      );

    expect(
      () => repository.importJson(jsonEncode(backup)),
      throwsFormatException,
    );
  });

  test('backup rejects more custom units than the import limit', () {
    final repository = MemoryUserStateRepository();
    final backup = _emptyBackup()
      ..['customUnits'] = List<Object?>.generate(
        UserState.maxImportedCustomUnits + 1,
        (index) => <String, Object?>{
          'id': 'custom_$index',
          'category': 'length',
          'name': 'Custom $index',
          'symbol': 'u$index',
          'scale': '1',
          'offset': '0',
          'aliases': <Object?>[],
          'description': '',
        },
      );

    expect(
      () => repository.importJson(jsonEncode(backup)),
      throwsFormatException,
    );
  });

  test('backup rejects recent conversions with oversized unit identifiers', () {
    final repository = MemoryUserStateRepository();
    final longId = List<String>.filled(65, 'x').join();
    final backup = _emptyBackup()
      ..['recents'] = <Object?>[
        <String, Object?>{
          'input': '1',
          'fromUnitId': longId,
          'toUnitId': 'meter',
          'createdAt': DateTime.utc(2026, 8, 19).toIso8601String(),
        },
      ];

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
