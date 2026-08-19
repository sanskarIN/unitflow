import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  test('save failure keeps session state and exposes a warning', () async {
    final repository = _FailingRepository(
      initial: UserState(onboardingComplete: true),
      failSave: true,
    );
    final controller = AppController(repository: repository);
    addTearDown(controller.dispose);
    await controller.initialize();

    await expectLater(controller.setTheme(ThemePreference.dark), completes);

    expect(controller.state.theme, ThemePreference.dark);
    expect(controller.warning, contains('could not be saved locally'));
  });

  test('clear failure preserves existing state and exposes a warning', () async {
    final repository = _FailingRepository(
      initial: UserState(
        onboardingComplete: true,
        theme: ThemePreference.dark,
      ),
      failClear: true,
    );
    final controller = AppController(repository: repository);
    addTearDown(controller.dispose);
    await controller.initialize();

    await expectLater(controller.resetLocalData(), completes);

    expect(controller.state.theme, ThemePreference.dark);
    expect(controller.warning, contains('could not be cleared'));
  });
}

final class _FailingRepository implements UserStateRepository {
  _FailingRepository({
    required UserState initial,
    this.failSave = false,
    this.failClear = false,
  }) : _state = initial;

  final bool failSave;
  final bool failClear;
  final MemoryUserStateRepository _codec = MemoryUserStateRepository();
  UserState _state;

  @override
  Future<UserState> load() async => _state;

  @override
  Future<void> save(UserState state) async {
    if (failSave) {
      throw StateError('simulated save failure');
    }
    _state = state;
  }

  @override
  Future<void> clear() async {
    if (failClear) {
      throw StateError('simulated clear failure');
    }
    _state = UserState();
  }

  @override
  String exportJson(UserState state) => _codec.exportJson(state);

  @override
  UserState importJson(String content) => _codec.importJson(content);
}
