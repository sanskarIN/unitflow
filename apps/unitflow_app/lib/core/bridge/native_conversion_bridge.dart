import '../math/exact_decimal.dart';

/// Application-level native bridge protocol supported by this Flutter source.
const int nativeBridgeProtocolVersion = 1;

/// Stable capabilities required before UnitFlow may route a session to Rust.
const String nativeBridgeCapabilityConvert = 'convert';
const String nativeBridgeCapabilityBatchConvert = 'batchConvert';
const String nativeBridgeCapabilityCanonicalDecimalText = 'canonicalDecimalText';
const Set<String> nativeBridgeRequiredCapabilities = <String>{
  nativeBridgeCapabilityConvert,
  nativeBridgeCapabilityBatchConvert,
  nativeBridgeCapabilityCanonicalDecimalText,
};

/// Maximum target count accepted by a native batch request.
const int nativeBridgeMaxBatchTargets = 256;

/// Maximum user-defined units accepted by one native catalog snapshot.
const int nativeBridgeMaxCustomUnits = 200;

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

final class NativeBridgeInfo {
  const NativeBridgeInfo({
    required this.protocolVersion,
    required this.backendId,
    required this.capabilities,
  });

  final int protocolVersion;
  final String backendId;
  final Set<String> capabilities;

  factory NativeBridgeInfo.fromMap(Map<String, Object?> value) {
    final protocolVersion = value['protocolVersion'];
    final backendId = value['backendId'];
    final capabilities = value['capabilities'];
    if (protocolVersion is! int || protocolVersion <= 0 || protocolVersion > 0x7fffffff) {
      throw const FormatException('Invalid native bridge protocol version.');
    }
    if (backendId is! String || !RegExp(r'^[a-z0-9][a-z0-9._-]{0,63}$').hasMatch(backendId)) {
      throw const FormatException('Invalid native bridge backend identifier.');
    }
    if (capabilities is! List<Object?> || capabilities.length > 32) {
      throw const FormatException('Invalid native bridge capabilities.');
    }

    final parsedCapabilities = <String>{};
    for (final capability in capabilities) {
      if (capability is! String ||
          !RegExp(r'^[A-Za-z][A-Za-z0-9._-]{0,63}$').hasMatch(capability) ||
          !parsedCapabilities.add(capability)) {
        throw const FormatException('Invalid native bridge capability identifier.');
      }
    }

    return NativeBridgeInfo(
      protocolVersion: protocolVersion,
      backendId: backendId,
      capabilities: Set<String>.unmodifiable(parsedCapabilities),
    );
  }

  /// Serializes startup metadata through the same bounded shape accepted from
  /// generated/native bindings. Capability ordering is deterministic.
  Map<String, Object?> toMap() {
    final sortedCapabilities = capabilities.toList()..sort();
    return <String, Object?>{
      'protocolVersion': protocolVersion,
      'backendId': backendId,
      'capabilities': List<String>.unmodifiable(sortedCapabilities),
    };
  }

  /// Re-runs all structural validation even when a bridge implementation
  /// supplied a directly constructed [NativeBridgeInfo].
  NativeBridgeInfo validatedCopy() => NativeBridgeInfo.fromMap(toMap());

  bool get isCompatible {
    if (protocolVersion != nativeBridgeProtocolVersion) {
      return false;
    }
    for (final requiredCapability in nativeBridgeRequiredCapabilities) {
      if (!capabilities.contains(requiredCapability)) {
        return false;
      }
    }
    return true;
  }

  void requireCompatible() {
    if (protocolVersion != nativeBridgeProtocolVersion) {
      throw const NativeBridgeFailure(
        code: 'protocol_mismatch',
        message: 'The native conversion backend protocol is not supported.',
      );
    }
    for (final requiredCapability in nativeBridgeRequiredCapabilities) {
      if (!capabilities.contains(requiredCapability)) {
        throw const NativeBridgeFailure(
          code: 'capability_mismatch',
          message: 'The native conversion backend is missing a required capability.',
        );
      }
    }
  }
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
    _validateCommonRequest(
      value: value,
      fromUnitId: fromUnitId,
      decimalPlaces: decimalPlaces,
    );
    _requireUnitId(toUnitId, field: 'toUnitId');

    return <String, Object?>{
      'value': value,
      'fromUnitId': fromUnitId,
      'toUnitId': toUnitId,
      'decimalPlaces': decimalPlaces,
      'roundMode': roundMode.name,
    };
  }
}

final class NativeBridgeBatchConversionRequest {
  const NativeBridgeBatchConversionRequest({
    required this.value,
    required this.fromUnitId,
    required this.targetUnitIds,
    required this.decimalPlaces,
    required this.roundMode,
  });

  final String value;
  final String fromUnitId;
  final List<String> targetUnitIds;
  final int? decimalPlaces;
  final NativeBridgeRoundMode roundMode;

  Map<String, Object?> toMap() {
    _validateCommonRequest(
      value: value,
      fromUnitId: fromUnitId,
      decimalPlaces: decimalPlaces,
    );
    if (targetUnitIds.length > nativeBridgeMaxBatchTargets) {
      throw const FormatException('Native bridge batch target limit exceeded.');
    }
    for (var index = 0; index < targetUnitIds.length; index += 1) {
      _requireUnitId(targetUnitIds[index], field: 'targetUnitIds[$index]');
    }

    return <String, Object?>{
      'value': value,
      'fromUnitId': fromUnitId,
      'targetUnitIds': List<String>.unmodifiable(targetUnitIds),
      'decimalPlaces': decimalPlaces,
      'roundMode': roundMode.name,
    };
  }
}

/// Generator-friendly custom-unit payload for replacing the Rust session's
/// user-defined catalog snapshot.
final class NativeBridgeCustomUnit {
  const NativeBridgeCustomUnit({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.symbol,
    required this.scale,
    required this.offset,
    required this.aliases,
    required this.description,
  });

  final String id;
  final String categoryId;
  final String name;
  final String symbol;
  final String scale;
  final String offset;
  final List<String> aliases;
  final String description;

  Map<String, Object?> toMap() {
    _requireUnitId(id, field: 'id');
    if (!RegExp(r'^[a-z][a-z0-9_]{0,31}$').hasMatch(categoryId)) {
      throw const FormatException('Invalid native bridge category identifier.');
    }
    if (name.trim().isEmpty || name.length > 128) {
      throw const FormatException('Invalid native bridge custom-unit name.');
    }
    if (symbol.trim().isEmpty || symbol.length > 32) {
      throw const FormatException('Invalid native bridge custom-unit symbol.');
    }
    if (description.length > 512) {
      throw const FormatException('Invalid native bridge custom-unit description.');
    }
    if (aliases.length > 32 || aliases.any((alias) => alias.trim().isEmpty || alias.length > 64)) {
      throw const FormatException('Invalid native bridge custom-unit aliases.');
    }

    final parsedScale = _requireCanonicalDecimal(scale, field: 'scale');
    if (parsedScale.compareTo(ExactDecimal.zero) <= 0) {
      throw const FormatException('Native bridge custom-unit scale must be positive.');
    }
    _requireCanonicalDecimal(offset, field: 'offset');

    return <String, Object?>{
      'id': id,
      'category': categoryId,
      'name': name.trim(),
      'symbol': symbol.trim(),
      'aliases': List<String>.unmodifiable(aliases.map((alias) => alias.trim())),
      'description': description.trim(),
      'scale': scale,
      'offset': offset,
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
  /// Validated startup metadata reported by the native backend.
  NativeBridgeInfo get info;

  Future<NativeBridgeConversionResponse> convert(
    NativeBridgeConversionRequest request,
  );

  Future<List<NativeBridgeConversionResponse>> batchConvert(
    NativeBridgeBatchConversionRequest request,
  );
}

/// Optional extension implemented by production bindings that can replace the
/// user-defined portion of the active Rust catalog atomically.
abstract interface class NativeCatalogSyncBridge implements NativeConversionBridge {
  Future<void> replaceCustomUnits(List<NativeBridgeCustomUnit> customUnits);
}

void _validateCommonRequest({
  required String value,
  required String fromUnitId,
  required int? decimalPlaces,
}) {
  _requireCanonicalDecimal(value, field: 'value');
  _requireUnitId(fromUnitId, field: 'fromUnitId');
  final places = decimalPlaces;
  if (places != null && (places < 0 || places > 28)) {
    throw const FormatException('Invalid native bridge decimal precision.');
  }
}

ExactDecimal _requireCanonicalDecimal(String value, {required String field}) {
  if (value.isEmpty || value.length > 1024) {
    throw FormatException('Invalid native bridge decimal field: $field.');
  }
  try {
    final parsed = ExactDecimal.parse(value);
    if (parsed.toCanonicalString() != value) {
      throw FormatException('Non-canonical native bridge decimal field: $field.');
    }
    return parsed;
  } on FormatException {
    throw FormatException('Invalid native bridge decimal field: $field.');
  }
}

void _requireUnitId(String value, {required String field}) {
  if (!RegExp(r'^[a-z0-9_-]{1,64}$').hasMatch(value)) {
    throw FormatException('Invalid native bridge unit identifier: $field.');
  }
}
