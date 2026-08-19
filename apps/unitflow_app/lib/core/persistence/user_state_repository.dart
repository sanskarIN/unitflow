import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'user_state.dart';

const _maxImportCharacters = 1_000_000;

UserState _decodeUserState(String content) {
  if (content.isEmpty || content.length > _maxImportCharacters) {
    throw const FormatException('UnitFlow import size is invalid.');
  }

  final Object? decoded = jsonDecode(content);
  if (decoded is! Map<Object?, Object?>) {
    throw const FormatException('UnitFlow import must be a JSON object.');
  }

  final normalized = <String, Object?>{};
  for (final entry in decoded.entries) {
    final key = entry.key;
    if (key is! String) {
      throw const FormatException('UnitFlow import contains an invalid key.');
    }
    normalized[key] = entry.value;
  }
  return UserState.fromJson(normalized);
}

abstract interface class UserStateRepository {
  Future<UserState> load();

  Future<void> save(UserState state);

  Future<void> clear();

  String exportJson(UserState state);

  UserState importJson(String content);
}

final class SharedPreferencesUserStateRepository implements UserStateRepository {
  SharedPreferencesUserStateRepository({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storageKey = 'unitflow.user_state.v1';

  final SharedPreferencesAsync _preferences;

  @override
  Future<UserState> load() async {
    final value = await _preferences.getString(_storageKey);
    if (value == null || value.isEmpty) {
      return UserState();
    }
    try {
      return importJson(value);
    } on FormatException catch (error) {
      throw StatePersistenceException(
        'Saved UnitFlow data is invalid and was not overwritten.',
        error,
      );
    }
  }

  @override
  Future<void> save(UserState state) async {
    final payload = jsonEncode(state.toJson());
    await _preferences.setString(_storageKey, payload);
  }

  @override
  Future<void> clear() => _preferences.remove(_storageKey);

  @override
  String exportJson(UserState state) =>
      const JsonEncoder.withIndent('  ').convert(state.toJson());

  @override
  UserState importJson(String content) => _decodeUserState(content);
}

final class MemoryUserStateRepository implements UserStateRepository {
  MemoryUserStateRepository([UserState? initial]) : _state = initial ?? UserState();

  UserState _state;

  @override
  Future<void> clear() async {
    _state = UserState();
  }

  @override
  String exportJson(UserState state) =>
      const JsonEncoder.withIndent('  ').convert(state.toJson());

  @override
  UserState importJson(String content) => _decodeUserState(content);

  @override
  Future<UserState> load() async => _state;

  @override
  Future<void> save(UserState state) async {
    _state = state;
  }
}

final class StatePersistenceException implements Exception {
  const StatePersistenceException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}
