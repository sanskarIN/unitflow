import 'package:flutter/foundation.dart';

import '../core/logging/app_log.dart';
import '../core/persistence/user_state.dart';
import '../core/persistence/user_state_repository.dart';
import '../features/converter/data/unit_catalog.dart';
import '../features/converter/domain/conversion_engine.dart';
import '../features/converter/domain/unit_models.dart';

final class AppController extends ChangeNotifier {
  AppController({required UserStateRepository repository}) : _repository = repository;

  final UserStateRepository _repository;
  UserState _state = UserState();
  ConversionEngine _engine = ExactConversionEngine();
  bool _ready = false;
  String? _warning;
  Future<void> _writeChain = Future<void>.value();

  UserState get state => _state;
  ConversionEngine get engine => _engine;
  bool get isReady => _ready;
  String? get warning => _warning;

  Future<void> initialize() async {
    try {
      final loaded = await _repository.load();
      final rebuilt = _buildEngine(loaded);
      _state = loaded;
      _engine = rebuilt;
      AppLog.write(LogLevel.info, 'state_loaded');
    } on Object catch (error) {
      _warning =
          'Saved preferences could not be loaded. Defaults are being used; existing saved data was not overwritten.';
      AppLog.write(
        LogLevel.error,
        'state_load_failed',
        fields: <String, Object?>{'error_type': error.runtimeType.toString()},
      );
      _state = UserState();
      _engine = ExactConversionEngine();
    } finally {
      _ready = true;
      notifyListeners();
    }
  }

  Future<void> setTheme(ThemePreference preference) =>
      _update(_state.copyWith(theme: preference));

  Future<void> setNotation(DecimalNotation notation) =>
      _update(_state.copyWith(notation: notation));

  Future<void> setDecimalPlaces(int decimalPlaces) {
    if (decimalPlaces < 0 || decimalPlaces > 28) {
      throw RangeError.range(decimalPlaces, 0, 28, 'decimalPlaces');
    }
    return _update(_state.copyWith(decimalPlaces: decimalPlaces));
  }

  Future<void> setUseGrouping(bool enabled) =>
      _update(_state.copyWith(useGrouping: enabled));

  Future<void> completeOnboarding() =>
      _update(_state.copyWith(onboardingComplete: true));

  Future<void> toggleFavorite(String unitId) {
    if (_engine.catalog.byId(unitId) == null) {
      throw ArgumentError.value(unitId, 'unitId', 'unknown unit');
    }
    final next = _state.favoriteUnitIds.toSet();
    next.contains(unitId) ? next.remove(unitId) : next.add(unitId);
    return _update(_state.copyWith(favoriteUnitIds: next));
  }

  bool isPairPinned(PinnedPair pair) => _state.pinnedPairs.any(
    (candidate) =>
        candidate.category == pair.category &&
        candidate.fromUnitId == pair.fromUnitId &&
        candidate.toUnitId == pair.toUnitId,
  );

  Future<void> togglePinnedPair(PinnedPair pair) {
    final from = _engine.catalog.byId(pair.fromUnitId);
    final to = _engine.catalog.byId(pair.toUnitId);
    if (from == null ||
        to == null ||
        from.category != pair.category ||
        to.category != pair.category) {
      throw ArgumentError('Pinned pair references invalid units.');
    }
    final next = _state.pinnedPairs.toList();
    final index = next.indexWhere(
      (candidate) =>
          candidate.category == pair.category &&
          candidate.fromUnitId == pair.fromUnitId &&
          candidate.toUnitId == pair.toUnitId,
    );
    if (index >= 0) {
      next.removeAt(index);
    } else {
      next.insert(0, pair);
      if (next.length > 20) {
        next.removeRange(20, next.length);
      }
    }
    return _update(_state.copyWith(pinnedPairs: next));
  }

  Future<void> recordRecent({
    required String input,
    required String fromUnitId,
    required String toUnitId,
  }) {
    final next = _state.recents.toList();
    if (next.isNotEmpty &&
        next.first.input == input &&
        next.first.fromUnitId == fromUnitId &&
        next.first.toUnitId == toUnitId) {
      return Future<void>.value();
    }
    next.insert(
      0,
      RecentConversion(
        input: input,
        fromUnitId: fromUnitId,
        toUnitId: toUnitId,
        createdAt: DateTime.now(),
      ),
    );
    if (next.length > 50) {
      next.removeRange(50, next.length);
    }
    return _update(_state.copyWith(recents: next));
  }

  Future<void> clearHistory() => _update(_state.copyWith(recents: <RecentConversion>[]));

  Future<void> restoreHistory(List<RecentConversion> recents) =>
      _update(_state.copyWith(recents: recents));

  Future<void> addCustomUnit(CustomUnitData customUnit) {
    final definition = customUnit.toUnitDefinition();
    if (_engine.catalog.byId(definition.id) != null) {
      throw ArgumentError.value(
        definition.id,
        'id',
        'unit identifier already exists',
      );
    }
    final next = <CustomUnitData>[..._state.customUnits, customUnit];
    final newState = _state.copyWith(customUnits: next);
    final newEngine = _buildEngine(newState);
    return _update(newState, engine: newEngine);
  }

  Future<void> removeCustomUnit(String id) {
    final existing = _state.customUnits
        .where((item) => item.id == id)
        .toList();
    if (existing.isEmpty) {
      return Future<void>.value();
    }
    final nextCustom = _state.customUnits
        .where((item) => item.id != id)
        .toList();
    final nextFavorites = _state.favoriteUnitIds
        .where((item) => item != id)
        .toSet();
    final nextPins = _state.pinnedPairs
        .where((pair) => pair.fromUnitId != id && pair.toUnitId != id)
        .toList();
    final newState = _state.copyWith(
      customUnits: nextCustom,
      favoriteUnitIds: nextFavorites,
      pinnedPairs: nextPins,
    );
    return _update(newState, engine: _buildEngine(newState));
  }

  String exportState() => _repository.exportJson(_state);

  Future<void> importState(String content) {
    final imported = _repository.importJson(content);
    final importedEngine = _buildEngine(imported);
    return _update(imported, engine: importedEngine);
  }

  Future<void> resetLocalData() async {
    await _repository.clear();
    _state = UserState(onboardingComplete: true);
    _engine = ExactConversionEngine();
    _warning = null;
    notifyListeners();
    AppLog.write(LogLevel.info, 'local_data_reset');
  }

  void clearWarning() {
    _warning = null;
    notifyListeners();
  }

  ConversionEngine _buildEngine(UserState state) {
    final units = <UnitDefinition>[...UnitCatalog.builtInUnits];
    final ids = units.map((unit) => unit.id).toSet();
    for (final custom in state.customUnits) {
      final definition = custom.toUnitDefinition();
      if (!ids.add(definition.id)) {
        throw FormatException('Duplicate unit identifier: ${definition.id}');
      }
      units.add(definition);
    }
    return ExactConversionEngine(catalog: UnitCatalog(units));
  }

  Future<void> _update(UserState state, {ConversionEngine? engine}) {
    _state = state;
    if (engine != null) {
      _engine = engine;
    }
    notifyListeners();

    final snapshot = state;
    final operation = _writeChain.then((_) => _repository.save(snapshot));
    _writeChain = operation.catchError((Object error) {
      AppLog.write(
        LogLevel.error,
        'state_save_failed',
        fields: <String, Object?>{'error_type': error.runtimeType.toString()},
      );
    });
    return operation;
  }
}
