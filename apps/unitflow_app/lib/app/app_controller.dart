import 'package:flutter/foundation.dart';

import '../core/logging/app_log.dart';
import '../core/math/exact_decimal.dart';
import '../core/persistence/user_state.dart';
import '../core/persistence/user_state_repository.dart';
import '../features/converter/data/unit_catalog.dart';
import '../features/converter/domain/conversion_engine.dart';
import '../features/converter/domain/conversion_session.dart';
import '../features/converter/domain/unit_models.dart';

final class AppController extends ChangeNotifier {
  AppController({
    required UserStateRepository repository,
    NativeConversionBridgeLoader? nativeBridgeLoader,
  }) : _repository = repository,
       _nativeBridgeLoader = nativeBridgeLoader ?? (() async => null);

  final UserStateRepository _repository;
  final NativeConversionBridgeLoader _nativeBridgeLoader;
  UserState _state = UserState();
  ConversionEngine _engine = ExactConversionEngine();
  ConversionSession _conversionSession = ConversionSession.select();
  bool _ready = false;
  bool _disposed = false;
  String? _warning;
  Future<void> _writeChain = Future<void>.value();
  Future<void>? _initialization;
  int _sessionRefreshGeneration = 0;

  UserState get state => _state;
  ConversionEngine get engine => _engine;
  ConversionSession get conversionSession => _conversionSession;
  bool get isReady => _ready;
  String? get warning => _warning;

  Future<void> initialize() {
    if (_disposed || _ready) {
      return Future<void>.value();
    }
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      final loaded = await _repository.load();
      if (_disposed) {
        return;
      }
      final rebuilt = _buildEngine(loaded);
      _state = loaded;
      _engine = rebuilt;
      await _refreshConversionSession(rebuilt, loaded, notify: false);
    } on Object catch (error) {
      if (_disposed) {
        return;
      }
      _warning =
          'Saved preferences could not be loaded. Defaults are being used; existing saved data was not overwritten.';
      AppLog.error(
        'state_load_failed',
        metadata: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      _state = UserState();
      _engine = ExactConversionEngine();
      _conversionSession = ConversionSession.select(fallbackEngine: _engine);
      _sessionRefreshGeneration += 1;
    } finally {
      if (!_disposed) {
        _ready = true;
        notifyListeners();
      }
    }
  }

  Future<void> setTheme(ThemePreference preference) => _update(_state.copyWith(theme: preference));

  Future<void> setNotation(DecimalNotation notation) => _update(_state.copyWith(notation: notation));

  Future<void> setRoundingMode(DecimalRoundingMode roundingMode) => _update(_state.copyWith(roundingMode: roundingMode));

  Future<void> setDecimalPlaces(int decimalPlaces) {
    if (decimalPlaces < 0 || decimalPlaces > 28) {
      throw RangeError.range(decimalPlaces, 0, 28, 'decimalPlaces');
    }
    return _update(_state.copyWith(decimalPlaces: decimalPlaces));
  }

  Future<void> setUseGrouping(bool enabled) => _update(_state.copyWith(useGrouping: enabled));

  Future<void> completeOnboarding() => _update(_state.copyWith(onboardingComplete: true));

  Future<void> toggleFavorite(String unitId) {
    if (_engine.catalog.byId(unitId) == null) {
      throw ArgumentError.value(unitId, 'unitId', 'unknown unit');
    }
    final next = _state.favoriteUnitIds.toSet();
    next.contains(unitId) ? next.remove(unitId) : next.add(unitId);
    return _update(_state.copyWith(favoriteUnitIds: next));
  }

  Future<void> clearFavorites() {
    if (_state.favoriteUnitIds.isEmpty) {
      return Future<void>.value();
    }
    return _update(_state.copyWith(favoriteUnitIds: <String>{}));
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
    if (from == null || to == null || from.category != pair.category || to.category != pair.category) {
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

  Future<void> clearPinnedPairs() {
    if (_state.pinnedPairs.isEmpty) {
      return Future<void>.value();
    }
    return _update(_state.copyWith(pinnedPairs: const <PinnedPair>[]));
  }

  Future<void> recordRecent({
    required String input,
    required String fromUnitId,
    required String toUnitId,
  }) {
    if (input.trim().isEmpty || input.length > 1024) {
      throw ArgumentError.value(input, 'input', 'conversion input is invalid');
    }

    final from = _engine.catalog.byId(fromUnitId);
    final to = _engine.catalog.byId(toUnitId);
    if (from == null || to == null) {
      throw ArgumentError('Recent conversion references unknown units.');
    }
    if (from.category != to.category) {
      throw ArgumentError('Recent conversion units must share a category.');
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

  Future<void> clearRecents() {
    if (_state.recents.isEmpty) {
      return Future<void>.value();
    }
    return _update(_state.copyWith(recents: const <RecentConversion>[]));
  }

  Future<void> addCustomUnit(CustomUnitData customUnit) {
    if (_state.customUnits.length >= UserState.maxImportedCustomUnits) {
      return Future<void>.error(
        StateError('The maximum number of custom units has been reached.'),
      );
    }

    final definition = customUnit.toUnitDefinition();
    if (_engine.catalog.byId(definition.id) != null) {
      throw ArgumentError.value(definition.id, 'id', 'unit identifier already exists');
    }
    final next = <CustomUnitData>[..._state.customUnits, customUnit];
    final newState = _state.copyWith(customUnits: next);
    final newEngine = _buildEngine(newState);
    return _update(newState, engine: newEngine);
  }

  Future<void> removeCustomUnit(String id) {
    final existing = _state.customUnits.where((item) => item.id == id).toList();
    if (existing.isEmpty) {
      return Future<void>.value();
    }
    final nextCustom = _state.customUnits.where((item) => item.id != id).toList();
    final nextFavorites = _state.favoriteUnitIds.where((item) => item != id).toSet();
    final nextPins = _state.pinnedPairs.where((pair) => pair.fromUnitId != id && pair.toUnitId != id).toList();
    final nextRecents = _state.recents.where((recent) => recent.fromUnitId != id && recent.toUnitId != id).toList();
    final newState = _state.copyWith(
      customUnits: nextCustom,
      favoriteUnitIds: nextFavorites,
      pinnedPairs: nextPins,
      recents: nextRecents,
    );
    return _update(newState, engine: _buildEngine(newState));
  }

  String exportState() => _repository.exportJson(_state);

  Future<void> importState(String content) async {
    if (_disposed) {
      throw StateError('AppController has been disposed.');
    }

    final imported = _repository.importJson(content);
    final importedEngine = _buildEngine(imported);
    final previousState = _state;
    final previousEngine = _engine;

    try {
      await _update(
        imported,
        engine: importedEngine,
        propagatePersistenceFailure: true,
      );
    } on Object catch (error, stackTrace) {
      // Roll back only when this failed import is still the active mutation.
      // A newer user action must never be overwritten by an older failed save.
      if (!_disposed && identical(_state, imported)) {
        _state = previousState;
        _engine = previousEngine;
        await _refreshConversionSession(previousEngine, previousState, notify: false);
        if (!_disposed) {
          notifyListeners();
        }
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  Future<void> resetLocalData() {
    if (_disposed) {
      return Future<void>.error(StateError('AppController has been disposed.'));
    }

    final baseline = UserState(onboardingComplete: true);
    _state = baseline;
    _engine = ExactConversionEngine();
    _warning = null;
    final sessionRefresh = _refreshConversionSession(_engine, baseline);
    notifyListeners();

    final operation = _writeChain.then((_) async {
      await _repository.clear();
      await _repository.save(baseline);
    });
    _writeChain = operation.catchError((Object error) {
      if (_disposed) {
        return;
      }
      _warning = 'Local data could not be cleared from storage. Please try again.';
      AppLog.error(
        'state_reset_failed',
        metadata: <String, Object?>{'errorType': error.runtimeType.toString()},
      );
      notifyListeners();
    });
    return Future.wait<void>(<Future<void>>[operation, sessionRefresh]).then<void>((_) {});
  }

  void clearWarning() {
    if (_disposed) {
      return;
    }
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
    final engine = ExactConversionEngine(catalog: UnitCatalog(units));
    _validateSavedReferences(state, engine);
    return engine;
  }

  void _validateSavedReferences(UserState state, ConversionEngine engine) {
    for (final unitId in state.favoriteUnitIds) {
      if (engine.catalog.byId(unitId) == null) {
        throw FormatException('Favorite references an unknown unit: $unitId');
      }
    }

    for (final pair in state.pinnedPairs) {
      final from = engine.catalog.byId(pair.fromUnitId);
      final to = engine.catalog.byId(pair.toUnitId);
      if (from == null || to == null || from.category != pair.category || to.category != pair.category) {
        throw const FormatException('Pinned pair references invalid units.');
      }
    }

    for (final recent in state.recents) {
      final from = engine.catalog.byId(recent.fromUnitId);
      final to = engine.catalog.byId(recent.toUnitId);
      if (from == null || to == null || from.category != to.category) {
        throw const FormatException('Recent conversion references invalid units.');
      }
    }
  }

  Future<void> _refreshConversionSession(
    ConversionEngine engine,
    UserState state, {
    bool notify = true,
  }) async {
    if (_disposed) {
      return;
    }
    final generation = ++_sessionRefreshGeneration;

    // Never leave an older native session active while a new catalog is being
    // validated. The deterministic fallback is immediately aligned to the new
    // engine, then may be promoted to a fresh native session below.
    _conversionSession = ConversionSession.select(fallbackEngine: engine);

    final session = await ConversionSession.bootstrap(
      loadNativeBridge: _nativeBridgeLoader,
      fallbackEngine: engine,
      initialCustomUnits: state.customUnits.map((item) => item.toUnitDefinition()),
    );
    if (_disposed || generation != _sessionRefreshGeneration) {
      return;
    }

    _conversionSession = session;
    if (notify) {
      notifyListeners();
    }
  }

  Future<void> _update(
    UserState state, {
    ConversionEngine? engine,
    bool propagatePersistenceFailure = false,
  }) {
    if (_disposed) {
      return Future<void>.error(StateError('AppController has been disposed.'));
    }

    _state = state;
    Future<void>? sessionRefresh;
    if (engine != null) {
      _engine = engine;
      sessionRefresh = _refreshConversionSession(engine, state);
    }
    notifyListeners();

    final snapshot = state;
    final operation = _writeChain.then((_) => _repository.save(snapshot));
    final handled = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {
        if (!_disposed) {
          _warning = 'Changes could not be saved to local storage. Please try again.';
          AppLog.error(
            'state_save_failed',
            metadata: <String, Object?>{'errorType': error.runtimeType.toString()},
          );
          notifyListeners();
        }
        if (propagatePersistenceFailure) {
          Error.throwWithStackTrace(error, stackTrace);
        }
      },
    );
    _writeChain = handled.catchError((Object _) {});

    if (sessionRefresh == null) {
      return handled;
    }
    return Future.wait<void>(<Future<void>>[handled, sessionRefresh]).then<void>((_) {});
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }
    _disposed = true;
    _sessionRefreshGeneration += 1;
    super.dispose();
  }
}
