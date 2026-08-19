import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/app/theme/app_theme.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/presentation/converter_controller.dart';
import 'package:unitflow/features/converter/presentation/converter_screen.dart';

void main() {
  testWidgets('converter screen renders core controls and result', (
    WidgetTester tester,
  ) async {
    final MemoryUserStateRepository repository = MemoryUserStateRepository();
    final AppController appController = AppController(repository: repository);
    await appController.initialize();
    final ConverterController controller = ConverterController(
      appController: appController,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: ConverterScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Convert units'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text('From'), findsOneWidget);
    expect(find.text('To'), findsOneWidget);
    expect(find.text('Result'), findsOneWidget);
    expect(find.text('View batch table'), findsOneWidget);

    controller.dispose();
    appController.dispose();
  });

  testWidgets('changing value updates rendered conversion result', (
    WidgetTester tester,
  ) async {
    final MemoryUserStateRepository repository = MemoryUserStateRepository();
    final AppController appController = AppController(repository: repository);
    await appController.initialize();
    final ConverterController controller = ConverterController(
      appController: appController,
    );
    controller.setFromUnit('kilometer');
    controller.setToUnit('meter');

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: ConverterScreen(controller: controller)),
      ),
    );
    await tester.pumpAndSettle();

    final Finder input = find.byType(TextField).first;
    await tester.enterText(input, '2.5');
    await tester.pump();

    expect(find.text('2,500'), findsOneWidget);

    controller.dispose();
    appController.dispose();
  });
}
