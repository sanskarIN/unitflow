import 'package:flutter/material.dart';

import '../state/app_state.dart';

Future<void> showSettingsSheet({
  required BuildContext context,
  required AppState state,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      return AnimatedBuilder(
        animation: state,
        builder: (BuildContext context, Widget? child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text('Display settings', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  Text('Decimal places: ${state.decimalPlaces}'),
                  Slider(
                    min: 0,
                    max: 15,
                    divisions: 15,
                    value: state.decimalPlaces.toDouble(),
                    label: '${state.decimalPlaces}',
                    onChanged: (double value) => state.setDecimalPlaces(value.round()),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Scientific notation'),
                    subtitle: const Text('Show results using exponential notation.'),
                    value: state.scientific,
                    onChanged: state.setScientific,
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
