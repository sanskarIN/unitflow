import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/format/decimal_format.dart';
import '../../../core/logging/app_log.dart';
import '../../../core/math/exact_decimal.dart';
import '../../../core/persistence/user_state.dart';
import '../../../l10n/generated/app_localizations.dart';

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
    builder: (context, _) {
      final strings = AppLocalizations.of(context);
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Text(strings.settingsTitle, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionCard(
                    title: strings.appearanceSection,
                    icon: Icons.palette_outlined,
                    children: <Widget>[
                      _DropdownSetting<ThemePreference>(
                        label: strings.themeLabel,
                        value: appController.state.theme,
                        values: ThemePreference.values,
                        labelFor: (value) => switch (value) {
                          ThemePreference.system => strings.themeSystem,
                          ThemePreference.light => strings.themeLight,
                          ThemePreference.dark => strings.themeDark,
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
                    title: strings.conversionFormattingSection,
                    icon: Icons.tune,
                    children: <Widget>[
                      _DropdownSetting<DecimalNotation>(
                        label: strings.notationLabel,
                        value: appController.state.notation,
                        values: DecimalNotation.values,
                        labelFor: (value) => switch (value) {
                          DecimalNotation.plain => strings.notationPlain,
                          DecimalNotation.scientific => strings.notationScientific,
                          DecimalNotation.engineering => strings.notationEngineering,
                        },
                        onChanged: (value) {
                          if (value != null) {
                            appController.setNotation(value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _DropdownSetting<DecimalRoundingMode>(
                        label: strings.roundingModeLabel,
                        value: appController.state.roundingMode,
                        values: DecimalRoundingMode.values,
                        labelFor: (value) => switch (value) {
                          DecimalRoundingMode.nearestEven => strings.roundNearestEven,
                          DecimalRoundingMode.halfAwayFromZero => strings.roundHalfAway,
                          DecimalRoundingMode.towardZero => strings.roundTowardZero,
                          DecimalRoundingMode.awayFromZero => strings.roundAwayZero,
                          DecimalRoundingMode.floor => strings.roundFloor,
                          DecimalRoundingMode.ceiling => strings.roundCeiling,
                        },
                        onChanged: (value) {
                          if (value != null) {
                            appController.setRoundingMode(value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _DropdownSetting<int>(
                        label: strings.decimalPlacesLabel,
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
                        title: Text(strings.digitGroupingTitle),
                        subtitle: Text(strings.digitGroupingSubtitle),
                        value: appController.state.useGrouping,
                        onChanged: appController.setUseGrouping,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: strings.privacyLocalDataSection,
                    icon: Icons.privacy_tip_outlined,
                    children: <Widget>[
                      Text(strings.privacyLocalDataDescription),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: <Widget>[
                          OutlinedButton.icon(
                            onPressed: () => _copyBackup(context),
                            icon: const Icon(Icons.copy_all_outlined),
                            label: Text(strings.copyBackupJson),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _importFromClipboard(context),
                            icon: const Icon(Icons.content_paste_go_outlined),
                            label: Text(strings.importFromClipboard),
                          ),
                          TextButton.icon(
                            onPressed: () => _confirmReset(context),
                            icon: const Icon(Icons.delete_sweep_outlined),
                            label: Text(strings.clearLocalData),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: strings.accessibilityKeyboardSection,
                    icon: Icons.accessibility_new_outlined,
                    children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.keyboard_outlined),
                        title: Text(strings.desktopShortcutsTitle),
                        subtitle: Text(strings.desktopShortcutsDescription),
                      ),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.text_fields_outlined),
                        title: Text(strings.scalableTextTitle),
                        subtitle: Text(strings.scalableTextDescription),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: strings.updatesSection,
                    icon: Icons.system_update_alt_outlined,
                    children: <Widget>[
                      Text(strings.updatesDescription),
                      const SizedBox(height: AppSpacing.sm),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.new_releases_outlined),
                        title: Text(strings.openGithubReleases),
                        subtitle: Text(strings.checkPublishedVersions),
                        trailing: const Icon(Icons.open_in_new),
                        onTap: () => _openReleases(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: strings.aboutSection,
                    icon: Icons.info_outline,
                    children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(strings.appName),
                        subtitle: Text(strings.aboutSubtitle),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: onOpenAbout,
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.verified_user_outlined),
                        title: Text(strings.madeBySanskar),
                        subtitle: Text(strings.mitLicenseSubtitle),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );

  Future<void> _copyBackup(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: appController.exportState()));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).backupCopied)),
    );
  }

  Future<void> _importFromClipboard(BuildContext context) async {
    final data = await Clipboard.getData('text/plain');
    final content = data?.text;
    if (!context.mounted) {
      return;
    }
    final strings = AppLocalizations.of(context);
    if (content == null || content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.clipboardMissingBackup)),
      );
      return;
    }

    try {
      await appController.importState(content);
    } on Object catch (error) {
      AppLog.warning(
        'backup_import_rejected',
        metadata: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).backupImportRejected)),
      );
      return;
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).backupImported)),
    );
  }

  Future<void> _openReleases(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse('https://github.com/sanskarIN/unitflow/releases'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).cannotOpenReleases)),
      );
    }
  }

  Future<void> _confirmReset(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      animationStyle: AppMotion.modalSurfaceStyle(context),
      builder: (context) => AlertDialog(
        title: Text(strings.clearDataDialogTitle),
        content: Text(strings.clearDataDialogBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.clearDataAction),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }

    try {
      await appController.resetLocalData();
    } on Object {
      return;
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).localDataCleared)),
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
