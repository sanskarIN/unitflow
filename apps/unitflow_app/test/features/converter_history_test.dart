import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/presentation/converter_controller.dart';

void main() {
  late MemoryUserStateRepository repository;
  late AppController appController;
  late ConverterController converter;

  setUp(() async {
    repository = MemoryUserStateRepository(
      UserState(onboardingComplete: true),
    );
    appController = AppController(repository: repository);
    await appController.initialize();
    converter = ConverterController(appController: appController);
  });

  tearDown(() {
    converter.dispose();
    appController.dispose();
  });

  test('recent conversions persist canonical input across locales', () async {
    converter.setLocale('de_DE');
    converter.setInput('1,25');

    await converter.recordCurrentConversion();

    final recent = (await repository.load()).recents.single;
    expect(recent.input, '1.25');
    expect(recent.fromUnitId, 'meter');
    expect(recent.toUnitId, 'kilometer');
  });

  test('applying a recent conversion restores pair input and result', () {
    final recent = RecentConversion(
      input: '2500',
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
      createdAt: DateTime.utc(2026, 8, 19),
    );

    converter.swapUnits();
    converter.setInput('3');
    converter.applyRecentConversion(recent);

    expect(converter.input, '2500');
    expect(converter.fromUnitId, 'meter');
    expect(converter.toUnitId, 'kilometer');
    expect(converter.result?.output.toCanonicalString(), '2.5');
  });
}
