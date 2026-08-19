import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/features/converter/domain/unit_models.dart';
import 'package:unitflow/features/converter/presentation/category_localizations.dart';
import 'package:unitflow/l10n/generated/app_localizations.dart';

void main() {
  test('English localization catalog loads primary navigation messages', () async {
    final strings = await AppLocalizations.delegate.load(const Locale('en'));

    expect(strings.appName, 'UnitFlow');
    expect(strings.navConvert, 'Convert');
    expect(strings.navBatch, 'Batch');
    expect(strings.navLibrary, 'Library');
    expect(strings.navHistory, 'History');
    expect(strings.navSettings, 'Settings');
  });

  test('every unit category has localized presentation content', () async {
    final strings = await AppLocalizations.delegate.load(const Locale('en'));

    for (final category in UnitCategory.values) {
      expect(category.localizedLabel(strings), isNotEmpty, reason: category.id);
      expect(
        category.localizedExplanation(strings),
        isNotEmpty,
        reason: category.id,
      );
      expect(category.localizedExample(strings), isNotEmpty, reason: category.id);
    }
  });
}
