import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/unit_model.dart';
import '../state/app_state.dart';
import 'batch_conversion_dialog.dart';
import 'settings_sheet.dart';
import 'unit_picker_dialog.dart';

class ConverterCard extends StatelessWidget {
  const ConverterCard({
    required this.state,
    required this.inputController,
    super.key,
  });

  final AppState state;
  final TextEditingController inputController;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final List<ConversionUnit> units = state.availableUnits;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('Converter', style: theme.textTheme.headlineSmall),
                ),
                IconButton(
                  tooltip: 'Display settings',
                  onPressed: () => showSettingsSheet(context: context, state: state),
                  icon: const Icon(Icons.tune),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: inputController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                labelText: 'Value',
                errorText: state.error,
                prefixIcon: const Icon(Icons.pin_outlined),
                suffixText: state.from.symbol,
              ),
              onChanged: state.setInput,
              onSubmitted: (_) => state.commitInput(),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final bool narrow = constraints.maxWidth < 620;
                final Widget fromButton = _UnitButton(
                  label: 'From',
                  unit: state.from,
                  onPressed: () => _pickUnit(context, units, true),
                );
                final Widget toButton = _UnitButton(
                  label: 'To',
                  unit: state.to,
                  onPressed: () => _pickUnit(context, units, false),
                );
                final Widget swap = Semantics(
                  button: true,
                  label: 'Swap source and destination units',
                  child: IconButton.filledTonal(
                    tooltip: 'Swap units',
                    onPressed: () {
                      state.swapUnits();
                      inputController.text = state.input;
                      inputController.selection = TextSelection.collapsed(
                        offset: inputController.text.length,
                      );
                    },
                    icon: Icon(narrow ? Icons.swap_vert : Icons.swap_horiz),
                  ),
                );

                if (narrow) {
                  return Column(
                    children: <Widget>[
                      fromButton,
                      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: swap),
                      toButton,
                    ],
                  );
                }

                return Row(
                  children: <Widget>[
                    Expanded(child: fromButton),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 12), child: swap),
                    Expanded(child: toButton),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: theme.colorScheme.primaryContainer,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text('Result', style: theme.textTheme.labelLarge),
                  const SizedBox(height: 6),
                  SelectableText(
                    state.output.isEmpty ? '—' : '${state.output} ${state.to.symbol}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: <Widget>[
                      FilledButton.tonalIcon(
                        onPressed: state.output.isEmpty ? null : () => _copyResult(context),
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text('Copy'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: state.toggleCurrentFavorite,
                        icon: Icon(
                          state.isCurrentPairFavorite ? Icons.star : Icons.star_border,
                        ),
                        label: Text(state.isCurrentPairFavorite ? 'Favorited' : 'Favorite pair'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => showBatchConversionDialog(context: context, state: state),
                        icon: const Icon(Icons.table_rows_outlined),
                        label: const Text('Batch'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _Explanation(state: state),
          ],
        ),
      ),
    );
  }

  Future<void> _pickUnit(
    BuildContext context,
    List<ConversionUnit> units,
    bool pickingFrom,
  ) async {
    final ConversionUnit? selected = await showUnitPickerDialog(
      context: context,
      title: pickingFrom ? 'Choose source unit' : 'Choose destination unit',
      units: units,
      selected: pickingFrom ? state.from : state.to,
    );
    if (selected == null) {
      return;
    }
    if (pickingFrom) {
      state.setFrom(selected);
    } else {
      state.setTo(selected);
    }
  }

  void _copyResult(BuildContext context) {
    final String text = '${state.output} ${state.to.symbol}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Result copied.')),
    );
  }
}

class _UnitButton extends StatelessWidget {
  const _UnitButton({
    required this.label,
    required this.unit,
    required this.onPressed,
  });

  final String label;
  final ConversionUnit unit;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label unit: ${unit.name}',
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          alignment: Alignment.centerLeft,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(label, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(unit.displayName, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.expand_more),
          ],
        ),
      ),
    );
  }
}

class _Explanation extends StatelessWidget {
  const _Explanation({required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: const Text('How this conversion works'),
      subtitle: Text('${state.from.name} → ${state.to.name}'),
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(state.from.description),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(state.to.description),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            state.category == UnitCategory.temperature
                ? 'Temperature conversions use an affine scale transformation through kelvin.'
                : 'Linear conversions pass through the category base unit using each unit factor.',
          ),
        ),
      ],
    );
  }
}
