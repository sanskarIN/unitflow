/// Decimal rounding modes mirrored by the Rust domain API.
enum DecimalRoundingMode {
  nearestEven,
  halfAwayFromZero,
  towardZero,
  awayFromZero,
  floor,
  ceiling,
}

/// Arbitrary-precision base-10 decimal used by the deterministic Dart fallback.
///
/// Production native builds are intended to use the Rust core through the bridge. This
/// implementation keeps widget/web tests and bridge-unavailable states deterministic without
/// converting values through binary floating point.
final class ExactDecimal implements Comparable<ExactDecimal> {
  factory ExactDecimal(BigInt coefficient, int scale) {
    if (scale < 0) {
      throw ArgumentError.value(scale, 'scale', 'must be non-negative');
    }
    return _normalized(coefficient, scale);
  }

  factory ExactDecimal.parse(String source) {
    final input = source.trim();
    if (input.isEmpty || input.length > 1024) {
      throw const FormatException('Invalid decimal input');
    }

    final match = RegExp(
      r'^([+-]?)(\d*)(?:\.(\d*))?(?:[eE]([+-]?\d+))?$',
    ).firstMatch(input);
    if (match == null) {
      throw const FormatException('Invalid decimal input');
    }

    final whole = match.group(2) ?? '';
    final fraction = match.group(3) ?? '';
    if (whole.isEmpty && fraction.isEmpty) {
      throw const FormatException('Invalid decimal input');
    }

    final exponent = int.tryParse(match.group(4) ?? '0');
    if (exponent == null || exponent.abs() > 1000) {
      throw const FormatException('Decimal exponent is out of range');
    }

    final digits = '${whole.isEmpty ? '0' : whole}$fraction';
    var coefficient = BigInt.parse(digits);
    if (match.group(1) == '-') {
      coefficient = -coefficient;
    }

    var scale = fraction.length - exponent;
    if (scale < 0) {
      coefficient *= _pow10(-scale);
      scale = 0;
    }
    return _normalized(coefficient, scale);
  }

  const ExactDecimal._(this.coefficient, this.scale);

  /// Canonical zero. BigInt values are runtime objects, so this cannot be a Dart `const`.
  static final ExactDecimal zero = ExactDecimal._(BigInt.zero, 0);

  final BigInt coefficient;
  final int scale;

  bool get isZero => coefficient == BigInt.zero;

  int get sign => coefficient.sign;

  ExactDecimal get abs => coefficient.isNegative ? -this : this;

  ExactDecimal operator -() => ExactDecimal(-coefficient, scale);

  ExactDecimal operator +(ExactDecimal other) {
    final targetScale = scale > other.scale ? scale : other.scale;
    final left = coefficient * _pow10(targetScale - scale);
    final right = other.coefficient * _pow10(targetScale - other.scale);
    return ExactDecimal(left + right, targetScale);
  }

  ExactDecimal operator -(ExactDecimal other) => this + (-other);

  ExactDecimal operator *(ExactDecimal other) =>
      ExactDecimal(coefficient * other.coefficient, scale + other.scale);

  /// Divides with an explicit number of fractional decimal digits.
  ExactDecimal divide(
    ExactDecimal other, {
    int precision = 28,
    DecimalRoundingMode rounding = DecimalRoundingMode.nearestEven,
  }) {
    if (other.isZero) {
      throw IntegerDivisionByZeroException();
    }
    if (precision < 0 || precision > 1000) {
      throw RangeError.range(precision, 0, 1000, 'precision');
    }

    var numerator = coefficient;
    var denominator = other.coefficient;
    final shift = precision + other.scale - scale;
    if (shift >= 0) {
      numerator *= _pow10(shift);
    } else {
      denominator *= _pow10(-shift);
    }

    var quotient = numerator ~/ denominator;
    final remainder = numerator.remainder(denominator).abs();
    quotient = _roundQuotient(
      quotient,
      remainder,
      denominator.abs(),
      numerator.sign * denominator.sign,
      rounding,
    );
    return ExactDecimal(quotient, precision);
  }

  ExactDecimal round(
    int fractionDigits, {
    DecimalRoundingMode mode = DecimalRoundingMode.nearestEven,
  }) {
    if (fractionDigits < 0) {
      throw RangeError.value(fractionDigits, 'fractionDigits');
    }
    if (scale <= fractionDigits) {
      return this;
    }

    final divisor = _pow10(scale - fractionDigits);
    var quotient = coefficient ~/ divisor;
    quotient = _roundQuotient(
      quotient,
      coefficient.remainder(divisor).abs(),
      divisor,
      coefficient.sign,
      mode,
    );
    return ExactDecimal(quotient, fractionDigits);
  }

  String toFixed(
    int fractionDigits, {
    DecimalRoundingMode mode = DecimalRoundingMode.nearestEven,
  }) {
    final rounded = round(fractionDigits, mode: mode);
    final negative = rounded.coefficient.isNegative;
    var digits = rounded.coefficient.abs().toString();

    if (fractionDigits == 0) {
      return '${negative ? '-' : ''}$digits';
    }

    final required = fractionDigits + 1;
    if (digits.length < required) {
      digits = digits.padLeft(required, '0');
    }
    final split = digits.length - fractionDigits;
    return '${negative ? '-' : ''}${digits.substring(0, split)}.${digits.substring(split)}';
  }

  String toCanonicalString() {
    if (scale == 0) {
      return coefficient.toString();
    }

    final negative = coefficient.isNegative;
    var digits = coefficient.abs().toString();
    if (digits.length <= scale) {
      digits = digits.padLeft(scale + 1, '0');
    }
    final split = digits.length - scale;
    return '${negative ? '-' : ''}${digits.substring(0, split)}.${digits.substring(split)}';
  }

  @override
  String toString() => toCanonicalString();

  @override
  int compareTo(ExactDecimal other) {
    final targetScale = scale > other.scale ? scale : other.scale;
    return (coefficient * _pow10(targetScale - scale)).compareTo(
      other.coefficient * _pow10(targetScale - other.scale),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ExactDecimal &&
      coefficient == other.coefficient &&
      scale == other.scale;

  @override
  int get hashCode => Object.hash(coefficient, scale);

  static ExactDecimal _normalized(BigInt coefficient, int scale) {
    if (coefficient == BigInt.zero) {
      return zero;
    }
    while (scale > 0 && coefficient.remainder(BigInt.from(10)) == BigInt.zero) {
      coefficient ~/= BigInt.from(10);
      scale -= 1;
    }
    return ExactDecimal._(coefficient, scale);
  }
}

BigInt _pow10(int exponent) {
  if (exponent < 0) {
    throw ArgumentError.value(exponent, 'exponent', 'must be non-negative');
  }
  var result = BigInt.one;
  var base = BigInt.from(10);
  var power = exponent;
  while (power > 0) {
    if (power.isOdd) {
      result *= base;
    }
    power ~/= 2;
    if (power > 0) {
      base *= base;
    }
  }
  return result;
}

BigInt _roundQuotient(
  BigInt quotient,
  BigInt remainder,
  BigInt divisor,
  int resultSign,
  DecimalRoundingMode mode,
) {
  if (remainder == BigInt.zero) {
    return quotient;
  }

  final direction = BigInt.from(resultSign < 0 ? -1 : 1);
  switch (mode) {
    case DecimalRoundingMode.towardZero:
      return quotient;
    case DecimalRoundingMode.awayFromZero:
      return quotient + direction;
    case DecimalRoundingMode.floor:
      return resultSign < 0 ? quotient - BigInt.one : quotient;
    case DecimalRoundingMode.ceiling:
      return resultSign > 0 ? quotient + BigInt.one : quotient;
    case DecimalRoundingMode.halfAwayFromZero:
      return remainder * BigInt.two >= divisor
          ? quotient + direction
          : quotient;
    case DecimalRoundingMode.nearestEven:
      final doubled = remainder * BigInt.two;
      if (doubled > divisor) {
        return quotient + direction;
      }
      if (doubled < divisor) {
        return quotient;
      }
      return quotient.abs().isOdd ? quotient + direction : quotient;
  }
}
