import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/app/theme/app_theme.dart';
import 'package:unitflow/app/unitflow_app.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';

void main() {
  testWidgets('reduced-motion policy removes modal and route durations', (tester) async {
    AnimationStyle? modalStyle;
    Duration? routeDuration;

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: Builder(
            builder: (context) {
              modalStyle = AppMotion.modalSurfaceStyle(context);
              routeDuration = AppMotion.routeDuration(
                context,
                const Duration(milliseconds: 300),
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    expect(modalStyle?.duration, Duration.zero);
    expect(modalStyle?.reverseDuration, Duration.zero);
    expect(routeDuration, Duration.zero);
  });

  testWidgets('pin control exposes its toggled semantic state', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    final controller = AppController(
      repository: MemoryUserStateRepository(
        UserState(onboardingComplete: true),
      ),
    );
    addTearDown(controller.dispose);
    await controller.initialize();

    await tester.pumpWidget(UnitFlowApp(appController: controller));
    await tester.pumpAndSettle();

    final unpinned = find.byTooltip('Pin unit pair');
    expect(unpinned, findsOneWidget);
    expect(
      tester.getSemantics(unpinned),
      isSemantics(hasToggledState: true, isToggled: false),
    );

    await tester.tap(unpinned);
    await tester.pump();

    final pinned = find.byTooltip('Unpin unit pair');
    expect(pinned, findsOneWidget);
    expect(
      tester.getSemantics(pinned),
      isSemantics(hasToggledState: true, isToggled: true),
    );
  });
}
