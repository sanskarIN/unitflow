import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/app/unitflow_app.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  testWidgets('primary destinations are reachable from the adaptive shell', (tester) async {
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(UnitFlowApp(appController: controller));
    await tester.pumpAndSettle();

    expect(find.text('Convert units'), findsOneWidget);

    await tester.tap(find.text('Batch').first);
    await tester.pumpAndSettle();
    expect(find.text('Batch conversion'), findsOneWidget);

    await tester.tap(find.text('Library').first);
    await tester.pumpAndSettle();
    expect(find.text('Unit library'), findsOneWidget);

    await tester.tap(find.text('History').first);
    await tester.pumpAndSettle();
    expect(find.text('History'), findsWidgets);
    expect(find.text('No recent conversions'), findsOneWidget);

    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();
    expect(find.text('Conversion and formatting'), findsOneWidget);
  });

  testWidgets('settings navigation retains local-only messaging', (tester) async {
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(UnitFlowApp(appController: controller));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();

    expect(find.text('Privacy and local data'), findsOneWidget);
    expect(find.text('Copy backup JSON'), findsOneWidget);
    expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
  });
}
