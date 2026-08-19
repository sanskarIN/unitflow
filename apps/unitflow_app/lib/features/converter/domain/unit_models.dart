import '../../../core/math/exact_decimal.dart';

enum UnitCategory {
  length,
  area,
  volume,
  mass,
  speed,
  pressure,
  energy,
  power,
  angle,
  dataSize,
  frequency,
  time,
  temperature,
}

extension UnitCategoryInfo on UnitCategory {
  String get id => switch (this) {
    UnitCategory.length => 'length',
    UnitCategory.area => 'area',
    UnitCategory.volume => 'volume',
    UnitCategory.mass => 'mass',
    UnitCategory.speed => 'speed',
    UnitCategory.pressure => 'pressure',
    UnitCategory.energy => 'energy',
    UnitCategory.power => 'power',
    UnitCategory.angle => 'angle',
    UnitCategory.dataSize => 'data_size',
    UnitCategory.frequency => 'frequency',
    UnitCategory.time => 'time',
    UnitCategory.temperature => 'temperature',
  };

  String get label => switch (this) {
    UnitCategory.length => 'Length',
    UnitCategory.area => 'Area',
    UnitCategory.volume => 'Volume',
    UnitCategory.mass => 'Mass',
    UnitCategory.speed => 'Speed',
    UnitCategory.pressure => 'Pressure',
    UnitCategory.energy => 'Energy',
    UnitCategory.power => 'Power',
    UnitCategory.angle => 'Angle',
    UnitCategory.dataSize => 'Data size',
    UnitCategory.frequency => 'Frequency',
    UnitCategory.time => 'Time',
    UnitCategory.temperature => 'Temperature',
  };

  String get explanation => switch (this) {
    UnitCategory.length =>
      'Length measures distance between points. UnitFlow uses the meter as its base.',
    UnitCategory.area =>
      'Area measures two-dimensional surface size. UnitFlow uses the square meter as its base.',
    UnitCategory.volume =>
      'Volume measures three-dimensional capacity. UnitFlow uses the liter as its base.',
    UnitCategory.mass =>
      'Mass measures the amount of matter. UnitFlow uses the kilogram as its base.',
    UnitCategory.speed =>
      'Speed measures distance traveled per unit time. UnitFlow uses meters per second as its base.',
    UnitCategory.pressure =>
      'Pressure measures force per area. UnitFlow uses the pascal as its base.',
    UnitCategory.energy =>
      'Energy measures capacity to do work. UnitFlow uses the joule as its base.',
    UnitCategory.power =>
      'Power measures energy transferred per unit time. UnitFlow uses the watt as its base.',
    UnitCategory.angle =>
      'Plane angle describes rotation. UnitFlow uses the radian as its base.',
    UnitCategory.dataSize =>
      'Data size measures digital information. UnitFlow uses the byte as its base and distinguishes decimal from binary prefixes.',
    UnitCategory.frequency =>
      'Frequency counts repeated events per second. UnitFlow uses the hertz as its base.',
    UnitCategory.time =>
      'Time measures duration. UnitFlow uses the second as its base.',
    UnitCategory.temperature =>
      'Temperature conversions are affine rather than purely multiplicative. UnitFlow uses kelvin as its base.',
  };

  String get example => switch (this) {
    UnitCategory.length => 'Example: 1 km = 1000 m',
    UnitCategory.area => 'Example: 1 ha = 10,000 m²',
    UnitCategory.volume => 'Example: 1 L = 1000 mL',
    UnitCategory.mass => 'Example: 1 kg = 1000 g',
    UnitCategory.speed => 'Example: 36 km/h = 10 m/s',
    UnitCategory.pressure => 'Example: 1 bar = 100,000 Pa',
    UnitCategory.energy => 'Example: 1 kWh = 3,600,000 J',
    UnitCategory.power => 'Example: 1 kW = 1000 W',
    UnitCategory.angle => 'Example: 180° = π rad',
    UnitCategory.dataSize => 'Example: 1 KiB = 1024 B',
    UnitCategory.frequency => 'Example: 1 kHz = 1000 Hz',
    UnitCategory.time => 'Example: 1 h = 3600 s',
    UnitCategory.temperature => 'Example: 0 °C = 32 °F',
  };
}

final class UnitDefinition {
  UnitDefinition({
    required this.id,
    required this.category,
    required this.name,
    required this.symbol,
    required this.scale,
    ExactDecimal? offset,
    this.aliases = const <String>[],
    this.description = '',
    this.isBuiltIn = true,
  }) : offset = offset ?? ExactDecimal.zero;

  final String id;
  final UnitCategory category;
  final String name;
  final String symbol;
  final ExactDecimal scale;
  final ExactDecimal offset;
  final List<String> aliases;
  final String description;
  final bool isBuiltIn;

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return true;
    }
    return id.toLowerCase().contains(normalized) ||
        name.toLowerCase().contains(normalized) ||
        symbol.toLowerCase().contains(normalized) ||
        description.toLowerCase().contains(normalized) ||
        aliases.any((alias) => alias.toLowerCase().contains(normalized));
  }
}

final class ConversionResult {
  const ConversionResult({
    required this.input,
    required this.output,
    required this.from,
    required this.to,
  });

  final ExactDecimal input;
  final ExactDecimal output;
  final UnitDefinition from;
  final UnitDefinition to;
}

final class PinnedPair {
  const PinnedPair({
    required this.category,
    required this.fromUnitId,
    required this.toUnitId,
  });

  static final RegExp _unitIdPattern = RegExp(r'^[a-z0-9_-]{1,64}$');

  final UnitCategory category;
  final String fromUnitId;
  final String toUnitId;

  String get storageValue => '${category.id}|$fromUnitId|$toUnitId';

  static PinnedPair? tryParse(String value) {
    if (value.length > 256) {
      return null;
    }
    final parts = value.split('|');
    if (parts.length != 3) {
      return null;
    }
    UnitCategory? category;
    for (final candidate in UnitCategory.values) {
      if (candidate.id == parts[0]) {
        category = candidate;
        break;
      }
    }
    if (category == null ||
        !_unitIdPattern.hasMatch(parts[1]) ||
        !_unitIdPattern.hasMatch(parts[2])) {
      return null;
    }
    return PinnedPair(
      category: category,
      fromUnitId: parts[1],
      toUnitId: parts[2],
    );
  }
}
