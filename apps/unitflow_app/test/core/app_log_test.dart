import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/logging/app_log.dart';

void main() {
  test('redacts sensitive metadata keys recursively', () {
    final sanitized = AppLog.sanitizeMetadata(<String, Object?>{
      'operation': 'load_state',
      'token': 'do-not-log-me',
      'nested': <String, Object?>{
        'AuthorizationHeader': 'Bearer hidden',
        'count': 2,
      },
    });

    expect(sanitized['operation'], 'load_state');
    expect(sanitized['token'], '[REDACTED]');
    expect(
      (sanitized['nested'] as Map<String, Object?>)['AuthorizationHeader'],
      '[REDACTED]',
    );
    expect((sanitized['nested'] as Map<String, Object?>)['count'], 2);
  });

  test('bounds long string metadata', () {
    final sanitized = AppLog.sanitizeMetadata(<String, Object?>{
      'message': 'x' * 400,
    });

    final message = sanitized['message'] as String;
    expect(message.length, 257);
    expect(message.endsWith('…'), isTrue);
  });
}
