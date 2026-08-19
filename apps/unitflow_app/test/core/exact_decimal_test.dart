import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';

void main() {
  group('ExactDecimal parsing', () {
    test('normalizes trailing zeros and scientific notation', () {
      expect(ExactDecimal.parse('001.2300').toCanonicalString(), '1.23');
      expect(ExactDecimal.parse('1.25e3').toCanonicalString(), '1250');
      expect(ExactDecimal.parse('-2.5e-3').toCanonicalString(), '-0.0025');
    });

    test('rejects invalid and unbounded exponent input', () {
      expect(() => ExactDecimal.parse(''), throwsFormatException);
      expect(() => ExactDecimal.parse('12.3.4'), throwsFormatException);
      expect(() => ExactDecimal.parse('1e1001'), throwsFormatException);
    });
  });

  group('ExactDecimal arithmetic', () {
    test('adds and multiplies without binary floating point drift', () {
      final ExactDecimal sum = ExactDecimal.parse('0.1') + ExactDecimal.parse('0.2');
      final ExactDecimal product = ExactDecimal.parse('1.25') * ExactDecimal.parse('8');

      expect(sum.toCanonicalString(), '0.3');
      expect(product.toCanonicalString(), '10');
    });

    test('divides to explicit precision', () {
      final ExactDecimal third = ExactDecimal.parse('1').divide(
        ExactDecimal.parse('3'),
        precision: 6,
      );

      expect(third.toFixed(6), '0.333333');
    });
  });

  group('ExactDecimal rounding', () {
    test('nearest-even handles positive midpoint ties', () {
      expect(
        ExactDecimal.parse('2.5').round(0).toCanonicalString(),
        '2',
      );
      expect(
        ExactDecimal.parse('3.5').round(0).toCanonicalString(),
        '4',
      );
    });

    test('nearest-even handles negative midpoint ties', () {
      expect(
        ExactDecimal.parse('-2.5').round(0).toCanonicalString(),
        '-2',
      );
      expect(
        ExactDecimal.parse('-3.5').round(0).toCanonicalString(),
        '-4',
      );
    });

    test('directional modes respect sign', () {
      final ExactDecimal value = ExactDecimal.parse('-1.21');

      expect(
        value.round(1, mode: DecimalRoundingMode.towardZero).toCanonicalString(),
        '-1.2',
      );
      expect(
        value.round(1, mode: DecimalRoundingMode.floor).toCanonicalString(),
        '-1.3',
      );
      expect(
        value.round(1, mode: DecimalRoundingMode.ceiling).toCanonicalString(),
        '-1.2',
      );
      expect(
        value.round(1, mode: DecimalRoundingMode.awayFromZero).toCanonicalString(),
        '-1.3',
      );
    });
  });
}
