import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  test('import rejects favorites that reference unknown units', () async {
    final controller = AppController(repository: MemoryUserStateRepository());
    await controller.initialize();

    expect(
      () => controller.importState(
        jsonEncode(
          _backupWith(
            favoriteUnitIds: const <Object?>['unit_that_does_not_exist'],
          ),
        ),
      ),
      throwsFormatException,
    );
  });

  test('import rejects pinned pairs that reference unknown units', () async {
    final controller = AppController(repository: MemoryUserStateRepository());
    await controller.initialize();

    expect(
      () => controller.importState(
        jsonEncode(
          _backupWith(
            pinnedPairs: const <Object?>[
              'length|meter|unit_that_does_not_exist',
            ],
          ),
        ),
      ),
      throwsFormatException,
    );
  });

  test('import rejects pinned pairs with a mismatched category', () async {
    final controller = AppController(repository: MemoryUserStateRepository());
    await controller.initialize();

    expect(
      () => controller.importState(
        jsonEncode(
          _backupWith(
            pinnedPairs: const <Object?>['mass|meter|kilometer'],
          ),
        ),
      ),
      throwsFormatException,
    );
  });

  test('import rejects recent conversions that cross categories', () async {
    final controller = AppController(repository: MemoryUserStateRepository());
    await controller.initialize();

    expect(
      () => controller.importState(
        jsonEncode(
          _backupWith(
            recents: <Object?>[
              <String, Object?>{
                'input': '1',
                'fromUnitId': 'meter',
                'toUnitId': 'kilogram',
                'createdAt': DateTime.utc(2026, 8, 19).toIso8601String(),
              },
            ],
          ),
        ),
      ),
      throwsFormatException,
    );
  });

  test('valid saved references remain importable', () async {
    final controller = AppController(repository: MemoryUserStateRepository());
    await controller.initialize();

    await controller.importState(
      jsonEncode(
        _backupWith(
          favoriteUnitIds: const <Object?>['meter'],
          pinnedPairs: const <Object?>['length|meter|kilometer'],
          recents: <Object?>[
            <String, Object?>{
              'input': '2.5',
              'fromUnitId': 'meter',
              'toUnitId': 'kilometer',
              'createdAt': DateTime.utc(2026, 8, 19).toIso8601String(),
            },
          ],
        ),
      ),
    );

    expect(controller.state.favoriteUnitIds, contains('meter'));
    expect(controller.state.pinnedPairs, hasLength(1));
    expect(controller.state.recents, hasLength(1));
  });
}

Map<String, Object?> _backupWith({
  List<Object?> favoriteUnitIds = const <Object?>[],
  List<Object?> pinnedPairs = const <Object?>[],
  List<Object?> recents = const <Object?>[],
  List<Object?> customUnits = const <Object?>[],
}) => <String, Object?>{
  'schemaVersion': 2,
  'theme': 'system',
  'notation': 'plain',
  'roundingMode': 'nearestEven',
  'decimalPlaces': 12,
  'useGrouping': true,
  'onboardingComplete': true,
  'favoriteUnitIds': favoriteUnitIds,
  'pinnedPairs': pinnedPairs,
  'recents': recents,
  'customUnits': customUnits,
};
