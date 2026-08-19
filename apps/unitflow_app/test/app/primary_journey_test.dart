import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/app/unitflow_app.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  testWidgets('convert pin swap and reopen recent conversion offline', (
    tester,
  ) async {
    final repository = MemoryUserStateRepository(
      UserState(onboardingComplete: true),
    );
    final controller = AppController(repository: repository);

    await tester.pumpWidget(UnitFlowApp(appController: controller));
    await tester.pumpAndSettle();

    final valueField = find.byType(TextField);
    expect(valueField, findsOneWidget);
    await tester.enterText(valueField, '1000');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();

    expect(find.text('1'), findsWidgets);
    expect(controller.state.recents, hasLength(1));
    expect(controller.state.recents.single.fromUnitId, 'meter');
    expect(controller.state.recents.single.toUnitId, 'kilometer');

    await tester.tap(find.byTooltip('Pin unit pair'));
    await tester.pumpAndSettle();
    expect(controller.state.pinnedPairs, hasLength(1));

    await tester.tap(find.byTooltip('Swap source and target units'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('History').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('1000 m'), findsOneWidget);

    await tester.tap(find.textContaining('1000 m'));
    await tester.pumpAndSettle();
    expect(find.text('Convert units'), findsOneWidget);
  });
}
