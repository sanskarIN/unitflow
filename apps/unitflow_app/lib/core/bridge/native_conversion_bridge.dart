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

  Map<String, Object?> toMap() => <String, Object?>{
    'value': value,
    'fromUnitId': fromUnitId,
    'toUnitId': toUnitId,
    'decimalPlaces': decimalPlaces,
    'roundMode': roundMode.name,
  };
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
        toUnitId is! String ||
        input.length > 1024 ||
        output.length > 1024 ||
        fromUnitId.isEmpty ||
        fromUnitId.length > 64 ||
        toUnitId.isEmpty ||
        toUnitId.length > 64) {
      throw const FormatException('Invalid native bridge conversion response.');
    }
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
