import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/main.dart';

void main() {
  testWidgets(
    'renders UnitFlow converter and computes a default result',
    (WidgetTester tester) async {
      await tester.pumpWidget(const UnitFlowApp());
      await tester.pumpAndSettle();

      expect(find.text('UnitFlow'), findsOneWidget);
      expect(find.text('Converter'), findsOneWidget);
      expect(find.text('Convert with confidence.'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.textContaining('km'), findsWidgets);
    },
  );
}
