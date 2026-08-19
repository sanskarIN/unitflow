import '../math/exact_decimal.dart';

/// Stable Flutter-side contract for a future native Rust bridge.
///
/// Decimal values cross this boundary as text so generated bindings never need
/// to represent conversion values with binary floating point.
enum NativeBridgeRoundMode {
  nearestEven,
  halfAwayFromZero,
  towardZero,
  awayFromZero,
  floor,
  ceiling,
}

final class NativeBridgeConversionRequest {
  const NativeBridgeConversionRequest({
    required this.value,
    required this.fromUnitId,
    required this.toUnitId,
    required this.decimalPlaces,
    required this.roundMode,
  });

  final String value;
  final String fromUnitId;
  final String toUnitId;
  final int? decimalPlaces;
  final NativeBridgeRoundMode roundMode;

  Map<String, Object?> toMap() {
    _requireCanonicalDecimal(value, field: 'value');
    _requireUnitId(fromUnitId, field: 'fromUnitId');
    _requireUnitId(toUnitId, field: 'toUnitId');
    final places = decimalPlaces;
    if (places != null && (places < 0 || places > 28)) {
      throw const FormatException('Invalid native bridge decimal precision.');
    }

    return <String, Object?>{
      'value': value,
      'fromUnitId': fromUnitId,
      'toUnitId': toUnitId,
      'decimalPlaces': decimalPlaces,
      'roundMode': roundMode.name,
    };
  }
}

final class NativeBridgeConversionResponse {
  const NativeBridgeConversionResponse({
    required this.input,
    required this.output,
    required this.fromUnitId,
    required this.toUnitId,
  });

  final String input;
  final String output;
  final String fromUnitId;
  final String toUnitId;

  factory NativeBridgeConversionResponse.fromMap(Map<String, Object?> value) {
    final input = value['input'];
    final output = value['output'];
    final fromUnitId = value['fromUnitId'];
    final toUnitId = value['toUnitId'];
    if (input is! String ||
        output is! String ||
        fromUnitId is! String ||
        toUnitId is! String) {
      throw const FormatException('Invalid native bridge conversion response.');
    }

    _requireCanonicalDecimal(input, field: 'input');
    _requireCanonicalDecimal(output, field: 'output');
    _requireUnitId(fromUnitId, field: 'fromUnitId');
    _requireUnitId(toUnitId, field: 'toUnitId');

    return NativeBridgeConversionResponse(
      input: input,
      output: output,
      fromUnitId: fromUnitId,
      toUnitId: toUnitId,
    );
  }
}

final class NativeBridgeFailure implements Exception {
  const NativeBridgeFailure({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'NativeBridgeFailure($code)';
}

abstract interface class NativeConversionBridge {
  /// Version of the request/response contract, independent of app version.
  int get protocolVersion;

  /// Diagnostic backend identifier such as `rust-native`.
  String get backendId;

  Future<NativeBridgeConversionResponse> convert(
    NativeBridgeConversionRequest request,
  );
}

void _requireCanonicalDecimal(String value, {required String field}) {
  if (value.isEmpty || value.length > 1024) {
    throw FormatException('Invalid native bridge decimal field: $field.');
  }
  try {
    final parsed = ExactDecimal.parse(value);
    if (parsed.toCanonicalString() != value) {
      throw FormatException('Non-canonical native bridge decimal field: $field.');
    }
  } on FormatException {
    throw FormatException('Invalid native bridge decimal field: $field.');
  }
}

void _requireUnitId(String value, {required String field}) {
  if (!RegExp(r'^[a-z0-9_-]{1,64}$').hasMatch(value)) {
    throw FormatException('Invalid native bridge unit identifier: $field.');
  }
}
