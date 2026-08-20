import '../../../core/math/exact_decimal.dart';
import '../data/unit_catalog.dart';
import 'unit_models.dart';

/// Maximum targets accepted by one conversion-engine batch request.
const int maxBatchConversionTargets = 256;

abstract interface class ConversionEngine {
  UnitCatalog get catalog;

  ConversionResult convert({
    required ExactDecimal value,
    required String fromUnitId,
    required String toUnitId,
    int decimalPlaces = 12,
    DecimalRoundingMode rounding = DecimalRoundingMode.nearestEven,
  });

  List<ConversionResult> batchConvert({
    required ExactDecimal value,
    required String fromUnitId,
    required Iterable<String> toUnitIds,
    int decimalPlaces = 12,
    DecimalRoundingMode rounding = DecimalRoundingMode.nearestEven,
  });
}

/// Deterministic fallback engine for web/tests and graceful startup before Rust bindings load.
/// Native production integration can implement [ConversionEngine] with generated Rust bindings
/// without changing presentation code.
final class ExactConversionEngine implements ConversionEngine {
  ExactConversionEngine({UnitCatalog? catalog}) : catalog = catalog ?? UnitCatalog();

  @override
  final UnitCatalog catalog;

  @override
  ConversionResult convert({
    required ExactDecimal value,
    required String fromUnitId,
    required String toUnitId,
    int decimalPlaces = 12,
    DecimalRoundingMode rounding = DecimalRoundingMode.nearestEven,
  }) {
    _validateDecimalPlaces(decimalPlaces);

    final from = catalog.byId(fromUnitId);
    final to = catalog.byId(toUnitId);
    if (from == null) {
      throw ConversionFailure('Unknown source unit: $fromUnitId');
    }
    if (to == null) {
      throw ConversionFailure('Unknown target unit: $toUnitId');
    }
    if (from.category != to.category) {
      throw ConversionFailure('Units must belong to the same category.');
    }
    if (to.scale.isZero) {
      throw ConversionFailure('Target unit has an invalid zero scale.');
    }

    final base = (value * from.scale) + from.offset;
    final output = (base - to.offset)
        .divide(to.scale, precision: 28, rounding: rounding)
        .round(decimalPlaces, mode: rounding);

    return ConversionResult(input: value, output: output, from: from, to: to);
  }

  @override
  List<ConversionResult> batchConvert({
    required ExactDecimal value,
    required String fromUnitId,
    required Iterable<String> toUnitIds,
    int decimalPlaces = 12,
    DecimalRoundingMode rounding = DecimalRoundingMode.nearestEven,
  }) {
    _validateDecimalPlaces(decimalPlaces);
    final targets = toUnitIds.take(maxBatchConversionTargets + 1).toList(growable: false);
    if (targets.length > maxBatchConversionTargets) {
      throw const ConversionFailure('Batch conversion supports at most 256 target units.');
    }

    return targets
        .map(
          (toUnitId) => convert(
            value: value,
            fromUnitId: fromUnitId,
            toUnitId: toUnitId,
            decimalPlaces: decimalPlaces,
            rounding: rounding,
          ),
        )
        .toList(growable: false);
  }
}

void _validateDecimalPlaces(int decimalPlaces) {
  if (decimalPlaces < 0 || decimalPlaces > 28) {
    throw const ConversionFailure('Decimal places must be between 0 and 28.');
  }
}

final class ConversionFailure implements Exception {
  const ConversionFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
