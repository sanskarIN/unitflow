import 'package:flutter/foundation.dart';

import '../core/converter.dart';
import '../core/unit_catalog.dart';
import '../core/unit_model.dart';

@immutable
class UnitPair {
  const UnitPair(this.fromId, this.toId);

  final String fromId;
  final String toId;

  @override
  bool operator ==(Object other) {
    return other is UnitPair && other.fromId == fromId && other.toId == toId;
  }

  @override
  int get hashCode => Object.hash(fromId, toId);
}

@immutable
class ConversionRecord {
  const ConversionRecord({
    required this.input,
    required this.output,
    required this.from,
    required this.to,
  });

  final String input;
  final String output;
  final ConversionUnit from;
  final ConversionUnit to;
}

class AppState extends ChangeNotifier {
  AppState({Converter converter = const Converter()}) : _converter = converter {
    _selectDefaultsForCategory();
    _recalculate(addToHistory: false);
  }

  final Converter _converter;
  UnitCategory _category = UnitCategory.length;
  late ConversionUnit _from;
  late ConversionUnit _to;
  String _input = '1';
  String _output = '';
  String? _error;
  int _decimalPlaces = 8;
  bool _scientific = false;
  final Set<UnitPair> _favorites = <UnitPair>{};
  final List<ConversionRecord> _recent = <ConversionRecord>[];

  UnitCategory get category => _category;
  ConversionUnit get from => _from;
  ConversionUnit get to => _to;
  String get input => _input;
  String get output => _output;
  String? get error => _error;
  int get decimalPlaces => _decimalPlaces;
  bool get scientific => _scientific;
  List<ConversionRecord> get recent => List<ConversionRecord>.unmodifiable(_recent);
  Set<UnitPair> get favorites => Set<UnitPair>.unmodifiable(_favorites);
  List<ConversionUnit> get availableUnits => unitsForCategory(_category);

  bool get isCurrentPairFavorite => _favorites.contains(UnitPair(_from.id, _to.id));

  void setCategory(UnitCategory value) {
    if (_category == value) {
      return;
    }
    _category = value;
    _selectDefaultsForCategory();
    _recalculate(addToHistory: false);
    notifyListeners();
  }

  void setFrom(ConversionUnit value) {
    if (value.category != _category || value.id == _from.id) {
      return;
    }
    _from = value;
    _recalculate();
    notifyListeners();
  }

  void setTo(ConversionUnit value) {
    if (value.category != _category || value.id == _to.id) {
      return;
    }
    _to = value;
    _recalculate();
    notifyListeners();
  }

  void swapUnits() {
    final ConversionUnit previousFrom = _from;
    _from = _to;
    _to = previousFrom;
    if (_output.isNotEmpty && _error == null) {
      _input = _output;
    }
    _recalculate();
    notifyListeners();
  }

  void setInput(String value) {
    _input = value;
    _recalculate(addToHistory: false);
    notifyListeners();
  }

  void commitInput() {
    _recalculate(addToHistory: true);
    notifyListeners();
  }

  void setDecimalPlaces(int value) {
    final int clamped = value.clamp(0, 15).toInt();
    if (_decimalPlaces == clamped) {
      return;
    }
    _decimalPlaces = clamped;
    _recalculate(addToHistory: false);
    notifyListeners();
  }

  void setScientific(bool value) {
    if (_scientific == value) {
      return;
    }
    _scientific = value;
    _recalculate(addToHistory: false);
    notifyListeners();
  }

  void toggleCurrentFavorite() {
    final UnitPair pair = UnitPair(_from.id, _to.id);
    if (!_favorites.remove(pair)) {
      _favorites.add(pair);
    }
    notifyListeners();
  }

  List<String> batchConvert(Iterable<String> lines) {
    final List<String> output = <String>[];
    for (final String line in lines) {
      final String trimmed = line.trim();
      if (trimmed.isEmpty) {
        continue;
      }
      final double? value = double.tryParse(trimmed);
      if (value == null) {
        output.add('$trimmed → invalid number');
        continue;
      }
      final double converted = _converter.convert(value: value, from: _from, to: _to);
      output.add(
        '$trimmed ${_from.symbol} → ${_converter.format(converted, decimalPlaces: _decimalPlaces, scientific: _scientific)} ${_to.symbol}',
      );
    }
    return output;
  }

  void clearHistory() {
    if (_recent.isEmpty) {
      return;
    }
    _recent.clear();
    notifyListeners();
  }

  void _selectDefaultsForCategory() {
    final List<ConversionUnit> units = unitsForCategory(_category);
    _from = units.first;
    _to = units.length > 1 ? units[1] : units.first;
  }

  void _recalculate({bool addToHistory = true}) {
    final double? value = double.tryParse(_input.trim());
    if (value == null) {
      _output = '';
      _error = _input.trim().isEmpty ? null : 'Enter a valid number.';
      return;
    }

    try {
      final double converted = _converter.convert(value: value, from: _from, to: _to);
      _output = _converter.format(
        converted,
        decimalPlaces: _decimalPlaces,
        scientific: _scientific,
      );
      _error = null;
      if (addToHistory) {
        _recent.insert(
          0,
          ConversionRecord(input: _input, output: _output, from: _from, to: _to),
        );
        if (_recent.length > 12) {
          _recent.removeRange(12, _recent.length);
        }
      }
    } on ConversionException catch (error) {
      _output = '';
      _error = error.message;
    }
  }
}
