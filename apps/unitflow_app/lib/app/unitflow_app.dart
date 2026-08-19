import 'package:flutter/material.dart';

import '../core/persistence/user_state.dart';
import '../features/onboarding/presentation/onboarding_screen.dart';
import '../l10n/app_localizations.dart';
import 'app_controller.dart';
import 'app_shell.dart';
import 'theme/app_theme.dart';

final class UnitFlowApp extends StatefulWidget {
  const UnitFlowApp({required this.appController, super.key});

  final AppController appController;

  @override
  State<UnitFlowApp> createState() => _UnitFlowAppState();
}

final class _UnitFlowAppState extends State<UnitFlowApp> {
  @override
  void initState() {
    super.initState();
    if (!widget.appController.isReady) {
      widget.appController.initialize();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.appController,
    builder: (context, _) => MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: _themeMode(widget.appController.state.theme),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: _home(),
    ),
  );

  Widget _home() {
    if (!widget.appController.isReady) {
      return const _StartupScreen();
    }
    if (!widget.appController.state.onboardingComplete) {
      return OnboardingScreen(appController: widget.appController);
    }
    return AppShell(appController: widget.appController);
  }

  ThemeMode _themeMode(ThemePreference preference) => switch (preference) {
    ThemePreference.system => ThemeMode.system,
    ThemePreference.light => ThemeMode.light,
    ThemePreference.dark => ThemeMode.dark,
  };
}

final class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.swap_calls,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(strings.appName, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.md),
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(strings.madeBySanskar),
          ],
        ),
      ),
    );
  }
}
