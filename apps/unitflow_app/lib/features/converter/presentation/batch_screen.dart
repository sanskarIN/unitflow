import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_theme.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../domain/batch_export.dart';
import '../domain/unit_models.dart';
import 'category_localizations.dart';
import 'converter_controller.dart';

final class BatchScreen extends StatefulWidget {
  const BatchScreen({required this.controller, super.key});

  final ConverterController controller;

  @override
  State<BatchScreen> createState() => _BatchScreenState();
}

final class _BatchScreenState extends State<BatchScreen> {
  late final TextEditingController _inputController;

  @override
  void initState() {
    super.initState();
    _inputController = TextEditingController(text: widget.controller.input);
    widget.controller.addListener(_syncInputFromController);
  }

  @override
  void didUpdateWidget(covariant BatchScreen oldWidget) {
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
    final input = widget.controller.input;
    if (_inputController.text == input) {
      return;
    }
    _inputController.value = TextEditingValue(
      text: input,
      selection: TextSelection.collapsed(offset: input.length),
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
    builder: (context, _) {
      final theme = Theme.of(context);
      final strings = AppLocalizations.of(context);
      final units = widget.controller.categoryUnits;
      final results = widget.controller.batchResults();
      final batchError = widget.controller.batchError;
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(strings.batchTitle, style: theme.textTheme.headlineMedium),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            strings.batchDescription,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        children: <Widget>[
                          OutlinedButton.icon(
                            onPressed: results.isEmpty
                                ? null
                                : () => _copyExport(BatchExportFormat.csv),
                            icon: const Icon(Icons.content_copy_outlined),
                            label: Text(strings.copyCsv),
                          ),
                          OutlinedButton.icon(
                            onPressed: results.isEmpty
                                ? null
                                : () => _copyExport(BatchExportFormat.tsv),
                            icon: const Icon(Icons.table_view_outlined),
                            label: Text(strings.copyTsv),
                          ),
                          OutlinedButton.icon(
                            onPressed: results.isEmpty
                                ? null
                                : () => _copyExport(BatchExportFormat.json),
                            icon: const Icon(Icons.data_object_outlined),
                            label: Text(strings.copyJson),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final horizontal = constraints.maxWidth >= 720;
                          final fields = <Widget>[
                            _BatchField<UnitCategory>(
                              label: strings.categoryLabel,
                              value: widget.controller.category,
                              items: UnitCategory.values,
                              labelFor: (value) => value.localizedLabel(strings),
                              onChanged: (value) {
                                if (value != null) {
                                  widget.controller.setCategory(value);
                                }
                              },
                            ),
                            _BatchField<String>(
                              label: strings.sourceUnitLabel,
                              value: widget.controller.fromUnitId,
                              items: units.map((unit) => unit.id).toList(growable: false),
                              labelFor: (id) {
                                final unit = units.firstWhere((candidate) => candidate.id == id);
                                return '${unit.name} (${unit.symbol})';
                              },
                              onChanged: (value) {
                                if (value != null) {
                                  widget.controller.setFromUnit(value);
                                }
                              },
                            ),
                            TextField(
                              controller: _inputController,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                                signed: true,
                              ),
                              decoration: InputDecoration(
                                labelText: strings.valueLabel,
                                errorText: widget.controller.error,
                              ),
                              onChanged: widget.controller.setInput,
                            ),
                          ];

                          if (!horizontal) {
                            return Column(
                              children: <Widget>[
                                for (var index = 0; index < fields.length; index++) ...<Widget>[
                                  fields[index],
                                  if (index != fields.length - 1)
                                    const SizedBox(height: AppSpacing.md),
                                ],
                              ],
                            );
                          }
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var index = 0; index < fields.length; index++) ...<Widget>[
                                Expanded(child: fields[index]),
                                if (index != fields.length - 1)
                                  const SizedBox(width: AppSpacing.md),
                              ],
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: batchError != null
                          ? Semantics(
                              liveRegion: true,
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Column(
                                  children: <Widget>[
                                    Icon(
                                      Icons.error_outline,
                                      size: 42,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      batchError,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : results.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              child: Column(
                                children: <Widget>[
                                  Icon(
                                    Icons.table_rows_outlined,
                                    size: 42,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    strings.batchEmpty,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: <DataColumn>[
                                  DataColumn(label: Text(strings.batchUnitColumn)),
                                  DataColumn(label: Text(strings.batchSymbolColumn)),
                                  DataColumn(label: Text(strings.batchValueColumn), numeric: true),
                                ],
                                rows: results
                                    .map(
                                      (result) => DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text(result.to.name)),
                                          DataCell(Text(result.to.symbol)),
                                          DataCell(
                                            SelectableText(
                                              widget.controller.formatBatchValue(result.output),
                                              textAlign: TextAlign.end,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    .toList(growable: false),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );

  Future<void> _copyExport(BatchExportFormat format) async {
    final content = widget.controller.exportBatch(format: format);
    if (content.isEmpty) {
      return;
    }
    await Clipboard.setData(ClipboardData(text: content));
    await widget.controller.recordCurrentConversion();
    if (!mounted) {
      return;
    }
    final label = switch (format) {
      BatchExportFormat.csv => 'CSV',
      BatchExportFormat.tsv => 'TSV',
      BatchExportFormat.json => 'JSON',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).batchCopied(label))),
    );
  }
}

final class _BatchField<T> extends StatelessWidget {
  const _BatchField({
    required this.label,
    required this.value,
    required this.items,
    required this.labelFor,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T value) labelFor;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    label: label,
    value: value == null ? null : labelFor(value as T),
    child: InputDecorator(
      decoration: InputDecoration(labelText: label),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(labelFor(item), overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(growable: false),
          onChanged: onChanged,
        ),
      ),
    ),
  );
}
