import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/format/decimal_format.dart';
import 'package:unitflow/core/math/exact_decimal.dart';

void main() {
  group('ExactDecimal parsing', () {
    test('normalizes trailing zeros', () {
      expect(ExactDecimal.parse('001.2300').toString(), '1.23');
      expect(ExactDecimal.parse('-0.000').toString(), '0');
    });

    test('supports scientific notation without doubles', () {
      expect(ExactDecimal.parse('1.25e3').toString(), '1250');
      expect(ExactDecimal.parse('1.25e-3').toString(), '0.00125');
    });

    test('rejects malformed and excessive exponent input', () {
      expect(() => ExactDecimal.parse('1.2.3'), throwsFormatException);
      expect(() => ExactDecimal.parse('1e1001'), throwsFormatException);
    });
  });

  group('ExactDecimal arithmetic', () {
    test('adds and subtracts different scales', () {
      expect((ExactDecimal.parse('1.2') + ExactDecimal.parse('0.03')).toString(), '1.23');
      expect((ExactDecimal.parse('1.2') - ExactDecimal.parse('0.03')).toString(), '1.17');
    });

    test('multiplies exactly', () {
      expect((ExactDecimal.parse('0.1') * ExactDecimal.parse('0.2')).toString(), '0.02');
    });

    test('divides to requested precision', () {
      expect(
        ExactDecimal.parse('1').divide(ExactDecimal.parse('3'), precision: 6).toString(),
        '0.333333',
      );
    });

    test('nearest-even differs from half-away on ties', () {
      expect(
        ExactDecimal.parse('2.5').round(0, mode: DecimalRoundingMode.nearestEven).toString(),
        '2',
      );
      expect(
        ExactDecimal.parse('2.5').round(0, mode: DecimalRoundingMode.halfAwayFromZero).toString(),
        '3',
      );
    });
  });

  group('Locale-aware decimal formatting', () {
    const formatter = DecimalDisplayFormatter();
    const parser = DecimalInputParser();

    test('uses Western grouping for en_US', () {
      expect(
        formatter.format(ExactDecimal.parse('1234567.89'), localeName: 'en_US'),
        '1,234,567.89',
      );
    });

    test('uses Indian grouping for en_IN', () {
      expect(
        formatter.format(ExactDecimal.parse('1234567.89'), localeName: 'en_IN'),
        '12,34,567.89',
      );
    });

    test('parses localized decimal and grouping separators exactly', () {
      expect(parser.parse('1.234,5', localeName: 'de_DE').toCanonicalString(), '1234.5');
    });
  });
}
