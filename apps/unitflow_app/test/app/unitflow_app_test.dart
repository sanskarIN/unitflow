import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/app/branding/unitflow_mark.dart';
import 'package:unitflow/app/unitflow_app.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  testWidgets('launches offline into the converter after onboarding', (
    tester,
  ) async {
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );

    await tester.pumpWidget(UnitFlowApp(appController: controller));
    await tester.pumpAndSettle();

    expect(find.text('UnitFlow'), findsOneWidget);
    expect(find.byType(UnitFlowMark), findsOneWidget);
    expect(find.text('Convert units'), findsOneWidget);
    expect(find.byIcon(Icons.swap_horiz), findsWidgets);
  });

  testWidgets('first run onboarding can be completed', (tester) async {
    final controller = AppController(
      repository: MemoryUserStateRepository(UserState()),
    );

    await tester.pumpWidget(UnitFlowApp(appController: controller));
    await tester.pumpAndSettle();

    expect(find.text('Convert with confidence'), findsOneWidget);
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    expect(find.text('Convert units'), findsOneWidget);
    expect(controller.state.onboardingComplete, isTrue);
  });

  testWidgets('converter exposes semantic labels for primary actions', (
    tester,
  ) async {
    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );

    await tester.pumpWidget(UnitFlowApp(appController: controller));
    await tester.pumpAndSettle();

    expect(find.byTooltip('Swap source and target units'), findsOneWidget);
    expect(find.byTooltip('Copy result'), findsOneWidget);
    expect(find.byTooltip('Search unit library'), findsOneWidget);
  });

  testWidgets('settings can persist the reduced motion preference', (
    tester,
  ) async {
    final repository = MemoryUserStateRepository(
      UserState(onboardingComplete: true),
    );
    final controller = AppController(repository: repository);

    await tester.pumpWidget(UnitFlowApp(appController: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Settings').first);
    await tester.pumpAndSettle();

    expect(find.text('Rounding mode'), findsOneWidget);
    expect(find.text('Reduce motion'), findsOneWidget);
    await tester.tap(find.text('Reduce motion'));
    await tester.pumpAndSettle();

    expect(controller.state.reduceMotion, isTrue);
    expect((await repository.load()).reduceMotion, isTrue);
  });
}
