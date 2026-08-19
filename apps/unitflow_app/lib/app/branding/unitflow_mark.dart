import 'package:flutter/material.dart';

/// Scalable UnitFlow brand mark built from framework primitives so it remains
/// crisp offline and does not require a runtime image or icon dependency.
final class UnitFlowMark extends StatelessWidget {
  const UnitFlowMark({
    super.key,
    this.size = 40,
    this.semanticLabel,
    this.showBackground = true,
  });

  final double size;
  final String? semanticLabel;
  final bool showBackground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final mark = SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: showBackground ? scheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(size * 0.24),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Icon(
              Icons.swap_horiz_rounded,
              size: size * 0.64,
              color: showBackground ? scheme.onPrimaryContainer : scheme.primary,
            ),
            Positioned(
              right: size * 0.12,
              top: size * 0.10,
              child: Container(
                width: size * 0.17,
                height: size * 0.17,
                decoration: BoxDecoration(
                  color: scheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (semanticLabel == null) {
      return ExcludeSemantics(child: mark);
    }
    return Semantics(image: true, label: semanticLabel, child: mark);
  }
}
