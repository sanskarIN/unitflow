import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/branding/unitflow_mark.dart';
import '../../../app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

final class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const appVersion = '0.1.0-alpha.1';

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 820),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: AppSpacing.md),
                const _IdentityCard(),
                const SizedBox(height: AppSpacing.md),
                _LinkCard(
                  title: strings.projectSupport,
                  children: <Widget>[
                    _ExternalTile(
                      icon: Icons.code,
                      title: strings.githubRepository,
                      subtitle: 'github.com/sanskarIN/unitflow',
                      uri: Uri.parse('https://github.com/sanskarIN/unitflow'),
                    ),
                    _ExternalTile(
                      icon: Icons.coffee_outlined,
                      title: strings.buyMeACoffee,
                      subtitle: 'buymeacoffee.com/sanskarIN',
                      uri: Uri.parse('https://buymeacoffee.com/sanskarIN'),
                    ),
                    _ExternalTile(
                      icon: Icons.support_agent,
                      title: strings.supportEmail,
                      subtitle: 'supportramsandesh@gmail.com',
                      uri: Uri.parse(
                        'mailto:supportramsandesh@gmail.com?subject=UnitFlow%20Support',
                      ),
                    ),
                    _ExternalTile(
                      icon: Icons.business_outlined,
                      title: strings.businessEmail,
                      subtitle: 'sanskarin@outlook.in',
                      uri: Uri.parse(
                        'mailto:sanskarin@outlook.in?subject=UnitFlow',
                      ),
                    ),
                    _ExternalTile(
                      icon: Icons.alternate_email,
                      title: strings.alternateBusinessEmail,
                      subtitle: 'sanskarin.business@gmail.com',
                      uri: Uri.parse(
                        'mailto:sanskarin.business@gmail.com?subject=UnitFlow',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          strings.privacy,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(strings.aboutPrivacyBody),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _IdentityCard extends StatelessWidget {
  const _IdentityCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: <Widget>[
            UnitFlowMark(size: 88, semanticLabel: strings.appName),
            const SizedBox(height: AppSpacing.md),
            Text(strings.appName, style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(AboutScreen.appVersion, style: theme.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Text(strings.aboutTagline, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            Text(
              strings.madeBySanskar,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(strings.openSourceMit),
          ],
        ),
      ),
    );
  }
}

final class _LinkCard extends StatelessWidget {
  const _LinkCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          ...children,
        ],
      ),
    ),
  );
}

final class _ExternalTile extends StatelessWidget {
  const _ExternalTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.uri,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Uri uri;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(Icons.open_in_new, size: 18),
    onTap: () => _open(context),
  );

  Future<void> _open(BuildContext context) async {
    if (!await launchUrl(uri)) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $title.')),
      );
    }
  }
}
