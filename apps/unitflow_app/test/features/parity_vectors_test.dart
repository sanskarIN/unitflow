import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/domain/conversion_engine.dart';

void main() {
  test('Dart fallback matches shared conversion vectors', () async {
    final file = File(
      '${Directory.current.path}/../../test_vectors/conversions.json',
    );
    final decoded = jsonDecode(await file.readAsString()) as List<Object?>;
    final engine = ExactConversionEngine();

    for (final entry in decoded) {
      final vector = (entry! as Map<Object?, Object?>).cast<String, Object?>();
      final result = engine.convert(
        value: ExactDecimal.parse(vector['input']! as String),
        fromUnitId: vector['from']! as String,
        toUnitId: vector['to']! as String,
        decimalPlaces: vector['decimalPlaces']! as int,
        rounding: _rounding(vector['roundingMode']! as String),
      );

      expect(
        result.output.toString(),
        vector['expected'],
        reason: vector['name']! as String,
      );
    }
  });
}

DecimalRoundingMode _rounding(String value) => switch (value) {
  'nearestEven' => DecimalRoundingMode.nearestEven,
  'halfAwayFromZero' => DecimalRoundingMode.halfAwayFromZero,
  'towardZero' => DecimalRoundingMode.towardZero,
  'awayFromZero' => DecimalRoundingMode.awayFromZero,
  'floor' => DecimalRoundingMode.floor,
  'ceiling' => DecimalRoundingMode.ceiling,
  _ => throw FormatException('Unsupported shared vector rounding mode.'),
};
