import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../app/app_controller.dart';
import '../../../app/theme/app_theme.dart';
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
                  Text(
                    'Recent conversions',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Stored locally on this device and limited to the most recent entries.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...recents.map((recent) {
                    final from = appController.engine.catalog.byId(recent.fromUnitId);
                    final to = appController.engine.catalog.byId(recent.toUnitId);
                    if (from == null || to == null || from.category != to.category) {
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
                            '${from.name} to ${to.name} • ${DateFormat.yMMMd().add_jm().format(recent.createdAt.toLocal())}',
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
}

final class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => Center(
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
              'No recent conversions yet',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Conversions appear here after you copy a result, open the batch table, or submit the value field.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
