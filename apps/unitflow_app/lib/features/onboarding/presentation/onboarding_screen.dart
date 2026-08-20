import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

final class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.appController, super.key});

  final AppController appController;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

final class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final pages = <({IconData icon, String title, String body})>[
      (
        icon: Icons.swap_calls,
        title: strings.onboardingConvertTitle,
        body: strings.onboardingConvertBody,
      ),
      (
        icon: Icons.calculate_outlined,
        title: strings.onboardingPrecisionTitle,
        body: strings.onboardingPrecisionBody,
      ),
      (
        icon: Icons.lock_outline,
        title: strings.onboardingPrivacyTitle,
        body: strings.onboardingPrivacyBody,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: widget.appController.completeOnboarding,
                  child: Text(strings.onboardingSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                onPageChanged: (value) => setState(() => _page = value),
                itemBuilder: (context, index) {
                  final item = pages[index];
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
                          pages.length,
                          (index) => AnimatedContainer(
                            duration: AppMotion.routeDuration(
                              context,
                              const Duration(milliseconds: 180),
                            ),
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
                          onPressed: () => _next(pages.length),
                          child: Text(
                            _page == pages.length - 1
                                ? strings.onboardingStart
                                : strings.onboardingNext,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        strings.madeBySanskar,
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

  Future<void> _next(int pageCount) async {
    if (_page == pageCount - 1) {
      await widget.appController.completeOnboarding();
      return;
    }
    if (MediaQuery.disableAnimationsOf(context)) {
      _pageController.jumpToPage(_page + 1);
      return;
    }
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
    );
  }
}
