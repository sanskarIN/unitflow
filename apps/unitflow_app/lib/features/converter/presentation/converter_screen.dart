import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_theme.dart';
import '../domain/unit_models.dart';
import 'converter_controller.dart';

final class ConverterScreen extends StatefulWidget {
  const ConverterScreen({required this.controller, super.key});

  final ConverterController controller;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

final class _ConverterScreenState extends State<ConverterScreen> {
  late final TextEditingController _inputController = TextEditingController(
    text: widget.controller.input,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.setLocale(Localizations.localeOf(context).toLanguageTag());
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) => LayoutBuilder(
      builder: (context, constraints) {
        final expanded = constraints.maxWidth >= AppBreakpoints.expanded;
        final converter = _ConverterCard(
          controller: widget.controller,
          inputController: _inputController,
          onShowBatch: _showBatch,
        );
        final side = _ConverterSidePanel(controller: widget.controller);

        if (expanded) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(flex: 3, child: converter),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(flex: 2, child: side),
                  ],
                ),
              ),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            converter,
            const SizedBox(height: AppSpacing.md),
            side,
          ],
        );
      },
    ),
  );

  Future<void> _showBatch() async {
    final results = widget.controller.batchResults();
    if (results.isEmpty) {
      return;
    }
    await widget.controller.recordCurrentConversion();
    if (!mounted) {
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: FractionallySizedBox(
          heightFactor: 0.78,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text('Batch conversion', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'From ${widget.controller.fromUnit?.name ?? 'selected unit'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                Expanded(
                  child: ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final result = results[index];
                      return ListTile(
                        title: Text(result.to.name),
                        subtitle: Text(result.to.symbol),
                        trailing: SelectableText(
                          widget.controller.formatBatchValue(result.output),
                          textAlign: TextAlign.end,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

final class _ConverterCard extends StatelessWidget {
  const _ConverterCard({
    required this.controller,
    required this.inputController,
    required this.onShowBatch,
  });

  final ConverterController controller;
  final TextEditingController inputController;
  final VoidCallback onShowBatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final units = controller.categoryUnits;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Convert units', style: theme.textTheme.headlineMedium),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'Precise, local, and distraction-free.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: controller.isCurrentPairPinned ? 'Unpin unit pair' : 'Pin unit pair',
                  onPressed: () => controller.toggleCurrentPairPinned(),
                  icon: Icon(
                    controller.isCurrentPairPinned
                        ? Icons.push_pin
                        : Icons.push_pin_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _LabeledDropdown<UnitCategory>(
              label: 'Category',
              value: controller.category,
              items: UnitCategory.values,
              itemLabel: (category) => category.label,
              onChanged: (category) {
                if (category != null) {
                  controller.setCategory(category);
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: inputController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Value',
                errorText: controller.error,
                helperText: 'Scientific notation such as 1.2e6 is supported.',
              ),
              onChanged: controller.setInput,
              onSubmitted: (_) => controller.recordCurrentConversion(),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth >= 560;
                final source = _LabeledDropdown<String>(
                  label: 'From',
                  value: controller.fromUnitId,
                  items: units.map((unit) => unit.id).toList(growable: false),
                  itemLabel: (id) {
                    final unit = units.firstWhere((candidate) => candidate.id == id);
                    return '${unit.name} (${unit.symbol})';
                  },
                  onChanged: (id) {
                    if (id != null) {
                      controller.setFromUnit(id);
                    }
                  },
                );
                final target = _LabeledDropdown<String>(
                  label: 'To',
                  value: controller.toUnitId,
                  items: units.map((unit) => unit.id).toList(growable: false),
                  itemLabel: (id) {
                    final unit = units.firstWhere((candidate) => candidate.id == id);
                    return '${unit.name} (${unit.symbol})';
                  },
                  onChanged: (id) {
                    if (id != null) {
                      controller.setToUnit(id);
                    }
                  },
                );

                if (!horizontal) {
                  return Column(
                    children: <Widget>[
                      source,
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: IconButton.filledTonal(
                          tooltip: 'Swap source and target units',
                          onPressed: controller.swapUnits,
                          icon: const Icon(Icons.swap_vert),
                        ),
                      ),
                      target,
                    ],
                  );
                }
                return Row(
                  children: <Widget>[
                    Expanded(child: source),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: IconButton.filledTonal(
                        tooltip: 'Swap source and target units',
                        onPressed: controller.swapUnits,
                        icon: const Icon(Icons.swap_horiz),
                      ),
                    ),
                    Expanded(child: target),
                  ],
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Semantics(
              liveRegion: controller.result != null,
              label: controller.result == null
                  ? 'No conversion result'
                  : 'Conversion result ${controller.formattedOutput} ${controller.toUnit?.symbol ?? ''}',
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.large),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Result',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          SelectableText(
                            controller.formattedOutput,
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (controller.toUnit != null)
                            Text(
                              controller.toUnit!.symbol,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy result',
                      onPressed: controller.result == null
                          ? null
                          : () => _copyResult(context),
                      icon: const Icon(Icons.copy_outlined),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: controller.result == null ? null : onShowBatch,
                icon: const Icon(Icons.table_rows_outlined),
                label: const Text('View batch table'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyResult(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: controller.formattedOutput));
    await controller.recordCurrentConversion();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conversion result copied.')),
    );
  }
}

final class _ConverterSidePanel extends StatelessWidget {
  const _ConverterSidePanel({required this.controller});

  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.school_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: AppSpacing.xs),
                    Text('Learn', style: theme.textTheme.titleLarge),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(controller.category.explanation),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  controller.category.example,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Current pair', style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${controller.fromUnit?.name ?? '—'} → ${controller.toUnit?.name ?? '—'}',
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton.tonalIcon(
                  onPressed: () => controller.toggleCurrentPairPinned(),
                  icon: Icon(
                    controller.isCurrentPairPinned
                        ? Icons.push_pin
                        : Icons.push_pin_outlined,
                  ),
                  label: Text(controller.isCurrentPairPinned ? 'Unpin pair' : 'Pin pair'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

final class _LabeledDropdown<T> extends StatelessWidget {
  const _LabeledDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => InputDecorator(
    decoration: InputDecoration(labelText: label),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        items: items
            .map(
              (item) => DropdownMenuItem<T>(
                value: item,
                child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
      ),
    ),
  );
}
