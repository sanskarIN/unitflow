import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/domain/conversion_engine.dart';

void main() {
  late ExactConversionEngine engine;

  setUp(() {
    engine = ExactConversionEngine();
  });

  test('converts meters to kilometers exactly', () {
    final result = engine.convert(
      value: ExactDecimal.parse('1000'),
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
      decimalPlaces: 12,
    );
    expect(result.output.toString(), '1');
  });

  test('converts Celsius to Fahrenheit', () {
    final result = engine.convert(
      value: ExactDecimal.zero,
      fromUnitId: 'celsius',
      toUnitId: 'fahrenheit',
      decimalPlaces: 6,
    );
    expect(result.output.toString(), '32');
  });

  test('rejects cross-category conversion', () {
    expect(
      () => engine.convert(
        value: ExactDecimal.parse('1'),
        fromUnitId: 'meter',
        toUnitId: 'second',
      ),
      throwsA(isA<ConversionFailure>()),
    );
  });

  test('batch conversion preserves target order', () {
    final results = engine.batchConvert(
      value: ExactDecimal.parse('1'),
      fromUnitId: 'meter',
      toUnitIds: const <String>['centimeter', 'kilometer', 'inch'],
      decimalPlaces: 6,
    );
    expect(results.map((result) => result.to.id), <String>[
      'centimeter',
      'kilometer',
      'inch',
    ]);
  });
}
