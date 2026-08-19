import 'dart:convert';

import 'package:flutter/foundation.dart';

enum AppLogLevel { debug, info, warning, error }

/// Small structured logger for development diagnostics.
///
/// UnitFlow does not ship telemetry. Messages are emitted only in debug builds,
/// and metadata keys that look sensitive are redacted before serialization.
final class AppLog {
  const AppLog._();

  static const _sensitiveFragments = <String>{
    'authorization',
    'cookie',
    'credential',
    'password',
    'secret',
    'token',
  };

  static void warning(String event, {Map<String, Object?> metadata = const {}}) =>
      _write(AppLogLevel.warning, event, metadata);

  static void error(String event, {Map<String, Object?> metadata = const {}}) =>
      _write(AppLogLevel.error, event, metadata);

  @visibleForTesting
  static Map<String, Object?> sanitizeMetadata(Map<String, Object?> metadata) {
    final sanitized = <String, Object?>{};
    for (final entry in metadata.entries) {
      final normalizedKey = entry.key.toLowerCase();
      final sensitive = _sensitiveFragments.any(normalizedKey.contains);
      sanitized[entry.key] = sensitive ? '[REDACTED]' : _sanitizeValue(entry.value);
    }
    return sanitized;
  }

  static Object? _sanitizeValue(Object? value) {
    if (value == null || value is num || value is bool) {
      return value;
    }
    if (value is String) {
      return value.length <= 256 ? value : '${value.substring(0, 256)}…';
    }
    if (value is Iterable<Object?>) {
      return value.take(20).map(_sanitizeValue).toList(growable: false);
    }
    if (value is Map<Object?, Object?>) {
      final normalized = <String, Object?>{};
      for (final entry in value.entries.take(20)) {
        final key = entry.key.toString();
        final lower = key.toLowerCase();
        final sensitive = _sensitiveFragments.any(lower.contains);
        normalized[key] = sensitive ? '[REDACTED]' : _sanitizeValue(entry.value);
      }
      return normalized;
    }
    return value.runtimeType.toString();
  }

  static void _write(
    AppLogLevel level,
    String event,
    Map<String, Object?> metadata,
  ) {
    if (!kDebugMode) {
      return;
    }
    final payload = <String, Object?>{
      'level': level.name,
      'event': event,
      if (metadata.isNotEmpty) 'metadata': sanitizeMetadata(metadata),
    };
    debugPrint(jsonEncode(payload));
  }
}
