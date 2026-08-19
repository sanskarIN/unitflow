import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/format/decimal_format.dart';
import 'package:unitflow/core/math/exact_decimal.dart';

void main() {
  const parser = DecimalInputParser();
  const formatter = DecimalDisplayFormatter();

  group('DecimalInputParser', () {
    test('parses English grouping and decimal separators', () {
      expect(
        parser.parse('1,234,567.89', localeName: 'en_US').toString(),
        '1234567.89',
      );
    });

    test('parses German grouping and decimal separators', () {
      expect(
        parser.parse('1.234.567,89', localeName: 'de_DE').toString(),
        '1234567.89',
      );
    });

    test('preserves scientific notation with localized decimal separator', () {
      expect(
        parser.parse('1,25e3', localeName: 'de_DE').toString(),
        '1250',
      );
    });
  });

  group('DecimalDisplayFormatter', () {
    test('formats English grouping without using binary floating point', () {
      expect(
        formatter.format(
          ExactDecimal.parse('1234567.89'),
          localeName: 'en_US',
        ),
        '1,234,567.89',
      );
    });

    test('formats German separators', () {
      expect(
        formatter.format(
          ExactDecimal.parse('1234567.89'),
          localeName: 'de_DE',
        ),
        '1.234.567,89',
      );
    });

    test('localizes scientific mantissa only', () {
      expect(
        formatter.format(
          ExactDecimal.parse('1250'),
          localeName: 'de_DE',
          notation: DecimalNotation.scientific,
        ),
        '1,250e+3',
      );
    });
  });
}
