import 'package:flutter/material.dart';

import '../../../app/app_controller.dart';
import '../../../app/theme/app_theme.dart';
import '../../../core/persistence/user_state.dart';

final class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.appController,
    required this.onOpenRecent,
    super.key,
  });

  final AppController appController;
  final ValueChanged<RecentConversion> onOpenRecent;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: appController,
    builder: (context, _) {
      final recents = appController.state.recents;
      return CustomScrollView(
        slivers: <Widget>[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('History', style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              'Your most recent conversions stay on this device and can be reopened instantly.',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      if (recents.isNotEmpty) ...<Widget>[
                        const SizedBox(width: AppSpacing.md),
                        OutlinedButton.icon(
                          onPressed: () => _confirmClear(context),
                          icon: const Icon(Icons.delete_sweep_outlined),
                          label: const Text('Clear'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (recents.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _EmptyHistory(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.xs,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              sliver: SliverList.separated(
                itemCount: recents.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
                itemBuilder: (context, index) => Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: _RecentTile(
                      recent: recents[index],
                      appController: appController,
                      onOpen: () => onOpenRecent(recents[index]),
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    },
  );

  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear conversion history?'),
        content: const Text(
          'This removes saved recent conversions from this device. Favorites, pinned pairs, custom units, and settings are kept.',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear history'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await appController.clearRecents();
    }
  }
}

final class _RecentTile extends StatelessWidget {
  const _RecentTile({
    required this.recent,
    required this.appController,
    required this.onOpen,
  });

  final RecentConversion recent;
  final AppController appController;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final from = appController.engine.catalog.byId(recent.fromUnitId);
    final to = appController.engine.catalog.byId(recent.toUnitId);
    if (from == null || to == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(from.symbol.characters.take(2).toString()),
        ),
        title: Text('${recent.input} ${from.symbol} → ${to.symbol}'),
        subtitle: Text(
          '${from.name} to ${to.name} · ${_formatTime(recent.createdAt.toLocal())}',
        ),
        trailing: const Icon(Icons.arrow_forward_outlined),
        onTap: onOpen,
      ),
    );
  }

  String _formatTime(DateTime value) {
    final date = '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
    final time = '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

final class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 460),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.history_outlined,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text('No recent conversions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Conversions are added here when you copy a result, open a batch table, or submit a conversion.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
