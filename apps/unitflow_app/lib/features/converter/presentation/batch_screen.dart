import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/app_theme.dart';
import '../domain/batch_export.dart';
import '../domain/unit_models.dart';
import 'converter_controller.dart';

final class BatchScreen extends StatefulWidget {
  const BatchScreen({required this.controller, super.key});

  final ConverterController controller;

  @override
  State<BatchScreen> createState() => _BatchScreenState();
}

final class _BatchScreenState extends State<BatchScreen> {
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
    builder: (context, _) {
      final theme = Theme.of(context);
      final units = widget.controller.categoryUnits;
      final results = widget.controller.batchResults();
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
                          Text('Batch conversion', style: theme.textTheme.headlineMedium),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Convert one value to every compatible unit in the selected category.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: AppSpacing.xs,
                        children: <Widget>[
                          OutlinedButton.icon(
                            onPressed: results.isEmpty
                                ? null
                                : () => _copyExport(BatchExportFormat.csv),
                            icon: const Icon(Icons.content_copy_outlined),
                            label: const Text('Copy CSV'),
                          ),
                          OutlinedButton.icon(
                            onPressed: results.isEmpty
                                ? null
                                : () => _copyExport(BatchExportFormat.tsv),
                            icon: const Icon(Icons.table_view_outlined),
                            label: const Text('Copy TSV'),
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
                              label: 'Category',
                              value: widget.controller.category,
                              items: UnitCategory.values,
                              labelFor: (value) => value.label,
                              onChanged: (value) {
                                if (value != null) {
                                  widget.controller.setCategory(value);
                                }
                              },
                            ),
                            _BatchField<String>(
                              label: 'Source unit',
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
                                labelText: 'Value',
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
                      child: results.isEmpty
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
                                  const Text(
                                    'Enter a valid value to generate the batch table.',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columns: const <DataColumn>[
                                  DataColumn(label: Text('Unit')),
                                  DataColumn(label: Text('Symbol')),
                                  DataColumn(label: Text('Value'), numeric: true),
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
    final label = format == BatchExportFormat.csv ? 'CSV' : 'TSV';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label batch table copied.')),
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
                child: Text(labelFor(item), overflow: TextOverflow.ellipsis),
              ),
            )
            .toList(growable: false),
        onChanged: onChanged,
      ),
    ),
  );
}
