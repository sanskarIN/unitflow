import 'package:intl/intl.dart';

import '../math/exact_decimal.dart';

enum DecimalNotation { plain, scientific, engineering }

final class DecimalInputParser {
  const DecimalInputParser();

  ExactDecimal parse(String input, {required String localeName}) {
    final symbols = NumberFormat.decimalPattern(localeName).symbols;
    var canonical = input.trim();

    final grouping = symbols.GROUP_SEP;
    if (grouping.isNotEmpty) {
      canonical = canonical.replaceAll(grouping, '');
    }
    // Some locales use NBSP/narrow-NBSP for grouping while keyboards provide spaces.
    if (grouping.contains('\u00a0') || grouping.contains('\u202f')) {
      canonical = canonical.replaceAll(' ', '');
    }

    final decimal = symbols.DECIMAL_SEP;
    if (decimal != '.') {
      canonical = canonical.replaceAll(decimal, '.');
    }
    return ExactDecimal.parse(canonical);
  }
}

final class DecimalDisplayFormatter {
  const DecimalDisplayFormatter();

  String format(
    ExactDecimal value, {
    required String localeName,
    DecimalNotation notation = DecimalNotation.plain,
    bool useGrouping = true,
  }) {
    final canonical = switch (notation) {
      DecimalNotation.plain => value.toCanonicalString(),
      DecimalNotation.scientific => _scientific(value),
      DecimalNotation.engineering => _engineering(value),
    };
    if (notation != DecimalNotation.plain) {
      return _localizeMantissa(canonical, localeName);
    }
    return _localizePlain(canonical, localeName, useGrouping: useGrouping);
  }

  String _localizePlain(
    String canonical,
    String localeName, {
    required bool useGrouping,
  }) {
    final symbols = NumberFormat.decimalPattern(localeName).symbols;
    final negative = canonical.startsWith('-');
    final unsigned = negative ? canonical.substring(1) : canonical;
    final parts = unsigned.split('.');
    var whole = parts[0];

    if (useGrouping && symbols.GROUP_SEP.isNotEmpty) {
      final grouping = _groupingSizes(symbols.DECIMAL_PATTERN);
      whole = _groupWhole(
        whole,
        separator: symbols.GROUP_SEP,
        primarySize: grouping.$1,
        secondarySize: grouping.$2,
      );
    }

    final fraction = parts.length == 2 ? '${symbols.DECIMAL_SEP}${parts[1]}' : '';
    return '${negative ? '-' : ''}$whole$fraction';
  }

  String _localizeMantissa(String formatted, String localeName) {
    final separator = NumberFormat.decimalPattern(localeName).symbols.DECIMAL_SEP;
    if (separator == '.') {
      return formatted;
    }
    final exponentIndex = formatted.indexOf('e');
    if (exponentIndex < 0) {
      return formatted.replaceFirst('.', separator);
    }
    final mantissa = formatted.substring(0, exponentIndex).replaceFirst('.', separator);
    return '$mantissa${formatted.substring(exponentIndex)}';
  }

  String _scientific(ExactDecimal value) {
    if (value.isZero) {
      return '0';
    }
    final negative = value.coefficient.isNegative;
    final digits = value.coefficient.abs().toString();
    final exponent = digits.length - 1 - value.scale;
    final mantissa = digits.length == 1 ? digits : '${digits[0]}.${digits.substring(1)}';
    return '${negative ? '-' : ''}$mantissa${_exponent(exponent)}';
  }

  String _engineering(ExactDecimal value) {
    if (value.isZero) {
      return '0';
    }
    final negative = value.coefficient.isNegative;
    var digits = value.coefficient.abs().toString();
    final exponent = digits.length - 1 - value.scale;
    final engineeringExponent = _floorDiv(exponent, 3) * 3;
    final integerDigits = exponent - engineeringExponent + 1;
    if (digits.length < integerDigits) {
      digits = digits.padRight(integerDigits, '0');
    }
    final mantissa = digits.length == integerDigits
        ? digits
        : '${digits.substring(0, integerDigits)}.${digits.substring(integerDigits)}';
    return '${negative ? '-' : ''}$mantissa${_exponent(engineeringExponent)}';
  }

  String _exponent(int exponent) => 'e${exponent >= 0 ? '+' : ''}$exponent';

  int _floorDiv(int value, int divisor) {
    final quotient = value ~/ divisor;
    final remainder = value.remainder(divisor);
    return remainder < 0 ? quotient - 1 : quotient;
  }

  (int, int) _groupingSizes(String decimalPattern) {
    final positivePattern = decimalPattern.split(';').first;
    final integerPattern = positivePattern.split('.').first;
    final groups = integerPattern.split(',');
    if (groups.length < 2) {
      return (0, 0);
    }

    final primary = _digitPlaceholders(groups.last);
    if (primary <= 0) {
      return (0, 0);
    }
    final secondary = groups.length >= 3 ? _digitPlaceholders(groups[groups.length - 2]) : primary;
    return (primary, secondary > 0 ? secondary : primary);
  }

  int _digitPlaceholders(String patternPart) =>
      patternPart.split('').where((character) => character == '#' || character == '0').length;

  String _groupWhole(
    String whole, {
    required String separator,
    required int primarySize,
    required int secondarySize,
  }) {
    if (primarySize <= 0 || secondarySize <= 0 || whole.length <= primarySize) {
      return whole;
    }

    final chunks = <String>[];
    var end = whole.length;
    var size = primarySize;
    while (end > 0) {
      final candidate = end - size;
      final start = candidate < 0 ? 0 : candidate;
      chunks.add(whole.substring(start, end));
      end = start;
      size = secondarySize;
    }
    return chunks.reversed.join(separator);
  }
}
