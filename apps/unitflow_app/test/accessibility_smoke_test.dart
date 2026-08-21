import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/app/app_controller.dart';
import 'package:unitflow/app/theme/app_theme.dart';
import 'package:unitflow/app/unitflow_app.dart';
import 'package:unitflow/core/persistence/user_state.dart';
import 'package:unitflow/core/persistence/user_state_repository.dart';
import 'package:unitflow/features/converter/presentation/batch_screen.dart';
import 'package:unitflow/features/converter/presentation/converter_controller.dart';
import 'package:unitflow/features/converter/presentation/converter_screen.dart';
import 'package:unitflow/features/history/presentation/history_screen.dart';
import 'package:unitflow/features/library/presentation/library_screen.dart';
import 'package:unitflow/features/onboarding/presentation/onboarding_screen.dart';
import 'package:unitflow/features/settings/presentation/about_screen.dart';
import 'package:unitflow/features/settings/presentation/settings_screen.dart';
import 'package:unitflow/l10n/generated/app_localizations.dart';

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

  testWidgets('batch selectors expose label and selected value semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);
    final appController = await _controller();
    final converterController = ConverterController(appController: appController);
    addTearDown(converterController.dispose);
    addTearDown(appController.dispose);

    await tester.pumpWidget(
      _localizedApp(BatchScreen(controller: converterController)),
    );
    await tester.pumpAndSettle();

    final category = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics &&
          widget.properties.label == 'Category' &&
          widget.properties.value == 'Length',
      description: 'batch category semantic label and value',
    );
    expect(category, findsOneWidget);
    expect(
      tester.getSemantics(category),
      isSemantics(label: 'Category', value: 'Length'),
    );
  });

  testWidgets('library and custom-unit dialog survive compact 200% text', (tester) async {
    await _useCompactLargeText(tester);
    final controller = await _controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _localizedApp(
        LibraryScreen(
          appController: controller,
          onOpenPair: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Custom unit'));
    await tester.pumpAndSettle();
    expect(find.text('Create custom unit'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('settings and history survive compact 200% text', (tester) async {
    await _useCompactLargeText(tester);
    final controller = await _controller();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _localizedApp(
        SettingsScreen(
          appController: controller,
          onOpenAbout: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Conversion and formatting'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _localizedApp(
        HistoryScreen(
          appController: controller,
          onOpenRecent: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('No recent conversions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('converter and batch survive compact 200% text', (tester) async {
    await _useCompactLargeText(tester);
    final appController = await _controller();
    final converterController = ConverterController(appController: appController);
    addTearDown(converterController.dispose);
    addTearDown(appController.dispose);

    await tester.pumpWidget(
      _localizedApp(ConverterScreen(controller: converterController)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Convert'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      _localizedApp(BatchScreen(controller: converterController)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Batch conversion'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('onboarding and about survive compact 200% text', (tester) async {
    await _useCompactLargeText(tester);
    final controller = await _controller(onboardingComplete: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      _localizedApp(OnboardingScreen(appController: controller)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Skip'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(_localizedApp(const AboutScreen()));
    await tester.pumpAndSettle();
    expect(find.text('UnitFlow'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

Finder _pinSemantics({required bool isToggled}) => find.byWidgetPredicate(
  (widget) => widget is Semantics && widget.properties.toggled == isToggled,
  description: 'pin semantic state toggled=$isToggled',
);

Future<AppController> _controller({bool onboardingComplete = true}) async {
  final controller = AppController(
    repository: MemoryUserStateRepository(
      UserState(onboardingComplete: onboardingComplete),
    ),
  );
  await controller.initialize();
  return controller;
}

Widget _localizedApp(Widget home) => MaterialApp(
  theme: AppTheme.light(),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: home),
);

Future<void> _useCompactLargeText(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(390, 844));
  tester.platformDispatcher.textScaleFactorTestValue = 2.0;
  addTearDown(() => tester.binding.setSurfaceSize(null));
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}
