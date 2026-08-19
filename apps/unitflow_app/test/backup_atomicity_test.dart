import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  test('rejected import does not replace active user state', () async {
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(
          onboardingComplete: true,
          favoriteUnitIds: <String>{'meter'},
        ),
      ),
    );
    await controller.initialize();

    final invalidBackup = <String, Object?>{
      'schemaVersion': UserState.schemaVersion,
      'theme': 'dark',
      'notation': 'engineering',
      'roundingMode': 'floor',
      'decimalPlaces': 2,
      'useGrouping': false,
      'onboardingComplete': true,
      'favoriteUnitIds': const <Object?>['unit_that_does_not_exist'],
      'pinnedPairs': const <Object?>[],
      'recents': const <Object?>[],
      'customUnits': const <Object?>[],
    };

    expect(
      () => controller.importState(jsonEncode(invalidBackup)),
      throwsFormatException,
    );

    expect(controller.state.theme, ThemePreference.system);
    expect(controller.state.decimalPlaces, 12);
    expect(controller.state.favoriteUnitIds, <String>{'meter'});
  });

  test('rejected duplicate custom IDs do not alter the active catalog', () async {
    final controller = AppController(repository: MemoryUserStateRepository());
    await controller.initialize();
    final beforeCount = controller.engine.catalog.all.length;

    final invalidBackup = <String, Object?>{
      'schemaVersion': UserState.schemaVersion,
      'theme': 'system',
      'notation': 'plain',
      'roundingMode': 'nearestEven',
      'decimalPlaces': 12,
      'useGrouping': true,
      'onboardingComplete': true,
      'favoriteUnitIds': const <Object?>[],
      'pinnedPairs': const <Object?>[],
      'recents': const <Object?>[],
      'customUnits': const <Object?>[
        <String, Object?>{
          'id': 'duplicate_custom',
          'category': 'length',
          'name': 'First custom',
          'symbol': 'a',
          'scale': '1',
          'offset': '0',
          'aliases': <Object?>[],
          'description': '',
        },
        <String, Object?>{
          'id': 'duplicate_custom',
          'category': 'length',
          'name': 'Second custom',
          'symbol': 'b',
          'scale': '2',
          'offset': '0',
          'aliases': <Object?>[],
          'description': '',
        },
      ],
    };

    expect(
      () => controller.importState(jsonEncode(invalidBackup)),
      throwsFormatException,
    );

    expect(controller.engine.catalog.all.length, beforeCount);
    expect(controller.engine.catalog.byId('duplicate_custom'), isNull);
  });
}
