import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/application/batch_export.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('batch CSV exports deterministic fields and escapes commas', () {
    final from = UnitDefinition(
      id: 'source',
      category: UnitCategory.length,
      name: 'Source',
      symbol: 's',
      scale: ExactDecimal.parse('1'),
    );
    final to = UnitDefinition(
      id: 'target',
      category: UnitCategory.length,
      name: 'Target, special',
      symbol: 't',
      scale: ExactDecimal.parse('1'),
    );
    final result = ConversionResult(
      input: ExactDecimal.parse('1'),
      output: ExactDecimal.parse('2.5'),
      from: from,
      to: to,
    );

    final csv = batchResultsToCsv(
      <ConversionResult>[result],
      valueFormatter: (value) => value.output.toCanonicalString(),
    );

    expect(csv, contains('unit_id,unit_name,symbol,value'));
    expect(csv, contains('target,"Target, special",t,2.5'));
  });
}
