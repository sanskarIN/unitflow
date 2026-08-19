import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/format/decimal_format.dart';
import '../../../core/persistence/user_state.dart';

final class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.appController,
    required this.onOpenAbout,
    super.key,
  });

  final AppController appController;
  final VoidCallback onOpenAbout;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: appController,
    builder: (context, _) => ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: <Widget>[
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: AppSpacing.md),
                Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.lg),
                _SectionCard(
                  title: 'Appearance',
                  icon: Icons.palette_outlined,
                  children: <Widget>[
                    _DropdownSetting<ThemePreference>(
                      label: 'Theme',
                      value: appController.state.theme,
                      values: ThemePreference.values,
                      labelFor: (value) => switch (value) {
                        ThemePreference.system => 'System',
                        ThemePreference.light => 'Light',
                        ThemePreference.dark => 'Dark',
                      },
                      onChanged: (value) {
                        if (value != null) {
                          appController.setTheme(value);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: 'Conversion and formatting',
                  icon: Icons.tune,
                  children: <Widget>[
                    _DropdownSetting<DecimalNotation>(
                      label: 'Notation',
                      value: appController.state.notation,
                      values: DecimalNotation.values,
                      labelFor: (value) => switch (value) {
                        DecimalNotation.plain => 'Plain',
                        DecimalNotation.scientific => 'Scientific',
                        DecimalNotation.engineering => 'Engineering',
                      },
                      onChanged: (value) {
                        if (value != null) {
                          appController.setNotation(value);
                        }
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _DropdownSetting<int>(
                      label: 'Decimal places',
                      value: appController.state.decimalPlaces,
                      values: List<int>.generate(29, (index) => index),
                      labelFor: (value) => value.toString(),
                      onChanged: (value) {
                        if (value != null) {
                          appController.setDecimalPlaces(value);
                        }
                      },
                    ),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Digit grouping'),
                      subtitle: const Text('Use locale-aware grouping separators in displayed results.'),
                      value: appController.state.useGrouping,
                      onChanged: appController.setUseGrouping,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: 'Privacy and local data',
                  icon: Icons.privacy_tip_outlined,
                  children: <Widget>[
                    const Text(
                      'Static conversions require no account. Your preferences, favorites, history, pinned pairs, and custom units are stored locally by default.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: <Widget>[
                        OutlinedButton.icon(
                          onPressed: () => _copyBackup(context),
                          icon: const Icon(Icons.copy_all_outlined),
                          label: const Text('Copy backup JSON'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _importFromClipboard(context),
                          icon: const Icon(Icons.content_paste_go_outlined),
                          label: const Text('Import from clipboard'),
                        ),
                        TextButton.icon(
                          onPressed: () => _confirmReset(context),
                          icon: const Icon(Icons.delete_sweep_outlined),
                          label: const Text('Clear local data'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SectionCard(
                  title: 'About',
                  icon: Icons.info_outline,
                  children: <Widget>[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('UnitFlow'),
                      subtitle: const Text('License, privacy, support, GitHub, funding, and credits'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: onOpenAbout,
                    ),
                    const Divider(),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.verified_user_outlined),
                      title: Text('Made by the Sanskar'),
                      subtitle: Text('Open source under the MIT License'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Future<void> _copyBackup(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: appController.exportState()));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Backup JSON copied to the clipboard.')),
    );
  }

  Future<void> _importFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');
    final content = data?.text;
    if (!context.mounted) {
      return;
    }
    if (content == null || content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The clipboard does not contain backup JSON.')),
      );
      return;
    }

    try {
      await appController.importState(content);
    } on Object catch (error) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Import rejected: $error')),
      );
      return;
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('UnitFlow backup imported.')),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear local UnitFlow data?'),
        content: const Text(
          'This removes preferences, favorites, recents, pinned pairs, and custom units from this device. Export a backup first if you want to restore them later.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear data'),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await appController.resetLocalData();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Local UnitFlow data cleared.')),
    );
  }
}

final class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: AppSpacing.xs),
              Text(title, style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    ),
  );
}

final class _DropdownSetting<T> extends StatelessWidget {
  const _DropdownSetting({
    required this.label,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(labelText: label),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        items: values
            .map(
              (value) => DropdownMenuItem<T>(
                value: value,
                child: Text(labelFor(value)),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
      ),
    ),
  );
}
