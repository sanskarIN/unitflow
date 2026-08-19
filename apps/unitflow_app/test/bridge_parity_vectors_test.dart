import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/domain/conversion_engine.dart';

void main() {
  test('deterministic Dart engine satisfies shared bridge parity vectors', () async {
    final file = File('../../fixtures/bridge_parity_v1.json');
    final decoded = jsonDecode(await file.readAsString()) as Map<String, Object?>;

    expect(decoded['protocolVersion'], 1);
    final cases = decoded['cases'] as List<Object?>;
    final engine = ExactConversionEngine();

    for (final rawCase in cases) {
      final vector = rawCase as Map<String, Object?>;
      final name = vector['name'] as String;
      final output = engine.convert(
        value: ExactDecimal.parse(vector['value'] as String),
        fromUnitId: vector['fromUnitId'] as String,
        toUnitId: vector['toUnitId'] as String,
        decimalPlaces: vector['decimalPlaces'] as int,
        rounding: _roundingMode(vector['roundMode'] as String),
      );

      expect(
        output.output.toCanonicalString(),
        vector['expected'],
        reason: name,
      );
    }
  });
}

DecimalRoundingMode _roundingMode(String value) => switch (value) {
  'nearestEven' => DecimalRoundingMode.nearestEven,
  'halfAwayFromZero' => DecimalRoundingMode.halfAwayFromZero,
  'towardZero' => DecimalRoundingMode.towardZero,
  'awayFromZero' => DecimalRoundingMode.awayFromZero,
  'floor' => DecimalRoundingMode.floor,
  'ceiling' => DecimalRoundingMode.ceiling,
  _ => throw FormatException('Unknown bridge parity rounding mode: $value'),
};
