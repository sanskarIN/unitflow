import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  test('pinned pair import rejects oversized source identifiers', () {
    final repository = MemoryUserStateRepository();
    final oversizedId = List<String>.filled(65, 'x').join();
    final backup = _emptyBackup()
      ..['pinnedPairs'] = <Object?>[
        'length|$oversizedId|meter',
      ];

    expect(
      () => repository.importJson(jsonEncode(backup)),
      throwsFormatException,
    );
  });

  test('pinned pair import rejects oversized target identifiers', () {
    final repository = MemoryUserStateRepository();
    final oversizedId = List<String>.filled(65, 'x').join();
    final backup = _emptyBackup()
      ..['pinnedPairs'] = <Object?>[
        'length|meter|$oversizedId',
      ];

    expect(
      () => repository.importJson(jsonEncode(backup)),
      throwsFormatException,
    );
  });

  test('favorite import rejects empty identifiers', () {
    final repository = MemoryUserStateRepository();
    final backup = _emptyBackup()
      ..['favoriteUnitIds'] = const <Object?>[''];

    expect(
      () => repository.importJson(jsonEncode(backup)),
      throwsFormatException,
    );
  });

  test('recent import rejects blank input text', () {
    final repository = MemoryUserStateRepository();
    final backup = _emptyBackup()
      ..['recents'] = <Object?>[
        <String, Object?>{
          'input': '   ',
          'fromUnitId': 'meter',
          'toUnitId': 'kilometer',
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
