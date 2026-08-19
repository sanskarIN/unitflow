import 'dart:convert';

/// Decodes JSON after rejecting duplicate object keys and excessive nesting.
///
/// Dart's standard JSON decoder keeps only one value when an object repeats a key. Backup
/// imports should instead fail closed so ambiguous documents cannot silently change meaning.
Object? decodeStrictJson(String source, {int maxNesting = 64}) {
  if (maxNesting < 1) {
    throw ArgumentError.value(maxNesting, 'maxNesting', 'must be positive');
  }
  _JsonObjectKeyScanner(source, maxNesting: maxNesting).validate();
  return jsonDecode(source);
}

final class _JsonObjectKeyScanner {
  _JsonObjectKeyScanner(this.source, {required this.maxNesting});

  final String source;
  final int maxNesting;
  int _index = 0;

  void validate() {
    _skipWhitespace();
    _parseValue(0);
    _skipWhitespace();
    if (_index != source.length) {
      throw const FormatException('Unexpected data after JSON value.');
    }
  }

  void _parseValue(int depth) {
    if (depth > maxNesting) {
      throw FormatException('JSON nesting exceeds the limit of $maxNesting.');
    }
    _skipWhitespace();
    if (_index >= source.length) {
      throw const FormatException('Unexpected end of JSON input.');
    }

    switch (source[_index]) {
      case '{':
        _parseObject(depth + 1);
      case '[':
        _parseArray(depth + 1);
      case '"':
        _scanString();
      default:
        _scanPrimitive();
    }
  }

  void _parseObject(int depth) {
    _expect('{');
    _skipWhitespace();
    if (_consumeIf('}')) {
      return;
    }

    final keys = <String>{};
    while (true) {
      _skipWhitespace();
      if (_index >= source.length || source[_index] != '"') {
        throw const FormatException('JSON object key must be a string.');
      }
      final rawKey = _scanString();
      final decodedKey = jsonDecode(rawKey);
      if (decodedKey is! String) {
        throw const FormatException('JSON object key is invalid.');
      }
      if (!keys.add(decodedKey)) {
        throw FormatException('Duplicate JSON object key: $decodedKey');
      }

      _skipWhitespace();
      _expect(':');
      _parseValue(depth);
      _skipWhitespace();
      if (_consumeIf('}')) {
        return;
      }
      _expect(',');
    }
  }

  void _parseArray(int depth) {
    _expect('[');
    _skipWhitespace();
    if (_consumeIf(']')) {
      return;
    }

    while (true) {
      _parseValue(depth);
      _skipWhitespace();
      if (_consumeIf(']')) {
        return;
      }
      _expect(',');
    }
  }

  String _scanString() {
    final start = _index;
    _expect('"');
    while (_index < source.length) {
      final character = source[_index];
      if (character == '"') {
        _index += 1;
        return source.substring(start, _index);
      }
      if (character == r'\') {
        _index += 1;
        if (_index >= source.length) {
          throw const FormatException('Unterminated JSON escape sequence.');
        }
        _index += 1;
        continue;
      }
      _index += 1;
    }
    throw const FormatException('Unterminated JSON string.');
  }

  void _scanPrimitive() {
    final start = _index;
    while (_index < source.length) {
      final character = source[_index];
      if (_isWhitespace(character) ||
          character == ',' ||
          character == ']' ||
          character == '}') {
        break;
      }
      _index += 1;
    }
    if (_index == start) {
      throw const FormatException('Expected JSON value.');
    }
  }

  void _skipWhitespace() {
    while (_index < source.length && _isWhitespace(source[_index])) {
      _index += 1;
    }
  }

  bool _consumeIf(String expected) {
    if (_index < source.length && source[_index] == expected) {
      _index += 1;
      return true;
    }
    return false;
  }

  void _expect(String expected) {
    if (!_consumeIf(expected)) {
      throw FormatException('Expected `$expected` in JSON input.');
    }
  }

  bool _isWhitespace(String character) =>
      character == ' ' ||
      character == '\n' ||
      character == '\r' ||
      character == '\t';
}
