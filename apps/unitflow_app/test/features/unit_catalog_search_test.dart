import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/data/unit_catalog.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('catalog search includes descriptive custom unit text', () {
    final catalog = UnitCatalog(<UnitDefinition>[
      UnitDefinition(
        id: 'demo_length',
        category: UnitCategory.length,
        name: 'Demo Length',
        symbol: 'dl',
        scale: ExactDecimal.parse('1'),
        description: 'Used for classroom calibration examples.',
        isBuiltIn: false,
      ),
    ]);

    final results = catalog.search('calibration');

    expect(results.map((unit) => unit.id), contains('demo_length'));
  });
}
