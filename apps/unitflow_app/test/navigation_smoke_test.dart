import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('desktop control shortcuts switch primary destinations', (tester) async {
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(UnitFlowApp(appController: controller));
    await tester.pumpAndSettle();

    await _sendControlShortcut(tester, LogicalKeyboardKey.digit2);
    expect(find.text('Batch conversion'), findsOneWidget);

    await _sendControlShortcut(tester, LogicalKeyboardKey.digit3);
    expect(find.text('Unit library'), findsOneWidget);

    await _sendControlShortcut(tester, LogicalKeyboardKey.digit4);
    expect(find.text('No recent conversions'), findsOneWidget);

    await _sendControlShortcut(tester, LogicalKeyboardKey.comma);
    expect(find.text('Conversion and formatting'), findsOneWidget);

    await _sendControlShortcut(tester, LogicalKeyboardKey.digit1);
    expect(find.text('Convert units'), findsOneWidget);
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

Future<void> _sendControlShortcut(
  WidgetTester tester,
  LogicalKeyboardKey key,
) async {
  await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  await tester.sendKeyEvent(key);
  await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pumpAndSettle();
}
