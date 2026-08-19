import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/data/unit_catalog.dart';
import 'package:unitflow/features/converter/domain/conversion_engine.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

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

  test('rejects values outside the Rust decimal input domain', () {
    for (final value in <String>[
      '79228162514264337593543950336',
      '-79228162514264337593543950336',
      '1e-29',
      '1e1000',
    ]) {
      expect(
        () => engine.convert(
          value: ExactDecimal.parse(value),
          fromUnitId: 'meter',
          toUnitId: 'kilometer',
        ),
        throwsA(isA<ConversionFailure>()),
        reason: value,
      );
    }
  });

  test('accepts Rust decimal boundary values', () {
    final result = engine.convert(
      value: ExactDecimal.parse('79228162514264337593543950335'),
      fromUnitId: 'meter',
      toUnitId: 'meter',
      decimalPlaces: 0,
    );
    expect(result.output.toCanonicalString(), '79228162514264337593543950335');
  });

  test('rejects a multiplication intermediate that would overflow Rust', () {
    expect(
      () => engine.convert(
        value: ExactDecimal.parse('79228162514264337593543950335'),
        fromUnitId: 'kilometer',
        toUnitId: 'meter',
        decimalPlaces: 0,
      ),
      throwsA(isA<ConversionFailure>()),
    );
  });

  test('rejects an affine intermediate that would overflow Rust', () {
    final affineEngine = ExactConversionEngine(
      catalog: UnitCatalog(<UnitDefinition>[
        UnitDefinition(
          id: 'shifted',
          category: UnitCategory.temperature,
          name: 'Shifted',
          symbol: 's',
          scale: ExactDecimal.parse('1'),
          offset: ExactDecimal.parse('1'),
        ),
        UnitDefinition(
          id: 'base',
          category: UnitCategory.temperature,
          name: 'Base',
          symbol: 'b',
          scale: ExactDecimal.parse('1'),
        ),
      ]),
    );

    expect(
      () => affineEngine.convert(
        value: ExactDecimal.parse('79228162514264337593543950335'),
        fromUnitId: 'shifted',
        toUnitId: 'base',
        decimalPlaces: 0,
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

  test('rounding mode changes midpoint conversion result', () {
    final midpointEngine = ExactConversionEngine(
      catalog: UnitCatalog(<UnitDefinition>[
        UnitDefinition(
          id: 'source',
          category: UnitCategory.length,
          name: 'Source',
          symbol: 'src',
          scale: ExactDecimal.parse('1'),
        ),
        UnitDefinition(
          id: 'double_source',
          category: UnitCategory.length,
          name: 'Double Source',
          symbol: 'dbl',
          scale: ExactDecimal.parse('2'),
        ),
      ]),
    );

    final nearestEven = midpointEngine.convert(
      value: ExactDecimal.parse('1'),
      fromUnitId: 'source',
      toUnitId: 'double_source',
      decimalPlaces: 0,
      rounding: DecimalRoundingMode.nearestEven,
    );
    final halfAway = midpointEngine.convert(
      value: ExactDecimal.parse('1'),
      fromUnitId: 'source',
      toUnitId: 'double_source',
      decimalPlaces: 0,
      rounding: DecimalRoundingMode.halfAwayFromZero,
    );

    expect(nearestEven.output.toString(), '0');
    expect(halfAway.output.toString(), '1');
  });
}
