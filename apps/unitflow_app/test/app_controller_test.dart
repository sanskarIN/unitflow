import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('collection cleanup actions preserve unrelated state', () async {
    final initial = UserState(
      onboardingComplete: true,
      favoriteUnitIds: <String>{'meter'},
      pinnedPairs: const <PinnedPair>[
        PinnedPair(
          category: UnitCategory.length,
          fromUnitId: 'meter',
          toUnitId: 'kilometer',
        ),
      ],
      recents: <RecentConversion>[
        RecentConversion(
          input: '12',
          fromUnitId: 'meter',
          toUnitId: 'kilometer',
          createdAt: DateTime.utc(2026, 8, 19),
        ),
      ],
    );
    final controller = AppController(
      repository: MemoryUserStateRepository(initial),
    );
    await controller.initialize();

    await controller.clearRecents();
    expect(controller.state.recents, isEmpty);
    expect(controller.state.favoriteUnitIds, contains('meter'));
    expect(controller.state.pinnedPairs, hasLength(1));

    await controller.clearFavorites();
    expect(controller.state.favoriteUnitIds, isEmpty);
    expect(controller.state.pinnedPairs, hasLength(1));

    await controller.clearPinnedPairs();
    expect(controller.state.pinnedPairs, isEmpty);
    expect(controller.state.onboardingComplete, isTrue);
  });

  test('removing a custom unit removes dangling user references', () async {
    const custom = CustomUnitData(
      id: 'double_meter',
      category: UnitCategory.length,
      name: 'Double Meter',
      symbol: 'dmx',
      scale: '2',
      offset: '0',
    );
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(
          onboardingComplete: true,
          customUnits: const <CustomUnitData>[custom],
          favoriteUnitIds: <String>{'double_meter'},
          pinnedPairs: const <PinnedPair>[
            PinnedPair(
              category: UnitCategory.length,
              fromUnitId: 'double_meter',
              toUnitId: 'meter',
            ),
          ],
          recents: <RecentConversion>[
            RecentConversion(
              input: '2',
              fromUnitId: 'double_meter',
              toUnitId: 'meter',
              createdAt: DateTime.utc(2026, 8, 19),
            ),
          ],
        ),
      ),
    );
    await controller.initialize();

    await controller.removeCustomUnit('double_meter');

    expect(controller.engine.catalog.byId('double_meter'), isNull);
    expect(controller.state.customUnits, isEmpty);
    expect(controller.state.favoriteUnitIds, isEmpty);
    expect(controller.state.pinnedPairs, isEmpty);
    expect(controller.state.recents, isEmpty);
  });
}
