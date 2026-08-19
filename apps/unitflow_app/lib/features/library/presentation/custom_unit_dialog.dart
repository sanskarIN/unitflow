import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/persistence/user_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../converter/domain/unit_models.dart';

Future<CustomUnitData?> showCustomUnitDialog(
  BuildContext context, {
  UnitCategory initialCategory = UnitCategory.length,
}) => showDialog<CustomUnitData>(
  context: context,
  builder: (context) => _CustomUnitDialog(initialCategory: initialCategory),
);

final class _CustomUnitDialog extends StatefulWidget {
  const _CustomUnitDialog({required this.initialCategory});

  final UnitCategory initialCategory;

  @override
  State<_CustomUnitDialog> createState() => _CustomUnitDialogState();
}

final class _CustomUnitDialogState extends State<_CustomUnitDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  final _symbolController = TextEditingController();
  final _scaleController = TextEditingController(text: '1');
  final _offsetController = TextEditingController(text: '0');
  final _aliasesController = TextEditingController();
  final _descriptionController = TextEditingController();
  late UnitCategory _category = widget.initialCategory;
  String? _formulaError;

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _symbolController.dispose();
    _scaleController.dispose();
    _offsetController.dispose();
    _aliasesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(strings.createCustomUnit),
      content: SizedBox(
        width: 560,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  strings.customUnitFormulaHelp,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                DropdownButtonFormField<UnitCategory>(
                  initialValue: _category,
                  decoration: InputDecoration(labelText: strings.category),
                  items: UnitCategory.values
                      .map(
                        (category) => DropdownMenuItem<UnitCategory>(
                          value: category,
                          child: Text(category.label),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (category) {
                    if (category != null) {
                      setState(() => _category = category);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(
                    labelText: strings.stableId,
                    hintText: strings.stableIdHint,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final id = value?.trim() ?? '';
                    return RegExp(r'^[a-z0-9_-]{1,64}$').hasMatch(id)
                        ? null
                        : strings.stableIdError;
                  },
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: strings.name),
                  textInputAction: TextInputAction.next,
                  maxLength: 128,
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? strings.nameRequired
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _symbolController,
                  decoration: InputDecoration(labelText: strings.symbol),
                  textInputAction: TextInputAction.next,
                  maxLength: 32,
                  validator: (value) => (value?.trim().isEmpty ?? true)
                      ? strings.symbolRequired
                      : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        controller: _scaleController,
                        decoration: InputDecoration(labelText: strings.scale),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? strings.required
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextFormField(
                        controller: _offsetController,
                        decoration: InputDecoration(labelText: strings.offset),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        validator: (value) => (value?.trim().isEmpty ?? true)
                            ? strings.required
                            : null,
                      ),
                    ),
                  ],
                ),
                if (_formulaError != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _formulaError!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _aliasesController,
                  decoration: InputDecoration(
                    labelText: strings.aliases,
                    hintText: strings.aliasesHint,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(labelText: strings.description),
                  maxLength: 512,
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(strings.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(strings.createUnit)),
      ],
    );
  }

  void _submit() {
    setState(() => _formulaError = null);
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final aliases = _aliasesController.text
        .split(',')
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    final data = CustomUnitData(
      id: _idController.text.trim(),
      category: _category,
      name: _nameController.text.trim(),
      symbol: _symbolController.text.trim(),
      scale: _scaleController.text.trim(),
      offset: _offsetController.text.trim(),
      aliases: aliases,
      description: _descriptionController.text.trim(),
    );
    try {
      data.toUnitDefinition();
    } on FormatException {
      setState(
        () => _formulaError = AppLocalizations.of(context).customUnitCreateFailed,
      );
      return;
    }
    Navigator.of(context).pop(data);
  }
}
