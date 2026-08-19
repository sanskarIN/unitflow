import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/errors/user_safe_error.dart';

void main() {
  test('userSafeFailure returns only the caller supplied fallback', () {
    const fallback = 'The operation could not be completed.';
    final message = userSafeFailure(
      StateError('secret-internal-detail'),
      event: 'test_failure',
      fallback: fallback,
    );

    expect(message, fallback);
    expect(message, isNot(contains('secret-internal-detail')));
  });
}
