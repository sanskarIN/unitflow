import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/app_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/errors/user_safe_error.dart';
import '../../../core/format/decimal_format.dart';
import '../../../core/io/backup_file_service.dart';
import '../../../core/math/exact_decimal.dart';
import '../../../core/persistence/user_state.dart';
import '../../../l10n/app_localizations.dart';

final class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.appController,
    required this.onOpenAbout,
    super.key,
  });

  static const _backupFiles = BackupFileService();
  static final Uri _releasesUri = Uri.parse(
    'https://github.com/sanskarIN/unitflow/releases',
  );

  final AppController appController;
  final VoidCallback onOpenAbout;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AnimatedBuilder(
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
                  Text(
                    strings.settings,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _SectionCard(
                    title: strings.appearance,
                    icon: Icons.palette_outlined,
                    children: <Widget>[
                      _DropdownSetting<ThemePreference>(
                        label: strings.theme,
                        value: appController.state.theme,
                        values: ThemePreference.values,
                        labelFor: (value) => switch (value) {
                          ThemePreference.system => strings.system,
                          ThemePreference.light => strings.light,
                          ThemePreference.dark => strings.dark,
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
                    title: strings.conversionFormatting,
                    icon: Icons.tune,
                    children: <Widget>[
                      _DropdownSetting<DecimalNotation>(
                        label: strings.notation,
                        value: appController.state.notation,
                        values: DecimalNotation.values,
                        labelFor: (value) => switch (value) {
                          DecimalNotation.plain => strings.plain,
                          DecimalNotation.scientific => strings.scientific,
                          DecimalNotation.engineering => strings.engineering,
                        },
                        onChanged: (value) {
                          if (value != null) {
                            appController.setNotation(value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _DropdownSetting<int>(
                        label: strings.decimalPlaces,
                        value: appController.state.decimalPlaces,
                        values: List<int>.generate(29, (index) => index),
                        labelFor: (value) => value.toString(),
                        onChanged: (value) {
                          if (value != null) {
                            appController.setDecimalPlaces(value);
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      _DropdownSetting<DecimalRoundingMode>(
                        label: strings.roundingMode,
                        helperText: strings.roundingModeSubtitle,
                        value: appController.state.roundingMode,
                        values: DecimalRoundingMode.values,
                        labelFor: (value) => switch (value) {
                          DecimalRoundingMode.nearestEven => strings.nearestEven,
                          DecimalRoundingMode.halfAwayFromZero =>
                            strings.halfAwayFromZero,
                          DecimalRoundingMode.towardZero => strings.towardZero,
                          DecimalRoundingMode.awayFromZero => strings.awayFromZero,
                          DecimalRoundingMode.floor => strings.floor,
                          DecimalRoundingMode.ceiling => strings.ceiling,
                        },
                        onChanged: (value) {
                          if (value != null) {
                            appController.setRoundingMode(value);
                          }
                        },
                      ),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(strings.digitGrouping),
                        subtitle: Text(strings.digitGroupingSubtitle),
                        value: appController.state.useGrouping,
                        onChanged: appController.setUseGrouping,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: strings.accessibility,
                    icon: Icons.accessibility_new_outlined,
                    children: <Widget>[
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(strings.reduceMotion),
                        subtitle: Text(strings.reduceMotionSubtitle),
                        value: appController.state.reduceMotion,
                        onChanged: appController.setReduceMotion,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(strings.systemAccessibility),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: strings.privacyLocalData,
                    icon: Icons.privacy_tip_outlined,
                    children: <Widget>[
                      Text(strings.privacyLocalDataSubtitle),
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: <Widget>[
                          OutlinedButton.icon(
                            onPressed: () => _saveBackupFile(context),
                            icon: const Icon(Icons.save_alt_outlined),
                            label: Text(strings.saveBackupFile),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _importBackupFile(context),
                            icon: const Icon(Icons.file_open_outlined),
                            label: Text(strings.importBackupFile),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _copyBackup(context),
                            icon: const Icon(Icons.copy_all_outlined),
                            label: Text(strings.copyBackupJson),
                          ),
                          OutlinedButton.icon(
                            onPressed: () => _importFromClipboard(context),
                            icon: const Icon(Icons.content_paste_go_outlined),
                            label: Text(strings.importClipboard),
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
                    title: strings.updates,
                    icon: Icons.system_update_alt_outlined,
                    children: <Widget>[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.new_releases_outlined),
                        title: Text(strings.openReleases),
                        subtitle: Text(strings.openReleasesSubtitle),
                        trailing: const Icon(Icons.open_in_new, size: 18),
                        onTap: () => _openReleases(context),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(strings.updatesNetworkNote),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _SectionCard(
                    title: strings.about,
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
                        subtitle: Text(strings.openSourceMit),
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
  }

  Future<void> _saveBackupFile(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    try {
      final saved = await _backupFiles.exportBackup(appController.exportState());
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            saved ? strings.backupFileSaved : strings.backupFileUnavailable,
          ),
        ),
      );
    } on Object catch (error) {
      final message = userSafeFailure(
        error,
        event: 'backup_export_failed',
        fallback: strings.backupExportFailed,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _importBackupFile(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    try {
      final content = await _backupFiles.importBackup();
      if (content == null) {
        return;
      }
      await appController.importState(content);
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.backupImported)),
      );
    } on Object catch (error) {
      final message = userSafeFailure(
        error,
        event: 'backup_file_import_rejected',
        fallback: strings.backupImportRejected,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _copyBackup(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: appController.exportState()));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.backupCopied)),
    );
  }

  Future<void> _importFromClipboard(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final data = await Clipboard.getData('text/plain');
    final content = data?.text;
    if (!context.mounted) {
      return;
    }
    if (content == null || content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(strings.clipboardNoBackup)),
      );
      return;
    }

    try {
      await appController.importState(content);
    } on Object catch (error) {
      final message = userSafeFailure(
        error,
        event: 'backup_clipboard_import_rejected',
        fallback: strings.backupImportRejected,
      );
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      return;
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.backupImported)),
    );
  }

  Future<void> _openReleases(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    try {
      if (await launchUrl(_releasesUri)) {
        return;
      }
    } on Object catch (error) {
      userSafeFailure(
        error,
        event: 'release_page_open_failed',
        fallback: strings.releaseOpenFailed,
      );
    }
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.releaseOpenFailed)),
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.clearLocalDataTitle),
        content: Text(strings.clearLocalDataBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.clearData),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await appController.resetLocalData();
    if (!context.mounted || appController.warning != null) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.localDataCleared)),
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
    this.helperText,
  });

  final String label;
  final String? helperText;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(labelText: label, helperText: helperText),
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
