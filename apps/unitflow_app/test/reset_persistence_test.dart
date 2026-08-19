import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  test('local reset persists a clean baseline with onboarding completed', () async {
    final repository = MemoryUserStateRepository();
    final controller = AppController(repository: repository);
    await controller.initialize();
    await controller.setTheme(ThemePreference.dark);
    await controller.toggleFavorite('meter');

    await controller.resetLocalData();

    final restored = AppController(repository: repository);
    await restored.initialize();
    expect(restored.state.theme, ThemePreference.system);
    expect(restored.state.onboardingComplete, isTrue);
    expect(restored.state.favoriteUnitIds, isEmpty);
    expect(restored.state.pinnedPairs, isEmpty);
    expect(restored.state.recents, isEmpty);
    expect(restored.state.customUnits, isEmpty);
  });

  test('local reset is serialized after an earlier pending save', () async {
    final repository = _DelayedRepository();
    final controller = AppController(repository: repository);
    await controller.initialize();

    final pendingSave = controller.setTheme(ThemePreference.dark);
    final pendingReset = controller.resetLocalData();

    await Future.wait(<Future<void>>[pendingSave, pendingReset]);
    final restored = await repository.load();

    expect(repository.operations, <String>['save:dark', 'clear', 'save:system']);
    expect(restored.theme, ThemePreference.system);
    expect(restored.onboardingComplete, isTrue);
  });

  test('local reset reports persistence failure through safe warning', () async {
    final controller = AppController(repository: _FailingResetRepository());
    await controller.initialize();

    await expectLater(controller.resetLocalData(), throwsStateError);
    await Future<void>.delayed(Duration.zero);

    expect(
      controller.warning,
      'Local data could not be cleared from storage. Please try again.',
    );
    expect(controller.state.onboardingComplete, isTrue);
  });
}

final class _DelayedRepository implements UserStateRepository {
  final MemoryUserStateRepository _delegate = MemoryUserStateRepository();
  final List<String> operations = <String>[];

  @override
  Future<UserState> load() => _delegate.load();

  @override
  Future<void> save(UserState state) async {
    await Future<void>.delayed(const Duration(milliseconds: 5));
    operations.add('save:${state.theme.name}');
    await _delegate.save(state);
  }

  @override
  Future<void> clear() async {
    operations.add('clear');
    await _delegate.clear();
  }

  @override
  String exportJson(UserState state) => _delegate.exportJson(state);

  @override
  UserState importJson(String content) => _delegate.importJson(content);
}

final class _FailingResetRepository implements UserStateRepository {
  final MemoryUserStateRepository _delegate = MemoryUserStateRepository();

  @override
  Future<UserState> load() => _delegate.load();

  @override
  Future<void> save(UserState state) => _delegate.save(state);

  @override
  Future<void> clear() async {
    throw StateError('simulated clear failure');
  }

  @override
  String exportJson(UserState state) => _delegate.exportJson(state);

  @override
  UserState importJson(String content) => _delegate.importJson(content);
}
