import 'package:flutter/foundation.dart';

import '../core/logging/app_log.dart';
import '../core/math/exact_decimal.dart';
import '../core/persistence/user_state.dart';
import '../core/persistence/user_state_repository.dart';
import '../features/converter/data/unit_catalog.dart';
import '../features/converter/domain/conversion_engine.dart';
import '../features/converter/domain/unit_models.dart';

final class RemovedCustomUnitSnapshot {
  const RemovedCustomUnitSnapshot({
    required this.unit,
    required this.wasFavorite,
    required this.pinnedPairs,
    required this.recents,
  });

  final CustomUnitData unit;
  final bool wasFavorite;
  final List<PinnedPair> pinnedPairs;
  final List<RecentConversion> recents;
}

final class AppController extends ChangeNotifier {
  AppController({required UserStateRepository repository}) : _repository = repository;

  static const _saveWarning =
      'Changes are available for this session but could not be saved locally. Export a backup before closing UnitFlow.';
  static const _clearWarning =
      'Local data could not be cleared. Your existing saved data was left in place.';

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
      _state = _normalizeStateReferences(loaded, rebuilt);
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

  Future<void> setRoundingMode(DecimalRoundingMode roundingMode) =>
      _update(_state.copyWith(roundingMode: roundingMode));

  Future<void> setDecimalPlaces(int decimalPlaces) {
    if (decimalPlaces < 0 || decimalPlaces > 28) {
      throw RangeError.range(decimalPlaces, 0, 28, 'decimalPlaces');
    }
    return _update(_state.copyWith(decimalPlaces: decimalPlaces));
  }

  Future<void> setUseGrouping(bool enabled) =>
      _update(_state.copyWith(useGrouping: enabled));

  Future<void> setReduceMotion(bool enabled) =>
      _update(_state.copyWith(reduceMotion: enabled));

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
    final from = _engine.catalog.byId(fromUnitId);
    final to = _engine.catalog.byId(toUnitId);
    if (from == null || to == null || from.category != to.category) {
      throw ArgumentError('Recent conversion references invalid units.');
    }
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

  Future<void> clearHistory() =>
      _update(_state.copyWith(recents: <RecentConversion>[]));

  Future<void> restoreHistory(List<RecentConversion> recents) {
    final restored = _state.copyWith(recents: recents.take(50).toList());
    return _update(_normalizeStateReferences(restored, _engine));
  }

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

  Future<RemovedCustomUnitSnapshot?> removeCustomUnit(String id) async {
    final existing = _state.customUnits.where((item) => item.id == id).toList();
    if (existing.isEmpty) {
      return null;
    }
    final snapshot = RemovedCustomUnitSnapshot(
      unit: existing.single,
      wasFavorite: _state.favoriteUnitIds.contains(id),
      pinnedPairs: List<PinnedPair>.unmodifiable(
        _state.pinnedPairs.where(
          (pair) => pair.fromUnitId == id || pair.toUnitId == id,
        ),
      ),
      recents: List<RecentConversion>.unmodifiable(
        _state.recents.where(
          (recent) => recent.fromUnitId == id || recent.toUnitId == id,
        ),
      ),
    );
    final nextCustom = _state.customUnits
        .where((item) => item.id != id)
        .toList();
    final nextFavorites = _state.favoriteUnitIds
        .where((item) => item != id)
        .toSet();
    final nextPins = _state.pinnedPairs
        .where((pair) => pair.fromUnitId != id && pair.toUnitId != id)
        .toList();
    final nextRecents = _state.recents
        .where((recent) => recent.fromUnitId != id && recent.toUnitId != id)
        .toList();
    final newState = _state.copyWith(
      customUnits: nextCustom,
      favoriteUnitIds: nextFavorites,
      pinnedPairs: nextPins,
      recents: nextRecents,
    );
    await _update(newState, engine: _buildEngine(newState));
    return snapshot;
  }

  Future<void> restoreCustomUnit(RemovedCustomUnitSnapshot snapshot) {
    if (_engine.catalog.byId(snapshot.unit.id) != null) {
      throw ArgumentError.value(
        snapshot.unit.id,
        'id',
        'unit identifier already exists',
      );
    }

    final customUnits = <CustomUnitData>[..._state.customUnits, snapshot.unit];
    final provisional = _state.copyWith(customUnits: customUnits);
    final restoredEngine = _buildEngine(provisional);

    final favorites = _state.favoriteUnitIds.toSet();
    if (snapshot.wasFavorite) {
      favorites.add(snapshot.unit.id);
    }

    final pins = <PinnedPair>[...snapshot.pinnedPairs, ..._state.pinnedPairs];
    final uniquePins = <String, PinnedPair>{};
    for (final pair in pins) {
      uniquePins.putIfAbsent(pair.storageValue, () => pair);
    }

    final recents = <RecentConversion>[...snapshot.recents, ..._state.recents]
      ..sort((left, right) => right.createdAt.compareTo(left.createdAt));

    final restored = provisional.copyWith(
      favoriteUnitIds: favorites,
      pinnedPairs: uniquePins.values.take(20).toList(),
      recents: recents.take(50).toList(),
    );
    return _update(
      _normalizeStateReferences(restored, restoredEngine),
      engine: restoredEngine,
    );
  }

  String exportState() => _repository.exportJson(_state);

  Future<void> importState(String content) {
    final imported = _repository.importJson(content);
    final importedEngine = _buildEngine(imported);
    final normalized = _normalizeStateReferences(imported, importedEngine);
    return _update(normalized, engine: importedEngine);
  }

  Future<void> resetLocalData() async {
    try {
      await _writeChain;
      await _repository.clear();
    } on Object catch (error) {
      _warning = _clearWarning;
      AppLog.write(
        LogLevel.error,
        'local_data_clear_failed',
        fields: <String, Object?>{'error_type': error.runtimeType.toString()},
      );
      notifyListeners();
      return;
    }
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

  UserState _normalizeStateReferences(
    UserState state,
    ConversionEngine engine,
  ) {
    final validIds = engine.catalog.units.map((unit) => unit.id).toSet();
    final favorites = state.favoriteUnitIds.where(validIds.contains).toSet();
    final pins = state.pinnedPairs.where((pair) {
      final from = engine.catalog.byId(pair.fromUnitId);
      final to = engine.catalog.byId(pair.toUnitId);
      return from != null &&
          to != null &&
          from.category == pair.category &&
          to.category == pair.category;
    }).take(20).toList();
    final recents = state.recents.where((recent) {
      final from = engine.catalog.byId(recent.fromUnitId);
      final to = engine.catalog.byId(recent.toUnitId);
      return from != null && to != null && from.category == to.category;
    }).take(50).toList();

    final removedFavorites = state.favoriteUnitIds.length - favorites.length;
    final removedPins = state.pinnedPairs.length - pins.length;
    final removedRecents = state.recents.length - recents.length;
    if (removedFavorites + removedPins + removedRecents > 0) {
      AppLog.write(
        LogLevel.warning,
        'state_references_normalized',
        fields: <String, Object?>{
          'removed_favorites': removedFavorites,
          'removed_pins': removedPins,
          'removed_recents': removedRecents,
        },
      );
    }

    return state.copyWith(
      favoriteUnitIds: favorites,
      pinnedPairs: pins,
      recents: recents,
    );
  }

  Future<void> _update(UserState state, {ConversionEngine? engine}) {
    _state = state;
    if (engine != null) {
      _engine = engine;
    }
    notifyListeners();

    final snapshot = state;
    final operation = _writeChain.then((_) => _repository.save(snapshot));
    final handled = operation.catchError((Object error) {
      _warning = _saveWarning;
      AppLog.write(
        LogLevel.error,
        'state_save_failed',
        fields: <String, Object?>{'error_type': error.runtimeType.toString()},
      );
      notifyListeners();
    });
    _writeChain = handled;
    return handled;
  }
}
