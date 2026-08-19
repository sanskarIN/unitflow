import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  test('recordRecent rejects unknown unit IDs', () async {
    final controller = AppController(repository: MemoryUserStateRepository());
    await controller.initialize();

    expect(
      () => controller.recordRecent(
        input: '1',
        fromUnitId: 'unit_that_does_not_exist',
        toUnitId: 'meter',
      ),
      throwsArgumentError,
    );
    expect(controller.state.recents, isEmpty);
  });

  test('recordRecent rejects cross-category pairs', () async {
    final controller = AppController(repository: MemoryUserStateRepository());
    await controller.initialize();

    expect(
      () => controller.recordRecent(
        input: '1',
        fromUnitId: 'meter',
        toUnitId: 'kilogram',
      ),
      throwsArgumentError,
    );
    expect(controller.state.recents, isEmpty);
  });

  test('recordRecent rejects oversized input strings', () async {
    final controller = AppController(repository: MemoryUserStateRepository());
    await controller.initialize();
    final oversized = List<String>.filled(1025, '9').join();

    expect(
      () => controller.recordRecent(
        input: oversized,
        fromUnitId: 'meter',
        toUnitId: 'kilometer',
      ),
      throwsArgumentError,
    );
    expect(controller.state.recents, isEmpty);
  });
}
