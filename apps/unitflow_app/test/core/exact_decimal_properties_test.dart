import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';

void main() {
  test('canonical decimal text round-trips for deterministic generated values', () {
    final random = Random(0x554E4954);

    for (var index = 0; index < 2000; index++) {
      final magnitude = random.nextInt(2000000001) - 1000000000;
      final scale = random.nextInt(10);
      final value = ExactDecimal(BigInt.from(magnitude), scale);
      final reparsed = ExactDecimal.parse(value.toCanonicalString());

      expect(reparsed, value, reason: 'case $index: ${value.toCanonicalString()}');
    }
  });

  test('comparison is antisymmetric across deterministic generated values', () {
    final random = Random(0x464C4F57);

    for (var index = 0; index < 1000; index++) {
      final left = ExactDecimal(
        BigInt.from(random.nextInt(2000001) - 1000000),
        random.nextInt(7),
      );
      final right = ExactDecimal(
        BigInt.from(random.nextInt(2000001) - 1000000),
        random.nextInt(7),
      );

      expect(
        left.compareTo(right).sign,
        -right.compareTo(left).sign,
        reason: 'case $index: $left vs $right',
      );
    }
  });

  test('rounding to the same precision is idempotent for every mode', () {
    final random = Random(0x44454349);

    for (final mode in DecimalRoundingMode.values) {
      for (var index = 0; index < 500; index++) {
        final value = ExactDecimal(
          BigInt.from(random.nextInt(2000000001) - 1000000000),
          random.nextInt(12),
        );
        final digits = random.nextInt(10);
        final once = value.round(digits, mode: mode);
        final twice = once.round(digits, mode: mode);

        expect(twice, once, reason: '$mode case $index: $value');
      }
    }
  });

  test('parser rejects pathological and malformed decimal inputs', () {
    final invalid = <String>[
      '',
      ' ',
      '.',
      '+',
      '-',
      '1e',
      '1e1001',
      '1e-1001',
      'NaN',
      'Infinity',
      '0x10',
      '1_000',
      '1,000',
      '1 000',
      '++1',
      '--1',
      '1.2.3',
      List<String>.filled(1025, '9').join(),
    ];

    for (final input in invalid) {
      expect(
        () => ExactDecimal.parse(input),
        throwsFormatException,
        reason: 'input should be rejected: $input',
      );
    }
  });
}
