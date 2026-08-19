import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/persistence/user_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../converter/domain/unit_models.dart';

final class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.appController,
    required this.onOpenPair,
    super.key,
  });

  final AppController appController;
  final ValueChanged<PinnedPair> onOpenPair;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: appController,
    builder: (context, _) {
      final strings = AppLocalizations.of(context);
      final recents = appController.state.recents;
      if (recents.isEmpty) {
        return const _EmptyHistory();
      }
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              strings.recentConversions,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              strings.recentConversionsSubtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      TextButton.icon(
                        onPressed: () => _clearHistory(context, recents),
                        icon: const Icon(Icons.delete_sweep_outlined),
                        label: Text(strings.clearHistory),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...recents.map((recent) {
                    final from = appController.engine.catalog.byId(
                      recent.fromUnitId,
                    );
                    final to = appController.engine.catalog.byId(
                      recent.toUnitId,
                    );
                    if (from == null ||
                        to == null ||
                        from.category != to.category) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.history, size: 20),
                          ),
                          title: Text(
                            '${recent.input} ${from.symbol} → ${to.symbol}',
                          ),
                          subtitle: Text(
                            '${from.name} → ${to.name} • ${DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).add_jm().format(recent.createdAt.toLocal())}',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => onOpenPair(
                            PinnedPair(
                              category: from.category,
                              fromUnitId: from.id,
                              toUnitId: to.id,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );

  Future<void> _clearHistory(
    BuildContext context,
    List<RecentConversion> snapshot,
  ) async {
    final strings = AppLocalizations.of(context);
    final preserved = List<RecentConversion>.of(snapshot);
    await appController.clearHistory();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(strings.historyCleared),
        action: SnackBarAction(
          label: strings.undo,
          onPressed: () => appController.restoreHistory(preserved),
        ),
      ),
    );
  }
}

final class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.history_toggle_off,
                size: 56,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                strings.noRecentConversions,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                strings.noRecentConversionsSubtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
