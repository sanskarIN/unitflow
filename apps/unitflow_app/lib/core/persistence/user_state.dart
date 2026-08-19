import '../../features/converter/domain/unit_models.dart';
import '../format/decimal_format.dart';
import '../math/exact_decimal.dart';

enum ThemePreference { system, light, dark }

final class RecentConversion {
  const RecentConversion({
    required this.input,
    required this.fromUnitId,
    required this.toUnitId,
    required this.createdAt,
  });

  static const _allowedKeys = <String>{
    'input',
    'fromUnitId',
    'toUnitId',
    'createdAt',
  };
  static final RegExp _unitIdPattern = RegExp(r'^[a-z0-9_-]{1,64}$');

  final String input;
  final String fromUnitId;
  final String toUnitId;
  final DateTime createdAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'input': input,
    'fromUnitId': fromUnitId,
    'toUnitId': toUnitId,
    'createdAt': createdAt.toUtc().toIso8601String(),
  };

  static RecentConversion? tryFromJson(Object? value) {
    if (value is! Map<String, Object?> || !_containsOnlyKeys(value, _allowedKeys)) {
      return null;
    }
    final input = value['input'];
    final from = value['fromUnitId'];
    final to = value['toUnitId'];
    final created = value['createdAt'];
    if (input is! String || from is! String || to is! String || created is! String) {
      return null;
    }
    final timestamp = DateTime.tryParse(created);
    if (timestamp == null ||
        input.isEmpty ||
        input.length > 1024 ||
        !_unitIdPattern.hasMatch(from) ||
        !_unitIdPattern.hasMatch(to)) {
      return null;
    }
    return RecentConversion(
      input: input,
      fromUnitId: from,
      toUnitId: to,
      createdAt: timestamp,
    );
  }
}

final class CustomUnitData {
  const CustomUnitData({
    required this.id,
    required this.category,
    required this.name,
    required this.symbol,
    required this.scale,
    required this.offset,
    this.aliases = const <String>[],
    this.description = '',
  });

  static const _allowedKeys = <String>{
    'id',
    'category',
    'name',
    'symbol',
    'scale',
    'offset',
    'aliases',
    'description',
  };

  final String id;
  final UnitCategory category;
  final String name;
  final String symbol;
  final String scale;
  final String offset;
  final List<String> aliases;
  final String description;

  UnitDefinition toUnitDefinition() {
    if (!RegExp(r'^[a-z0-9_-]{1,64}$').hasMatch(id)) {
      throw const FormatException('Custom unit ID is invalid.');
    }
    final normalizedName = name.trim();
    final normalizedSymbol = symbol.trim();
    final normalizedDescription = description.trim();
    if (normalizedName.isEmpty || normalizedName.length > 128) {
      throw const FormatException('Custom unit name is invalid.');
    }
    if (normalizedSymbol.isEmpty || normalizedSymbol.length > 32) {
      throw const FormatException('Custom unit symbol is invalid.');
    }
    if (aliases.length > 32) {
      throw const FormatException('Custom unit aliases are invalid.');
    }
    final normalizedAliases = <String>[];
    final seenAliases = <String>{};
    for (final alias in aliases) {
      final normalized = alias.trim();
      if (normalized.isEmpty || normalized.length > 64) {
        throw const FormatException('Custom unit aliases are invalid.');
      }
      if (seenAliases.add(normalized.toLowerCase())) {
        normalizedAliases.add(normalized);
      }
    }
    if (normalizedDescription.length > 512) {
      throw const FormatException('Custom unit description is too long.');
    }
    if (scale.isEmpty || scale.length > 1024 || offset.isEmpty || offset.length > 1024) {
      throw const FormatException('Custom unit formula is invalid.');
    }
    final parsedScale = ExactDecimal.parse(scale);
    if (parsedScale.compareTo(ExactDecimal.zero) <= 0) {
      throw const FormatException('Custom unit scale must be greater than zero.');
    }
    return UnitDefinition(
      id: id,
      category: category,
      name: normalizedName,
      symbol: normalizedSymbol,
      scale: parsedScale,
      offset: ExactDecimal.parse(offset),
      aliases: List<String>.unmodifiable(normalizedAliases),
      description: normalizedDescription,
      isBuiltIn: false,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'category': category.id,
    'name': name,
    'symbol': symbol,
    'scale': scale,
    'offset': offset,
    'aliases': aliases,
    'description': description,
  };

  static CustomUnitData? tryFromJson(Object? value) {
    if (value is! Map<String, Object?> || !_containsOnlyKeys(value, _allowedKeys)) {
      return null;
    }
    final id = value['id'];
    final categoryId = value['category'];
    final name = value['name'];
    final symbol = value['symbol'];
    final scale = value['scale'];
    final offset = value['offset'];
    final aliasesValue = value['aliases'];
    final description = value['description'];
    if (id is! String ||
        categoryId is! String ||
        name is! String ||
        symbol is! String ||
        scale is! String ||
        offset is! String ||
        description is! String ||
        aliasesValue is! List<Object?>) {
      return null;
    }
    UnitCategory? category;
    for (final candidate in UnitCategory.values) {
      if (candidate.id == categoryId) {
        category = candidate;
        break;
      }
    }
    if (category == null || aliasesValue.any((value) => value is! String)) {
      return null;
    }
    final aliases = aliasesValue.cast<String>();
    final result = CustomUnitData(
      id: id,
      category: category,
      name: name,
      symbol: symbol,
      scale: scale,
      offset: offset,
      aliases: aliases,
      description: description,
    );
    try {
      final normalized = result.toUnitDefinition();
      return CustomUnitData(
        id: normalized.id,
        category: normalized.category,
        name: normalized.name,
        symbol: normalized.symbol,
        scale: normalized.scale.toCanonicalString(),
        offset: normalized.offset.toCanonicalString(),
        aliases: normalized.aliases,
        description: normalized.description,
      );
    } on FormatException {
      return null;
    }
  }
}

final class UserState {
  UserState({
    this.theme = ThemePreference.system,
    this.notation = DecimalNotation.plain,
    this.roundingMode = DecimalRoundingMode.nearestEven,
    this.decimalPlaces = 12,
    this.useGrouping = true,
    this.reduceMotion = false,
    this.onboardingComplete = false,
    Set<String>? favoriteUnitIds,
    List<PinnedPair>? pinnedPairs,
    List<RecentConversion>? recents,
    List<CustomUnitData>? customUnits,
  }) : favoriteUnitIds = Set<String>.unmodifiable(favoriteUnitIds ?? <String>{}),
       pinnedPairs = List<PinnedPair>.unmodifiable(pinnedPairs ?? const <PinnedPair>[]),
       recents = List<RecentConversion>.unmodifiable(recents ?? const <RecentConversion>[]),
       customUnits = List<CustomUnitData>.unmodifiable(customUnits ?? const <CustomUnitData>[]);

  static const schemaVersion = 2;
  static const maxPinnedPairs = 20;
  static const maxStoredRecents = 100;
  static const maxActiveRecents = 50;
  static const maxCustomUnits = 200;
  static final RegExp _unitIdPattern = RegExp(r'^[a-z0-9_-]{1,64}$');
  static const _allowedKeysV1 = <String>{
    'schemaVersion',
    'theme',
    'notation',
    'decimalPlaces',
    'useGrouping',
    'onboardingComplete',
    'favoriteUnitIds',
    'pinnedPairs',
    'recents',
    'customUnits',
  };
  static const _allowedKeysV2 = <String>{
    ..._allowedKeysV1,
    'roundingMode',
    'reduceMotion',
  };

  final ThemePreference theme;
  final DecimalNotation notation;
  final DecimalRoundingMode roundingMode;
  final int decimalPlaces;
  final bool useGrouping;
  final bool reduceMotion;
  final bool onboardingComplete;
  final Set<String> favoriteUnitIds;
  final List<PinnedPair> pinnedPairs;
  final List<RecentConversion> recents;
  final List<CustomUnitData> customUnits;

  UserState copyWith({
    ThemePreference? theme,
    DecimalNotation? notation,
    DecimalRoundingMode? roundingMode,
    int? decimalPlaces,
    bool? useGrouping,
    bool? reduceMotion,
    bool? onboardingComplete,
    Set<String>? favoriteUnitIds,
    List<PinnedPair>? pinnedPairs,
    List<RecentConversion>? recents,
    List<CustomUnitData>? customUnits,
  }) => UserState(
    theme: theme ?? this.theme,
    notation: notation ?? this.notation,
    roundingMode: roundingMode ?? this.roundingMode,
    decimalPlaces: decimalPlaces ?? this.decimalPlaces,
    useGrouping: useGrouping ?? this.useGrouping,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    favoriteUnitIds: favoriteUnitIds ?? this.favoriteUnitIds,
    pinnedPairs: pinnedPairs ?? this.pinnedPairs,
    recents: recents ?? this.recents,
    customUnits: customUnits ?? this.customUnits,
  );

  Map<String, Object?> toJson() => <String, Object?>{
    'schemaVersion': schemaVersion,
    'theme': theme.name,
    'notation': notation.name,
    'roundingMode': roundingMode.name,
    'decimalPlaces': decimalPlaces,
    'useGrouping': useGrouping,
    'reduceMotion': reduceMotion,
    'onboardingComplete': onboardingComplete,
    'favoriteUnitIds': favoriteUnitIds.toList(growable: false),
    'pinnedPairs': pinnedPairs.map((pair) => pair.storageValue).toList(growable: false),
    'recents': recents.map((recent) => recent.toJson()).toList(growable: false),
    'customUnits': customUnits.map((unit) => unit.toJson()).toList(growable: false),
  };

  static UserState fromJson(Map<String, Object?> json) {
    final version = json['schemaVersion'];
    if (version is! int || version < 1 || version > schemaVersion) {
      throw const FormatException('Unsupported UnitFlow data schema.');
    }
    final allowedKeys = version == 1 ? _allowedKeysV1 : _allowedKeysV2;
    if (!_containsOnlyKeys(json, allowedKeys)) {
      throw const FormatException('UnitFlow data contains unsupported fields.');
    }

    final decimalPlaces = json['decimalPlaces'];
    final useGrouping = json['useGrouping'];
    final reduceMotionValue = json['reduceMotion'];
    final onboardingComplete = json['onboardingComplete'];
    if (decimalPlaces is! int ||
        decimalPlaces < 0 ||
        decimalPlaces > 28 ||
        useGrouping is! bool ||
        (reduceMotionValue != null && reduceMotionValue is! bool) ||
        onboardingComplete is! bool) {
      throw const FormatException('Invalid UnitFlow preferences.');
    }

    final theme = ThemePreference.values.where((item) => item.name == json['theme']).firstOrNull;
    final notation = DecimalNotation.values.where((item) => item.name == json['notation']).firstOrNull;
    final roundingMode = version == 1
        ? DecimalRoundingMode.nearestEven
        : DecimalRoundingMode.values
              .where((item) => item.name == json['roundingMode'])
              .firstOrNull;
    if (theme == null || notation == null || roundingMode == null) {
      throw const FormatException('Invalid UnitFlow appearance or conversion settings.');
    }

    final favoritesRaw = json['favoriteUnitIds'];
    final pinsRaw = json['pinnedPairs'];
    final recentsRaw = json['recents'];
    final customRaw = json['customUnits'];
    if (favoritesRaw is! List<Object?> ||
        pinsRaw is! List<Object?> ||
        recentsRaw is! List<Object?> ||
        customRaw is! List<Object?>) {
      throw const FormatException('Invalid UnitFlow user data.');
    }
    if (pinsRaw.length > maxPinnedPairs ||
        recentsRaw.length > maxStoredRecents ||
        customRaw.length > maxCustomUnits) {
      throw const FormatException('UnitFlow user data exceeds supported collection limits.');
    }

    final favorites = <String>{};
    for (final value in favoritesRaw) {
      if (value is! String || !_unitIdPattern.hasMatch(value)) {
        throw const FormatException('Invalid favorite unit data.');
      }
      if (!favorites.add(value)) {
        throw const FormatException('Duplicate favorite unit data.');
      }
    }

    final pins = <PinnedPair>[];
    final pinKeys = <String>{};
    for (final value in pinsRaw) {
      if (value is! String) {
        throw const FormatException('Invalid pinned pair data.');
      }
      final pin = PinnedPair.tryParse(value);
      if (pin == null || !pinKeys.add(pin.storageValue)) {
        throw const FormatException('Invalid pinned pair data.');
      }
      pins.add(pin);
    }

    final recents = <RecentConversion>[];
    for (final value in recentsRaw) {
      final normalized = _stringKeyedMap(value);
      final recent = RecentConversion.tryFromJson(normalized);
      if (recent == null) {
        throw const FormatException('Invalid conversion history data.');
      }
      recents.add(recent);
    }

    final customUnits = <CustomUnitData>[];
    final customUnitIds = <String>{};
    for (final value in customRaw) {
      final normalized = _stringKeyedMap(value);
      final unit = CustomUnitData.tryFromJson(normalized);
      if (unit == null || !customUnitIds.add(unit.id)) {
        throw const FormatException('Invalid custom unit data.');
      }
      customUnits.add(unit);
    }

    return UserState(
      theme: theme,
      notation: notation,
      roundingMode: roundingMode,
      decimalPlaces: decimalPlaces,
      useGrouping: useGrouping,
      reduceMotion: reduceMotionValue as bool? ?? false,
      onboardingComplete: onboardingComplete,
      favoriteUnitIds: favorites,
      pinnedPairs: pins,
      recents: recents,
      customUnits: customUnits,
    );
  }
}

Map<String, Object?>? _stringKeyedMap(Object? value) {
  if (value is! Map<Object?, Object?>) {
    return null;
  }
  final result = <String, Object?>{};
  for (final entry in value.entries) {
    if (entry.key is! String) {
      return null;
    }
    result[entry.key! as String] = entry.value;
  }
  return result;
}

bool _containsOnlyKeys(Map<String, Object?> value, Set<String> allowed) =>
    value.keys.every(allowed.contains);

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
