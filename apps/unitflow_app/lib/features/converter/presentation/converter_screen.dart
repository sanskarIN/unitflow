import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../application/batch_export.dart';
import '../domain/unit_models.dart';
import 'converter_controller.dart';

final class ConverterScreen extends StatefulWidget {
  const ConverterScreen({required this.controller, super.key});

  final ConverterController controller;

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

final class _ConverterScreenState extends State<ConverterScreen> {
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.controller.input);
    widget.controller.addListener(_syncInputFromController);
  }

  @override
  void didUpdateWidget(covariant ConverterScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) {
      return;
    }
    oldWidget.controller.removeListener(_syncInputFromController);
    widget.controller.addListener(_syncInputFromController);
    _syncInputFromController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.controller.setLocale(Localizations.localeOf(context).toLanguageTag());
  }

  void _syncInputFromController() {
    final next = widget.controller.input;
    if (_inputController.text == next) {
      return;
    }
    _inputController.value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: next.length),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncInputFromController);
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
      builder: (context) {
        final strings = AppLocalizations.of(context);
        return SafeArea(
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
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              strings.batchConversion,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              '${strings.from}: ${widget.controller.fromUnit?.name ?? '—'}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      OutlinedButton.icon(
                        onPressed: () => _copyBatchCsv(context, results),
                        icon: const Icon(Icons.file_copy_outlined),
                        label: Text(strings.copyCsv),
                      ),
                    ],
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
        );
      },
    );
  }

  Future<void> _copyBatchCsv(
    BuildContext context,
    List<ConversionResult> results,
  ) async {
    final strings = AppLocalizations.of(context);
    final csv = batchResultsToCsv(
      results,
      valueFormatter: (result) => result.output.toCanonicalString(),
    );
    await Clipboard.setData(ClipboardData(text: csv));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.csvCopied)),
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
    final strings = AppLocalizations.of(context);
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
                      Text(
                        strings.convertUnits,
                        style: theme.textTheme.headlineMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        strings.converterTagline,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: controller.isCurrentPairPinned
                      ? strings.unpinUnitPair
                      : strings.pinUnitPair,
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
              label: strings.category,
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
                labelText: strings.value,
                errorText: controller.error,
                helperText: strings.scientificInputHint,
              ),
              onChanged: controller.setInput,
              onSubmitted: (_) => controller.recordCurrentConversion(),
            ),
            const SizedBox(height: AppSpacing.md),
            LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth >= 560;
                final source = _LabeledDropdown<String>(
                  label: strings.from,
                  value: controller.fromUnitId,
                  items: units.map((unit) => unit.id).toList(growable: false),
                  itemLabel: (id) {
                    final unit = units.firstWhere(
                      (candidate) => candidate.id == id,
                    );
                    return '${unit.name} (${unit.symbol})';
                  },
                  onChanged: (id) {
                    if (id != null) {
                      controller.setFromUnit(id);
                    }
                  },
                );
                final target = _LabeledDropdown<String>(
                  label: strings.to,
                  value: controller.toUnitId,
                  items: units.map((unit) => unit.id).toList(growable: false),
                  itemLabel: (id) {
                    final unit = units.firstWhere(
                      (candidate) => candidate.id == id,
                    );
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
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: IconButton.filledTonal(
                          tooltip: strings.swapUnits,
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                      ),
                      child: IconButton.filledTonal(
                        tooltip: strings.swapUnits,
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
                  ? strings.noConversionResult
                  : '${strings.result}: ${controller.formattedOutput} ${controller.toUnit?.symbol ?? ''}',
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
                            strings.result,
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
                      tooltip: strings.copyResult,
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
                label: Text(strings.viewBatchTable),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyResult(BuildContext context) async {
    final strings = AppLocalizations.of(context);
    await Clipboard.setData(ClipboardData(text: controller.formattedOutput));
    await controller.recordCurrentConversion();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.resultCopied)),
    );
  }
}

final class _ConverterSidePanel extends StatelessWidget {
  const _ConverterSidePanel({required this.controller});

  final ConverterController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
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
                    Icon(
                      Icons.school_outlined,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(strings.learn, style: theme.textTheme.titleLarge),
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
                Text(strings.currentPair, style: theme.textTheme.titleLarge),
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
                  label: Text(
                    controller.isCurrentPairPinned
                        ? strings.unpinPair
                        : strings.pinPair,
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
                child: Text(
                  itemLabel(item),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
      ),
    ),
  );
}
