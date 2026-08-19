enum UnitCategory {
  length,
  mass,
  temperature,
  time,
  area,
  volume,
  speed,
  data,
  pressure,
  energy,
  power,
  angle,
}

extension UnitCategoryLabel on UnitCategory {
  String get label {
    switch (this) {
      case UnitCategory.length:
        return 'Length';
      case UnitCategory.mass:
        return 'Mass';
      case UnitCategory.temperature:
        return 'Temperature';
      case UnitCategory.time:
        return 'Time';
      case UnitCategory.area:
        return 'Area';
      case UnitCategory.volume:
        return 'Volume';
      case UnitCategory.speed:
        return 'Speed';
      case UnitCategory.data:
        return 'Data';
      case UnitCategory.pressure:
        return 'Pressure';
      case UnitCategory.energy:
        return 'Energy';
      case UnitCategory.power:
        return 'Power';
      case UnitCategory.angle:
        return 'Angle';
    }
  }
}

class ConversionUnit {
  const ConversionUnit({
    required this.id,
    required this.category,
    required this.name,
    required this.symbol,
    required this.factorToBase,
    required this.description,
    this.aliases = const <String>[],
  });

  final String id;
  final UnitCategory category;
  final String name;
  final String symbol;
  final double factorToBase;
  final String description;
  final List<String> aliases;

  String get displayName => '$name ($symbol)';

  bool matches(String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return true;
    }
    return id.toLowerCase().contains(needle) ||
        name.toLowerCase().contains(needle) ||
        symbol.toLowerCase().contains(needle) ||
        description.toLowerCase().contains(needle) ||
        aliases.any((String value) => value.toLowerCase().contains(needle));
  }
}
