import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/app_state.dart';

Future<void> showBatchConversionDialog({
  required BuildContext context,
  required AppState state,
}) async {
  final TextEditingController controller = TextEditingController();
  List<String> results = const <String>[];

  await showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text('Batch conversion'),
            content: SizedBox(
              width: 620,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Convert multiple values from ${state.from.symbol} to ${state.to.symbol}. Enter one value per line.',
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: controller,
                      minLines: 6,
                      maxLines: 10,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '1\n2.5\n100',
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          results = state.batchConvert(controller.text.split('\n'));
                        });
                      },
                      icon: const Icon(Icons.calculate_outlined),
                      label: const Text('Convert batch'),
                    ),
                    if (results.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 16),
                      SelectableText(results.join('\n')),
                    ],
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              if (results.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: results.join('\n')));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Batch results copied.')),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy'),
                ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    },
  );

  controller.dispose();
}
