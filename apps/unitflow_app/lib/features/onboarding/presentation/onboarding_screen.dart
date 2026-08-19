import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/theme/app_theme.dart';

final class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.appController, super.key});

  final AppController appController;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

final class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pages = <({IconData icon, String title, String body})>[
    (
      icon: Icons.swap_calls,
      title: 'Convert with confidence',
      body: 'Explore a broad catalog across length, area, volume, mass, speed, pressure, energy, power, angle, data, frequency, time, temperature, and more.',
    ),
    (
      icon: Icons.calculate_outlined,
      title: 'Precision by design',
      body: 'UnitFlow keeps decimal calculations deterministic, supports scientific and engineering notation, and makes rounding an explicit setting.',
    ),
    (
      icon: Icons.lock_outline,
      title: 'Offline-first and yours',
      body: 'Static conversions need no account. Favorites, history, pinned pairs, settings, and custom units are designed to stay on your device unless you export them.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: widget.appController.completeOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) {
                  final item = _pages[index];
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 620),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(AppRadii.large),
                              ),
                              child: Icon(
                                item.icon,
                                size: 64,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              item.body,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List<Widget>.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                            width: index == _page ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: index == _page
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(99),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _next,
                          child: Text(_page == _pages.length - 1 ? 'Start converting' : 'Next'),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Made by the Sanskar',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _next() async {
    if (_page == _pages.length - 1) {
      await widget.appController.completeOnboarding();
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }
}
