import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/bridge/native_conversion_bridge.dart';

void main() {
  test('bridge request keeps decimal values as strings', () {
    const request = NativeBridgeConversionRequest(
      value: '1234567890.000000000123',
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
      decimalPlaces: 18,
      roundMode: NativeBridgeRoundMode.nearestEven,
    );

    final encoded = request.toMap();

    expect(encoded['value'], '1234567890.000000000123');
    expect(encoded['value'], isA<String>());
    expect(encoded['decimalPlaces'], 18);
    expect(encoded['roundMode'], 'nearestEven');
  });

  test('bridge response validates stable unit identifiers', () {
    final response = NativeBridgeConversionResponse.fromMap(
      const <String, Object?>{
        'input': '1000',
        'output': '1',
        'fromUnitId': 'meter',
        'toUnitId': 'kilometer',
      },
    );

    expect(response.input, '1000');
    expect(response.output, '1');
    expect(response.fromUnitId, 'meter');
    expect(response.toUnitId, 'kilometer');
  });

  test('bridge response rejects malformed payloads', () {
    expect(
      () => NativeBridgeConversionResponse.fromMap(
        const <String, Object?>{
          'input': 1000,
          'output': '1',
          'fromUnitId': 'meter',
          'toUnitId': 'kilometer',
        },
      ),
      throwsFormatException,
    );
  });

  test('bridge failures avoid embedding arbitrary details in toString', () {
    const failure = NativeBridgeFailure(
      code: 'invalid_decimal',
      message: 'Internal detail that belongs to a safe presentation boundary.',
    );

    expect(failure.toString(), 'NativeBridgeFailure(invalid_decimal)');
    expect(failure.toString(), isNot(contains(failure.message)));
  });
}
