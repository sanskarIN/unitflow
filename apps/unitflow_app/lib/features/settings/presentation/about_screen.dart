import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/theme/app_theme.dart';

final class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const appVersion = '0.1.0-alpha.1';

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.md),
    children: <Widget>[
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: AppSpacing.md),
              _IdentityCard(),
              const SizedBox(height: AppSpacing.md),
              _LinkCard(
                title: 'Project and support',
                children: <Widget>[
                  _ExternalTile(
                    icon: Icons.code,
                    title: 'GitHub repository',
                    subtitle: 'github.com/sanskarIN/unitflow',
                    uri: Uri.parse('https://github.com/sanskarIN/unitflow'),
                  ),
                  _ExternalTile(
                    icon: Icons.coffee_outlined,
                    title: 'Buy Me a Coffee',
                    subtitle: 'buymeacoffee.com/sanskarIN',
                    uri: Uri.parse('https://buymeacoffee.com/sanskarIN'),
                  ),
                  _ExternalTile(
                    icon: Icons.support_agent,
                    title: 'Support email',
                    subtitle: 'supportramsandesh@gmail.com',
                    uri: Uri.parse(
                      'mailto:supportramsandesh@gmail.com?subject=UnitFlow%20Support',
                    ),
                  ),
                  _ExternalTile(
                    icon: Icons.business_outlined,
                    title: 'Business email',
                    subtitle: 'sanskarin@outlook.in',
                    uri: Uri.parse(
                      'mailto:sanskarin@outlook.in?subject=UnitFlow',
                    ),
                  ),
                  _ExternalTile(
                    icon: Icons.alternate_email,
                    title: 'Business email (alternate)',
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
                        'Privacy',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Static conversions work offline and do not require an account. Preferences, favorites, history, pinned pairs, and custom units are designed to remain on this device unless you explicitly export them.',
                      ),
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

final class _IdentityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: <Widget>[
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(AppRadii.large),
              ),
              child: Icon(
                Icons.swap_calls,
                size: 48,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('UnitFlow', style: theme.textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Version ${AboutScreen.appVersion}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'A precise, offline-first unit converter with a Rust domain core and Flutter interface.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Made by the Sanskar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text('Open source under the MIT License.'),
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
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Could not open $title.')));
    }
  }
}
