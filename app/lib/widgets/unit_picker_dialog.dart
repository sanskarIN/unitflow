import 'package:flutter/material.dart';

import '../core/unit_model.dart';

Future<ConversionUnit?> showUnitPickerDialog({
  required BuildContext context,
  required String title,
  required List<ConversionUnit> units,
  required ConversionUnit selected,
}) {
  String query = '';

  return showDialog<ConversionUnit>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          final List<ConversionUnit> filtered = units
              .where((ConversionUnit unit) => unit.matches(query))
              .toList(growable: false);

          return AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 520,
              height: 520,
              child: Column(
                children: <Widget>[
                  TextField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search units',
                      hintText: 'Name, symbol, alias, or description',
                    ),
                    onChanged: (String value) {
                      setState(() {
                        query = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text('No matching units.'))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (BuildContext context, int index) {
                              final ConversionUnit unit = filtered[index];
                              return ListTile(
                                selected: unit.id == selected.id,
                                leading: CircleAvatar(child: Text(unit.symbol)),
                                title: Text(unit.name),
                                subtitle: Text(unit.description),
                                trailing: unit.id == selected.id
                                    ? const Icon(Icons.check_circle)
                                    : null,
                                onTap: () => Navigator.of(context).pop(unit),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          );
        },
      );
    },
  );
}
