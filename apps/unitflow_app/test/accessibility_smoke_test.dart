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

  testWidgets('pin controls expose their toggled semantic state', (tester) async {
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

    final unpinnedSemantics = _pinSemantics(isToggled: false);
    expect(unpinnedSemantics, findsNWidgets(2));
    expect(
      tester.getSemantics(unpinnedSemantics.first),
      isSemantics(hasToggledState: true, isToggled: false),
    );

    await tester.tap(find.byTooltip('Pin unit pair'));
    await tester.pump();

    final pinnedSemantics = _pinSemantics(isToggled: true);
    expect(pinnedSemantics, findsNWidgets(2));
    expect(
      tester.getSemantics(pinnedSemantics.first),
      isSemantics(hasToggledState: true, isToggled: true),
    );
  });
}

Finder _pinSemantics({required bool isToggled}) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.toggled == isToggled,
  description: 'pin semantic state toggled=$isToggled',
);
