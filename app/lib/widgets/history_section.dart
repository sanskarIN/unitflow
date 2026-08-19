import 'package:flutter/material.dart';

import '../state/app_state.dart';

class HistorySection extends StatelessWidget {
  const HistorySection({required this.state, super.key});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final List<ConversionRecord> recent = state.recent;
    if (recent.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text('Recent conversions', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                TextButton.icon(
                  onPressed: state.clearHistory,
                  icon: const Icon(Icons.delete_sweep_outlined),
                  label: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            for (final ConversionRecord record in recent.take(6))
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.history),
                title: Text('${record.input} ${record.from.symbol} → ${record.output} ${record.to.symbol}'),
                subtitle: Text('${record.from.name} to ${record.to.name}'),
              ),
          ],
        ),
      ),
    );
  }
}
