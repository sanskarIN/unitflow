import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/bridge/native_conversion_bridge.dart';

void main() {
  test('bridge startup metadata accepts the supported Rust contract', () {
    final info = NativeBridgeInfo.fromMap(
      const <String, Object?>{
        'protocolVersion': 1,
        'backendId': 'rust-core',
        'capabilities': <Object?>[
          'convert',
          'batchConvert',
          'canonicalDecimalText',
        ],
      },
    );

    expect(nativeBridgeProtocolVersion, 1);
    expect(info.protocolVersion, nativeBridgeProtocolVersion);
    expect(info.backendId, 'rust-core');
    expect(info.capabilities, nativeBridgeRequiredCapabilities);
    expect(info.isCompatible, isTrue);
    expect(info.requireCompatible, returnsNormally);
  });

  test('bridge startup metadata fails closed on protocol mismatch', () {
    final info = NativeBridgeInfo.fromMap(
      const <String, Object?>{
        'protocolVersion': 2,
        'backendId': 'rust-core',
        'capabilities': <Object?>[
          'convert',
          'batchConvert',
          'canonicalDecimalText',
        ],
      },
    );

    expect(info.isCompatible, isFalse);
    expect(
      info.requireCompatible,
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'protocol_mismatch',
        ),
      ),
    );
  });

  test('bridge startup metadata fails closed on missing capability', () {
    final info = NativeBridgeInfo.fromMap(
      const <String, Object?>{
        'protocolVersion': 1,
        'backendId': 'rust-core',
        'capabilities': <Object?>['convert', 'canonicalDecimalText'],
      },
    );

    expect(info.isCompatible, isFalse);
    expect(
      info.requireCompatible,
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'capability_mismatch',
        ),
      ),
    );
  });

  test('bridge startup metadata rejects malformed capability payloads', () {
    expect(
      () => NativeBridgeInfo.fromMap(
        const <String, Object?>{
          'protocolVersion': 1,
          'backendId': 'Rust Core',
          'capabilities': <Object?>['convert'],
        },
      ),
      throwsFormatException,
    );
    expect(
      () => NativeBridgeInfo.fromMap(
        const <String, Object?>{
          'protocolVersion': 1,
          'backendId': 'rust-core',
          'capabilities': <Object?>['convert', 'convert'],
        },
      ),
      throwsFormatException,
    );
  });

  test('bridge startup metadata serialization is deterministic and revalidated', () {
    const direct = NativeBridgeInfo(
      protocolVersion: nativeBridgeProtocolVersion,
      backendId: 'rust-core',
      capabilities: <String>{
        'convert',
        'canonicalDecimalText',
        'batchConvert',
      },
    );

    final encoded = direct.toMap();
    final validated = direct.validatedCopy();

    expect(encoded['protocolVersion'], nativeBridgeProtocolVersion);
    expect(encoded['backendId'], 'rust-core');
    expect(
      encoded['capabilities'],
      <String>['batchConvert', 'canonicalDecimalText', 'convert'],
    );
    expect(validated.capabilities, nativeBridgeRequiredCapabilities);
    expect(validated.requireCompatible, returnsNormally);
  });

  test('direct malformed startup metadata is rejected by validated copy', () {
    const malformed = NativeBridgeInfo(
      protocolVersion: nativeBridgeProtocolVersion,
      backendId: 'Rust Core',
      capabilities: <String>{'convert'},
    );

    expect(malformed.validatedCopy, throwsFormatException);
  });

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

  test('bridge request rejects non-canonical decimals', () {
    const request = NativeBridgeConversionRequest(
      value: '01.0',
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
      decimalPlaces: 12,
      roundMode: NativeBridgeRoundMode.nearestEven,
    );

    expect(request.toMap, throwsFormatException);
  });

  test('bridge request rejects invalid unit IDs and precision', () {
    const invalidUnit = NativeBridgeConversionRequest(
      value: '1',
      fromUnitId: '../meter',
      toUnitId: 'kilometer',
      decimalPlaces: 12,
      roundMode: NativeBridgeRoundMode.nearestEven,
    );
    const invalidPrecision = NativeBridgeConversionRequest(
      value: '1',
      fromUnitId: 'meter',
      toUnitId: 'kilometer',
      decimalPlaces: 29,
      roundMode: NativeBridgeRoundMode.nearestEven,
    );

    expect(invalidUnit.toMap, throwsFormatException);
    expect(invalidPrecision.toMap, throwsFormatException);
  });

  test('batch request preserves target order and exact text', () {
    const request = NativeBridgeBatchConversionRequest(
      value: '2',
      fromUnitId: 'meter',
      targetUnitIds: <String>['centimeter', 'millimeter'],
      decimalPlaces: 8,
      roundMode: NativeBridgeRoundMode.nearestEven,
    );

    final encoded = request.toMap();

    expect(nativeBridgeMaxBatchTargets, 256);
    expect(encoded['value'], '2');
    expect(encoded['targetUnitIds'], <String>['centimeter', 'millimeter']);
    expect(encoded['roundMode'], 'nearestEven');
  });

  test('batch request rejects malformed targets and oversized batches', () {
    const malformedTarget = NativeBridgeBatchConversionRequest(
      value: '2',
      fromUnitId: 'meter',
      targetUnitIds: <String>['../centimeter'],
      decimalPlaces: null,
      roundMode: NativeBridgeRoundMode.nearestEven,
    );
    final oversizedBatch = NativeBridgeBatchConversionRequest(
      value: '2',
      fromUnitId: 'meter',
      targetUnitIds: List<String>.filled(
        nativeBridgeMaxBatchTargets + 1,
        'centimeter',
      ),
      decimalPlaces: null,
      roundMode: NativeBridgeRoundMode.nearestEven,
    );

    expect(malformedTarget.toMap, throwsFormatException);
    expect(oversizedBatch.toMap, throwsFormatException);
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

  test('bridge response rejects non-canonical decimal output', () {
    expect(
      () => NativeBridgeConversionResponse.fromMap(
        const <String, Object?>{
          'input': '1000',
          'output': '01.0',
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
