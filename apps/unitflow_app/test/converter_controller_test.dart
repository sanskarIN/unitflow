import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/domain/conversion_engine.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';
import 'package:unitflow/features/converter/presentation/converter_controller.dart';

void main() {
  late AppController appController;
  late ConverterController controller;

  setUp(() async {
    appController = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );
    await appController.initialize();
    controller = ConverterController(appController: appController);
  });

  tearDown(() {
    controller.dispose();
    appController.dispose();
  });

  test('default length pair converts meters to kilometers exactly', () {
    controller.setInput('1500');

    expect(controller.category, UnitCategory.length);
    expect(controller.fromUnitId, 'meter');
    expect(controller.toUnitId, 'kilometer');
    expect(controller.result?.output, ExactDecimal.parse('1.5'));
    expect(controller.error, isNull);
  });

  test('swap reverses the selected conversion pair', () {
    controller.setInput('1.5');
    controller.swapUnits();

    expect(controller.fromUnitId, 'kilometer');
    expect(controller.toUnitId, 'meter');
    expect(controller.result?.output, ExactDecimal.parse('1500'));
  });

  test('changing category always selects a valid same-category pair', () {
    controller.setCategory(UnitCategory.temperature);

    expect(controller.fromUnit?.category, UnitCategory.temperature);
    expect(controller.toUnit?.category, UnitCategory.temperature);
    expect(controller.fromUnitId, isNotEmpty);
    expect(controller.toUnitId, isNotEmpty);
  });

  test('invalid numeric input produces a safe validation message', () {
    controller.setInput('not-a-number');

    expect(controller.result, isNull);
    expect(controller.error, isNotNull);
    expect(controller.error, isNot(contains('Exception')));
  });

  test('batch results stay within the selected category', () {
    controller.setCategory(UnitCategory.mass);
    controller.setInput('2');

    final results = controller.batchResults();

    expect(results, isNotEmpty);
    expect(results.every((result) => result.from.category == UnitCategory.mass), isTrue);
    expect(results.every((result) => result.to.category == UnitCategory.mass), isTrue);
  });

  test('fallback batch engine accepts the documented maximum target count', () {
    final engine = ExactConversionEngine();
    final results = engine.batchConvert(
      value: ExactDecimal.parse('2'),
      fromUnitId: 'meter',
      toUnitIds: List<String>.filled(maxBatchConversionTargets, 'centimeter'),
    );

    expect(maxBatchConversionTargets, 256);
    expect(results, hasLength(maxBatchConversionTargets));
    expect(results.first.output, ExactDecimal.parse('200'));
    expect(results.last.output, ExactDecimal.parse('200'));
  });

  test('fallback batch engine rejects requests above the shared target limit', () {
    final engine = ExactConversionEngine();

    expect(
      () => engine.batchConvert(
        value: ExactDecimal.parse('2'),
        fromUnitId: 'meter',
        toUnitIds: List<String>.filled(
          maxBatchConversionTargets + 1,
          'centimeter',
        ),
      ),
      throwsA(
        isA<ConversionFailure>().having(
          (failure) => failure.message,
          'message',
          contains('at most 256'),
        ),
      ),
    );
  });
}
