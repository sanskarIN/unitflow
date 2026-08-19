import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';
import 'package:unitflow/features/converter/presentation/converter_controller.dart';

void main() {
  late MemoryUserStateRepository repository;
  late AppController appController;
  late ConverterController controller;

  setUp(() async {
    repository = MemoryUserStateRepository();
    appController = AppController(repository: repository);
    await appController.initialize();
    controller = ConverterController(appController: appController);
    controller.setLocale('en_US');
  });

  tearDown(() {
    controller.dispose();
    appController.dispose();
  });

  test('starts with a valid length conversion', () {
    expect(controller.category, UnitCategory.length);
    expect(controller.fromUnit, isNotNull);
    expect(controller.toUnit, isNotNull);
    expect(controller.result, isNotNull);
    expect(controller.error, isNull);
  });

  test('recomputes when input and units change', () {
    controller.setFromUnit('kilometer');
    controller.setToUnit('meter');
    controller.setInput('1.25');

    expect(controller.formattedOutput, '1,250');
    expect(controller.error, isNull);
  });

  test('swap reverses the current pair', () {
    controller.setFromUnit('meter');
    controller.setToUnit('kilometer');
    controller.swapUnits();

    expect(controller.fromUnitId, 'kilometer');
    expect(controller.toUnitId, 'meter');
  });

  test('invalid input exposes a user-facing error without result', () {
    controller.setInput('not-a-number');

    expect(controller.result, isNull);
    expect(controller.error, isNotNull);
    expect(controller.formattedOutput, '—');
  });

  test('category changes always select a valid pair', () {
    controller.setCategory(UnitCategory.temperature);

    expect(controller.fromUnit?.category, UnitCategory.temperature);
    expect(controller.toUnit?.category, UnitCategory.temperature);
    expect(controller.categoryUnits, isNotEmpty);
  });

  test('batch results cover every other unit in the category', () {
    controller.setCategory(UnitCategory.frequency);
    controller.setInput('1');

    final results = controller.batchResults();
    expect(results.length, controller.categoryUnits.length - 1);
    expect(results.every((result) => result.from.id == controller.fromUnitId), isTrue);
  });

  test('pin and recent actions persist through app controller', () async {
    await controller.toggleCurrentPairPinned();
    await controller.recordCurrentConversion();

    expect(controller.isCurrentPairPinned, isTrue);
    expect(appController.state.pinnedPairs, isNotEmpty);
    expect(appController.state.recents, isNotEmpty);
  });

  test('app settings changes trigger recomputation', () async {
    controller.setFromUnit('kilometer');
    controller.setToUnit('meter');
    controller.setInput('1.23456789');

    await appController.setDecimalPlaces(2);

    expect(controller.formattedOutput, '1,234.57');
  });
}
