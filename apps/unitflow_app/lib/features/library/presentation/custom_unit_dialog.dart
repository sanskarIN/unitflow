import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/persistence/user_state.dart';
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
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Create custom unit'),
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
                'Define a safe affine relationship: base = value × scale + offset.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<UnitCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
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
                decoration: const InputDecoration(
                  labelText: 'Stable ID',
                  hintText: 'my_custom_unit',
                ),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  final id = value?.trim() ?? '';
                  return RegExp(r'^[a-z0-9_-]{1,64}$').hasMatch(id)
                      ? null
                      : 'Use 1–64 lowercase letters, digits, _ or -.';
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                textInputAction: TextInputAction.next,
                maxLength: 128,
                validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter a name.' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _symbolController,
                decoration: const InputDecoration(labelText: 'Symbol'),
                textInputAction: TextInputAction.next,
                maxLength: 32,
                validator: (value) => (value?.trim().isEmpty ?? true) ? 'Enter a symbol.' : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _scaleController,
                      decoration: const InputDecoration(labelText: 'Scale'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true) ? 'Required.' : null,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: TextFormField(
                      controller: _offsetController,
                      decoration: const InputDecoration(labelText: 'Offset'),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) => (value?.trim().isEmpty ?? true) ? 'Required.' : null,
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
                decoration: const InputDecoration(
                  labelText: 'Aliases',
                  hintText: 'comma, separated, aliases',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
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
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _submit,
        child: const Text('Create unit'),
      ),
    ],
  );

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
    } on FormatException catch (error) {
      setState(() => _formulaError = error.message);
      return;
    }
    Navigator.of(context).pop(data);
  }
}
