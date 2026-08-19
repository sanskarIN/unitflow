import 'dart:math' as math;

import 'unit_model.dart';

class ConversionException implements Exception {
  const ConversionException(this.message);

  final String message;

  @override
  String toString() => message;
}

class Converter {
  const Converter();

  double convert({
    required double value,
    required ConversionUnit from,
    required ConversionUnit to,
  }) {
    if (from.category != to.category) {
      throw const ConversionException('Units must belong to the same category.');
    }

    if (from.category == UnitCategory.temperature) {
      return _convertTemperature(value, from.id, to.id);
    }

    if (to.factorToBase == 0) {
      throw const ConversionException('Destination unit has an invalid zero factor.');
    }

    return value * from.factorToBase / to.factorToBase;
  }

  List<double> batchConvert({
    required Iterable<double> values,
    required ConversionUnit from,
    required ConversionUnit to,
  }) {
    return values
        .map((double value) => convert(value: value, from: from, to: to))
        .toList(growable: false);
  }

  String format(
    double value, {
    int decimalPlaces = 8,
    bool scientific = false,
  }) {
    final int safePlaces = decimalPlaces.clamp(0, 15).toInt();
    if (value.isNaN || value.isInfinite) {
      return value.toString();
    }
    if (scientific) {
      return value.toStringAsExponential(safePlaces);
    }

    final String fixed = value.toStringAsFixed(safePlaces);
    if (!fixed.contains('.')) {
      return fixed;
    }
    return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  double round(double value, int decimalPlaces) {
    final int safePlaces = decimalPlaces.clamp(0, 15).toInt();
    final double scale = math.pow(10, safePlaces).toDouble();
    return (value * scale).roundToDouble() / scale;
  }

  double _convertTemperature(double value, String from, String to) {
    if (from == to) {
      return value;
    }

    final double kelvin = switch (from) {
      'kelvin' => value,
      'celsius' => value + 273.15,
      'fahrenheit' => (value + 459.67) * 5 / 9,
      _ => throw ConversionException('Unknown temperature unit: $from'),
    };

    return switch (to) {
      'kelvin' => kelvin,
      'celsius' => kelvin - 273.15,
      'fahrenheit' => kelvin * 9 / 5 - 459.67,
      _ => throw ConversionException('Unknown temperature unit: $to'),
    };
  }
}
