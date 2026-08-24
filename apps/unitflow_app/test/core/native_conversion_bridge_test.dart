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

  test('custom catalog snapshot keeps exact canonical decimal strings', () {
    const unit = NativeBridgeCustomUnit(
      id: 'double_meter',
      categoryId: 'length',
      name: 'Double meter',
      symbol: 'dm2',
      scale: '2',
      offset: '0',
      aliases: <String>['double metre'],
      description: 'Synthetic test unit.',
    );

    final encoded = unit.toMap();

    expect(nativeBridgeMaxCustomUnits, 200);
    expect(encoded['id'], 'double_meter');
    expect(encoded['category'], 'length');
    expect(encoded['scale'], '2');
    expect(encoded['offset'], '0');
    expect(encoded['aliases'], <String>['double metre']);
  });

  test('custom catalog snapshot rejects invalid scale and identifiers', () {
    const invalidScale = NativeBridgeCustomUnit(
      id: 'double_meter',
      categoryId: 'length',
      name: 'Double meter',
      symbol: 'dm2',
      scale: '2.0',
      offset: '0',
      aliases: <String>[],
      description: '',
    );
    const invalidId = NativeBridgeCustomUnit(
      id: '../double_meter',
      categoryId: 'length',
      name: 'Double meter',
      symbol: 'dm2',
      scale: '2',
      offset: '0',
      aliases: <String>[],
      description: '',
    );

    expect(invalidScale.toMap, throwsFormatException);
    expect(invalidId.toMap, throwsFormatException);
  });

  test('custom catalog snapshot rejects non-positive scale', () {
    const unit = NativeBridgeCustomUnit(
      id: 'zero_scale',
      categoryId: 'length',
      name: 'Zero scale',
      symbol: 'zs',
      scale: '0',
      offset: '0',
      aliases: <String>[],
      description: '',
    );

    expect(unit.toMap, throwsFormatException);
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

  test('generated adapter caches startup metadata and forwards exact request maps', () async {
    final api = _GeneratedApiFake();
    final adapter = GeneratedNativeConversionBridge(api);
    const request = NativeBridgeConversionRequest(
      value: '2',
      fromUnitId: 'meter',
      toUnitId: 'centimeter',
      decimalPlaces: 12,
      roundMode: NativeBridgeRoundMode.nearestEven,
    );

    expect(adapter.info.backendId, 'rust-core');
    expect(adapter.info.protocolVersion, 1);
    expect(api.infoReads, 1);

    final response = await adapter.convert(request);
    expect(api.lastSingleRequest?['value'], '2');
    expect(api.lastSingleRequest?['fromUnitId'], 'meter');
    expect(api.lastSingleRequest?['toUnitId'], 'centimeter');
    expect(response.output, '200');
    expect(api.infoReads, 1);
  });

  test('generated adapter preserves batch order and validates returned maps', () async {
    final api = _GeneratedApiFake();
    final adapter = GeneratedNativeConversionBridge(api);
    const request = NativeBridgeBatchConversionRequest(
      value: '2',
      fromUnitId: 'meter',
      targetUnitIds: <String>['centimeter', 'millimeter'],
      decimalPlaces: null,
      roundMode: NativeBridgeRoundMode.nearestEven,
    );

    final responses = await adapter.batchConvert(request);

    expect(api.lastBatchRequest?['targetUnitIds'], <String>['centimeter', 'millimeter']);
    expect(responses.map((item) => item.toUnitId), <String>['centimeter', 'millimeter']);
    expect(responses.map((item) => item.output), <String>['200', '2000']);
  });

  test('generated adapter classifies malformed response map as invalid response', () async {
    final api = _GeneratedApiFake(malformedSingleResponse: true);
    final adapter = GeneratedNativeConversionBridge(api);
    const request = NativeBridgeConversionRequest(
      value: '2',
      fromUnitId: 'meter',
      toUnitId: 'centimeter',
      decimalPlaces: null,
      roundMode: NativeBridgeRoundMode.nearestEven,
    );

    await expectLater(
      adapter.convert(request),
      throwsA(
        isA<NativeBridgeFailure>().having(
          (failure) => failure.code,
          'code',
          'invalid_response',
        ),
      ),
    );
  });

  test('generated adapter validates and forwards custom catalog snapshots', () async {
    final api = _GeneratedApiFake();
    final adapter = GeneratedNativeConversionBridge(api);
    const unit = NativeBridgeCustomUnit(
      id: 'double_meter',
      categoryId: 'length',
      name: 'Double meter',
      symbol: 'dm2',
      scale: '2',
      offset: '0',
      aliases: <String>[],
      description: '',
    );

    await adapter.replaceCustomUnits(const <NativeBridgeCustomUnit>[unit]);

    expect(api.lastCustomUnits, hasLength(1));
    expect(api.lastCustomUnits.single['id'], 'double_meter');
    expect(api.lastCustomUnits.single['scale'], '2');
  });
}

const _adapterInfo = NativeBridgeInfo(
  protocolVersion: nativeBridgeProtocolVersion,
  backendId: 'rust-core',
  capabilities: <String>{
    nativeBridgeCapabilityConvert,
    nativeBridgeCapabilityBatchConvert,
    nativeBridgeCapabilityCanonicalDecimalText,
  },
);

final class _GeneratedApiFake implements GeneratedNativeBridgeApi {
  _GeneratedApiFake({this.malformedSingleResponse = false});

  final bool malformedSingleResponse;
  int infoReads = 0;
  Map<String, Object?>? lastSingleRequest;
  Map<String, Object?>? lastBatchRequest;
  List<Map<String, Object?>> lastCustomUnits = const <Map<String, Object?>>[];

  @override
  NativeBridgeInfo get info {
    infoReads += 1;
    return _adapterInfo;
  }

  @override
  Future<Map<String, Object?>> convert(Map<String, Object?> request) async {
    lastSingleRequest = request;
    if (malformedSingleResponse) {
      return <String, Object?>{
        'input': request['value'],
        'output': '02.0',
        'fromUnitId': request['fromUnitId'],
        'toUnitId': request['toUnitId'],
      };
    }
    return <String, Object?>{
      'input': request['value'],
      'output': '200',
      'fromUnitId': request['fromUnitId'],
      'toUnitId': request['toUnitId'],
    };
  }

  @override
  Future<List<Map<String, Object?>>> batchConvert(Map<String, Object?> request) async {
    lastBatchRequest = request;
    final targets = (request['targetUnitIds']! as List<String>);
    return List<Map<String, Object?>>.generate(
      targets.length,
      (index) => <String, Object?>{
        'input': request['value'],
        'output': index == 0 ? '200' : '2000',
        'fromUnitId': request['fromUnitId'],
        'toUnitId': targets[index],
      },
      growable: false,
    );
  }

  @override
  Future<void> replaceCustomUnits(List<Map<String, Object?>> customUnits) async {
    lastCustomUnits = List<Map<String, Object?>>.unmodifiable(customUnits);
  }
}
