import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/domain/conversion_engine.dart';

void main() {
  late ExactConversionEngine engine;

  setUp(() {
    engine = ExactConversionEngine();
  });

  test('converts exact linear length values', () {
    final result = engine.convert(
      value: ExactDecimal.parse('1.25'),
      fromUnitId: 'kilometer',
      toUnitId: 'meter',
    );

    expect(result.output.toCanonicalString(), '1250');
  });

  test('converts affine Celsius and Fahrenheit values', () {
    final freezing = engine.convert(
      value: ExactDecimal.parse('0'),
      fromUnitId: 'celsius',
      toUnitId: 'fahrenheit',
      decimalPlaces: 8,
    );
    final boiling = engine.convert(
      value: ExactDecimal.parse('212'),
      fromUnitId: 'fahrenheit',
      toUnitId: 'celsius',
      decimalPlaces: 8,
    );

    expect(freezing.output.toCanonicalString(), '32');
    expect(boiling.output.toCanonicalString(), '100');
  });

  test('distinguishes decimal and binary data prefixes', () {
    final decimal = engine.convert(
      value: ExactDecimal.parse('1'),
      fromUnitId: 'megabyte',
      toUnitId: 'byte',
      decimalPlaces: 0,
    );
    final binary = engine.convert(
      value: ExactDecimal.parse('1'),
      fromUnitId: 'mebibyte',
      toUnitId: 'byte',
      decimalPlaces: 0,
    );

    expect(decimal.output.toCanonicalString(), '1000000');
    expect(binary.output.toCanonicalString(), '1048576');
  });

  test('converts a batch to every requested target', () {
    final results = engine.batchConvert(
      value: ExactDecimal.parse('1'),
      fromUnitId: 'kilogram',
      toUnitIds: const <String>['gram', 'milligram', 'pound'],
      decimalPlaces: 8,
    );

    expect(results, hasLength(3));
    expect(results[0].output.toCanonicalString(), '1000');
    expect(results[1].output.toCanonicalString(), '1000000');
    expect(results[2].to.id, 'pound');
  });

  test('rejects unknown and cross-category unit pairs', () {
    expect(
      () => engine.convert(
        value: ExactDecimal.parse('1'),
        fromUnitId: 'missing',
        toUnitId: 'meter',
      ),
      throwsA(isA<ConversionFailure>()),
    );
    expect(
      () => engine.convert(
        value: ExactDecimal.parse('1'),
        fromUnitId: 'meter',
        toUnitId: 'kilogram',
      ),
      throwsA(isA<ConversionFailure>()),
    );
  });

  test('rejects unsupported decimal precision', () {
    expect(
      () => engine.convert(
        value: ExactDecimal.parse('1'),
        fromUnitId: 'meter',
        toUnitId: 'kilometer',
        decimalPlaces: 29,
      ),
      throwsA(isA<ConversionFailure>()),
    );
  });
}
