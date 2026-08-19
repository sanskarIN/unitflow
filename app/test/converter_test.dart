import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/converter.dart';
import 'package:unitflow/core/unit_catalog.dart';
import 'package:unitflow/core/unit_model.dart';

ConversionUnit unit(String id) {
  return unitCatalog.firstWhere((ConversionUnit value) => value.id == id);
}

void main() {
  const Converter converter = Converter();

  test('converts kilometers to meters', () {
    final double result = converter.convert(
      value: 1.25,
      from: unit('kilometer'),
      to: unit('meter'),
    );
    expect(result, closeTo(1250, 1e-12));
  });

  test('converts Celsius to Fahrenheit', () {
    final double result = converter.convert(
      value: 100,
      from: unit('celsius'),
      to: unit('fahrenheit'),
    );
    expect(result, closeTo(212, 1e-10));
  });

  test('keeps decimal and binary data units distinct', () {
    final double decimal = converter.convert(
      value: 1,
      from: unit('megabyte'),
      to: unit('byte'),
    );
    final double binary = converter.convert(
      value: 1,
      from: unit('mebibyte'),
      to: unit('byte'),
    );
    expect(decimal, 1000000);
    expect(binary, 1048576);
  });

  test('rejects mismatched categories', () {
    expect(
      () => converter.convert(
        value: 1,
        from: unit('meter'),
        to: unit('kilogram'),
      ),
      throwsA(isA<ConversionException>()),
    );
  });

  test('formats trailing zeros cleanly', () {
    expect(converter.format(12.5, decimalPlaces: 6), '12.5');
    expect(converter.format(12, decimalPlaces: 6), '12');
  });
}
