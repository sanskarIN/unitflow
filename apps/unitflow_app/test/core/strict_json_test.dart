import 'package:flutter_test/flutter_test.dart';
import 'package:unitflow/core/persistence/strict_json.dart';

void main() {
  test('decodes valid nested JSON', () {
    final decoded = decodeStrictJson(
      '{"root":{"items":[1,true,null,{"name":"UnitFlow"}]}}',
    );

    expect(decoded, isA<Map<Object?, Object?>>());
  });

  test('rejects duplicate root object keys', () {
    expect(
      () => decodeStrictJson('{"schemaVersion":1,"schemaVersion":2}'),
      throwsFormatException,
    );
  });

  test('rejects duplicate nested object keys', () {
    expect(
      () => decodeStrictJson('{"outer":{"value":1,"value":2}}'),
      throwsFormatException,
    );
  });

  test('treats escaped and literal forms of the same key as duplicates', () {
    expect(
      () => decodeStrictJson('{"name":1,"\\u006eame":2}'),
      throwsFormatException,
    );
  });

  test('allows the same key name in separate objects', () {
    expect(
      decodeStrictJson('[{"value":1},{"value":2}]'),
      isA<List<Object?>>(),
    );
  });

  test('rejects nesting beyond configured limit', () {
    expect(
      () => decodeStrictJson('[[[0]]]', maxNesting: 2),
      throwsFormatException,
    );
  });
}
