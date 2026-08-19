import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/math/exact_decimal.dart';
import 'package:unitflow/features/converter/data/unit_catalog.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';

void main() {
  test('built-in catalog has unique non-empty identifiers', () {
    final UnitCatalog catalog = UnitCatalog();
    final Set<String> ids = catalog.units.map((UnitDefinition unit) => unit.id).toSet();

    expect(ids.length, catalog.units.length);
    expect(ids.every((String id) => id.isNotEmpty), isTrue);
  });

  test('every supported category has multiple units', () {
    final UnitCatalog catalog = UnitCatalog();

    for (final UnitCategory category in UnitCategory.values) {
      expect(
        catalog.forCategory(category).length,
        greaterThanOrEqualTo(2),
        reason: '${category.label} should be usable as a conversion category.',
      );
    }
  });

  test('search matches symbols and aliases', () {
    final UnitCatalog catalog = UnitCatalog();

    expect(catalog.search('km').any((UnitDefinition unit) => unit.id == 'kilometer'), isTrue);
    expect(catalog.search('metre').any((UnitDefinition unit) => unit.id == 'meter'), isTrue);
    expect(catalog.search('mib').any((UnitDefinition unit) => unit.id == 'mebibyte'), isTrue);
  });

  test('category-scoped search never leaks another category', () {
    final UnitCatalog catalog = UnitCatalog();
    final List<UnitDefinition> results = catalog.search(
      'm',
      category: UnitCategory.mass,
      limit: 100,
    );

    expect(results, isNotEmpty);
    expect(results.every((UnitDefinition unit) => unit.category == UnitCategory.mass), isTrue);
  });

  test('duplicate unit identifiers are rejected', () {
    final UnitDefinition first = UnitDefinition(
      id: 'duplicate',
      category: UnitCategory.length,
      name: 'First',
      symbol: 'f',
      scale: ExactDecimal.zero,
    );
    final UnitDefinition second = UnitDefinition(
      id: 'duplicate',
      category: UnitCategory.length,
      name: 'Second',
      symbol: 's',
      scale: ExactDecimal.zero,
    );

    expect(() => UnitCatalog(<UnitDefinition>[first, second]), throwsStateError);
  });
}
