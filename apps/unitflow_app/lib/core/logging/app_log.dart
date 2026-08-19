import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

/// Minimal structured diagnostics with conservative key-based redaction.
///
/// UnitFlow does not log conversion history, imported backup contents, or clipboard payloads.
abstract final class AppLog {
  static const _sensitiveFragments = <String>{
    'password',
    'passwd',
    'token',
    'secret',
    'authorization',
    'cookie',
    'email',
    'backup',
    'clipboard',
    'content',
  };

  static void write(
    LogLevel level,
    String event, {
    Map<String, Object?> fields = const <String, Object?>{},
  }) {
    if (!kDebugMode && level == LogLevel.debug) {
      return;
    }
    final safeFields = <String, Object?>{};
    for (final entry in fields.entries) {
      safeFields[entry.key] = _shouldRedact(entry.key) ? '<redacted>' : _bound(entry.value);
    }
    debugPrint(<String, Object?>{
      'level': level.name,
      'event': event,
      ...safeFields,
    }.toString());
  }

  static bool _shouldRedact(String key) {
    final normalized = key.toLowerCase();
    return _sensitiveFragments.any(normalized.contains);
  }

  static Object? _bound(Object? value) {
    if (value is String && value.length > 200) {
      return '${value.substring(0, 197)}...';
    }
    if (value is num || value is bool || value == null) {
      return value;
    }
    return value.runtimeType.toString();
  }
}
