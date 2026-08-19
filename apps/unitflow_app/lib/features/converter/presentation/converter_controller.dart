import 'package:flutter/foundation.dart';

import '../../../app/app_controller.dart';
import '../../../core/format/decimal_format.dart';
import '../../../core/math/exact_decimal.dart';
import '../../../core/persistence/user_state.dart';
import '../domain/batch_export.dart';
import '../domain/conversion_engine.dart';
import '../domain/unit_models.dart';

final class ConverterController extends ChangeNotifier {
  ConverterController({required AppController appController})
    : _appController = appController {
    _appController.addListener(_onAppChanged);
    _selectDefaults(UnitCategory.length);
    recompute();
  }

  final AppController _appController;
  final DecimalInputParser _parser = const DecimalInputParser();
  final DecimalDisplayFormatter _formatter = const DecimalDisplayFormatter();
  final BatchExportFormatter _batchExporter = const BatchExportFormatter();

  UnitCategory _category = UnitCategory.length;
  String _fromUnitId = 'meter';
  String _toUnitId = 'kilometer';
  String _input = '1';
  String _localeName = 'en';
  ConversionResult? _result;
  String? _error;

  UnitCategory get category => _category;
  String get fromUnitId => _fromUnitId;
  String get toUnitId => _toUnitId;
  String get input => _input;
  ConversionResult? get result => _result;
  String? get error => _error;

  List<UnitDefinition> get categoryUnits =>
      _appController.engine.catalog.forCategory(_category);

  UnitDefinition? get fromUnit => _appController.engine.catalog.byId(_fromUnitId);
  UnitDefinition? get toUnit => _appController.engine.catalog.byId(_toUnitId);

  PinnedPair get currentPair => PinnedPair(
    category: _category,
    fromUnitId: _fromUnitId,
    toUnitId: _toUnitId,
  );

  bool get isCurrentPairPinned => _appController.isPairPinned(currentPair);

  String get formattedOutput {
    final output = _result?.output;
    if (output == null) {
      return '—';
    }
    return _formatter.format(
      output,
      localeName: _localeName,
      notation: _appController.state.notation,
      useGrouping: _appController.state.useGrouping,
    );
  }

  void setLocale(String localeName) {
    if (_localeName == localeName) {
      return;
    }
    _localeName = localeName;
    recompute();
  }

  void setCategory(UnitCategory category) {
    if (_category == category) {
      return;
    }
    _category = category;
    _selectDefaults(category);
    recompute();
  }

  void setFromUnit(String id) {
    final unit = _appController.engine.catalog.byId(id);
    if (unit == null || unit.category != _category || id == _fromUnitId) {
      return;
    }
    _fromUnitId = id;
    recompute();
  }

  void setToUnit(String id) {
    final unit = _appController.engine.catalog.byId(id);
    if (unit == null || unit.category != _category || id == _toUnitId) {
      return;
    }
    _toUnitId = id;
    recompute();
  }

  void swapUnits() {
    final previousFrom = _fromUnitId;
    _fromUnitId = _toUnitId;
    _toUnitId = previousFrom;
    recompute();
  }

  void setInput(String value) {
    if (_input == value) {
      return;
    }
    _input = value;
    recompute();
  }

  void recompute() {
    _ensureValidPair();
    if (_input.trim().isEmpty) {
      _result = null;
      _error = null;
      notifyListeners();
      return;
    }

    try {
      final value = _parser.parse(_input, localeName: _localeName);
      _result = _appController.engine.convert(
        value: value,
        fromUnitId: _fromUnitId,
        toUnitId: _toUnitId,
        decimalPlaces: _appController.state.decimalPlaces,
        rounding: _appController.state.roundingMode,
      );
      _error = null;
    } on FormatException {
      _result = null;
      _error = 'Enter a valid number for the selected locale.';
    } on ConversionFailure catch (failure) {
      _result = null;
      _error = failure.message;
    } on Object {
      _result = null;
      _error = 'This value cannot be converted with the current settings.';
    }
    notifyListeners();
  }

  List<ConversionResult> batchResults() {
    final value = _result?.input;
    if (value == null) {
      return const <ConversionResult>[];
    }
    return _appController.engine.batchConvert(
      value: value,
      fromUnitId: _fromUnitId,
      toUnitIds: categoryUnits
          .where((unit) => unit.id != _fromUnitId)
          .map((unit) => unit.id),
      decimalPlaces: _appController.state.decimalPlaces,
      rounding: _appController.state.roundingMode,
    );
  }

  String exportBatch({BatchExportFormat format = BatchExportFormat.csv}) =>
      _batchExporter.encode(batchResults(), format: format);

  String formatBatchValue(ExactDecimal value) => _formatter.format(
    value,
    localeName: _localeName,
    notation: _appController.state.notation,
    useGrouping: _appController.state.useGrouping,
  );

  Future<void> toggleCurrentPairPinned() =>
      _appController.togglePinnedPair(currentPair);

  Future<void> recordCurrentConversion() {
    if (_result == null) {
      return Future<void>.value();
    }
    return _appController.recordRecent(
      input: _input,
      fromUnitId: _fromUnitId,
      toUnitId: _toUnitId,
    );
  }

  void applyPinnedPair(PinnedPair pair) {
    final from = _appController.engine.catalog.byId(pair.fromUnitId);
    final to = _appController.engine.catalog.byId(pair.toUnitId);
    if (from == null || to == null || from.category != pair.category || to.category != pair.category) {
      return;
    }
    _category = pair.category;
    _fromUnitId = pair.fromUnitId;
    _toUnitId = pair.toUnitId;
    recompute();
  }

  void applyRecent(RecentConversion recent) {
    final from = _appController.engine.catalog.byId(recent.fromUnitId);
    final to = _appController.engine.catalog.byId(recent.toUnitId);
    if (from == null || to == null || from.category != to.category) {
      return;
    }
    _category = from.category;
    _fromUnitId = from.id;
    _toUnitId = to.id;
    _input = recent.input;
    recompute();
  }

  void _selectDefaults(UnitCategory category) {
    final units = _appController.engine.catalog.forCategory(category);
    if (units.isEmpty) {
      _fromUnitId = '';
      _toUnitId = '';
      return;
    }
    _fromUnitId = units.first.id;
    _toUnitId = units.length > 1 ? units[1].id : units.first.id;
  }

  void _ensureValidPair() {
    final from = _appController.engine.catalog.byId(_fromUnitId);
    final to = _appController.engine.catalog.byId(_toUnitId);
    if (from?.category != _category || to?.category != _category) {
      _selectDefaults(_category);
    }
  }

  void _onAppChanged() {
    if (!_appController.isReady) {
      return;
    }
    recompute();
  }

  @override
  void dispose() {
    _appController.removeListener(_onAppChanged);
    super.dispose();
  }
}
