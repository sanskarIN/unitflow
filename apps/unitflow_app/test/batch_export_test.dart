import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/domain/batch_export.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  const formatter = BatchExportFormatter();
  final meter = UnitDefinition(
    id: 'meter',
    category: UnitCategory.length,
    name: 'Meter',
    symbol: 'm',
    scale: ExactDecimal.parse('1'),
  );
  final kilometer = UnitDefinition(
    id: 'kilometer',
    category: UnitCategory.length,
    name: 'Kilometer',
    symbol: 'km',
    scale: ExactDecimal.parse('1000'),
  );

  test('CSV export contains stable headers and canonical decimals', () {
    final output = formatter.encode(<ConversionResult>[
      ConversionResult(
        input: ExactDecimal.parse('1000.00'),
        output: ExactDecimal.parse('1.0'),
        from: meter,
        to: kilometer,
      ),
    ]);

    expect(
      output,
      'input,from_unit_id,from_unit,from_symbol,output,to_unit_id,to_unit,to_symbol\n'
      '1000,meter,Meter,m,1,kilometer,Kilometer,km',
    );
  });

  test('TSV export uses tab delimiters', () {
    final output = formatter.encode(
      <ConversionResult>[
        ConversionResult(
          input: ExactDecimal.parse('2'),
          output: ExactDecimal.parse('0.002'),
          from: meter,
          to: kilometer,
        ),
      ],
      format: BatchExportFormat.tsv,
    );

    expect(output.split('\n').first.split('\t'), hasLength(8));
    expect(output, contains('0.002\tkilometer'));
  });

  test('CSV export quotes fields containing commas and quotes', () {
    final quotedTarget = UnitDefinition(
      id: 'test',
      category: UnitCategory.length,
      name: 'Test, "quoted" unit',
      symbol: 't',
      scale: ExactDecimal.parse('1'),
    );
    final output = formatter.encode(<ConversionResult>[
      ConversionResult(
        input: ExactDecimal.parse('1'),
        output: ExactDecimal.parse('1'),
        from: meter,
        to: quotedTarget,
      ),
    ]);

    expect(output, contains('"Test, ""quoted"" unit"'));
  });

  test('JSON export uses strings for exact decimal values', () {
    final output = formatter.encode(
      <ConversionResult>[
        ConversionResult(
          input: ExactDecimal.parse('1000.00'),
          output: ExactDecimal.parse('1.0'),
          from: meter,
          to: kilometer,
        ),
      ],
      format: BatchExportFormat.json,
    );
    final decoded = jsonDecode(output) as List<Object?>;
    final row = decoded.single as Map<String, Object?>;

    expect(row['input'], '1000');
    expect(row['output'], '1');
    expect(row['from_unit_id'], 'meter');
    expect(row['to_unit_id'], 'kilometer');
  });

  test('JSON export of an empty batch is a valid empty array', () {
    final output = formatter.encode(
      const <ConversionResult>[],
      format: BatchExportFormat.json,
    );
    expect(output, '[]');
  });
}
