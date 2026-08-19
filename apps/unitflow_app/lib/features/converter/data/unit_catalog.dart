import '../../../core/math/exact_decimal.dart';
import '../domain/unit_models.dart';

/// Immutable catalog snapshot used by Flutter while native Rust bindings initialize or when the
/// web fallback is selected. IDs and affine factors mirror the Rust core catalog.
final class UnitCatalog {
  UnitCatalog([List<UnitDefinition>? units])
    : units = List<UnitDefinition>.unmodifiable(units ?? builtInUnits) {
    for (final unit in this.units) {
      if (_byId.containsKey(unit.id)) {
        throw StateError('Duplicate unit id: ${unit.id}');
      }
      _byId[unit.id] = unit;
    }
  }

  final List<UnitDefinition> units;
  final Map<String, UnitDefinition> _byId = <String, UnitDefinition>{};

  UnitDefinition? byId(String id) => _byId[id];

  List<UnitDefinition> forCategory(UnitCategory category) =>
      units.where((unit) => unit.category == category).toList(growable: false);

  List<UnitDefinition> search(
    String query, {
    UnitCategory? category,
    int limit = 30,
  }) {
    if (limit <= 0) {
      return const <UnitDefinition>[];
    }
    final normalized = query.trim().toLowerCase();
    final matches = units
        .where((unit) => category == null || unit.category == category)
        .where((unit) => unit.matches(normalized))
        .map((unit) => (_score(unit, normalized), unit))
        .toList();
    matches.sort((left, right) {
      final score = left.$1.compareTo(right.$1);
      return score != 0 ? score : left.$2.name.compareTo(right.$2.name);
    });
    return matches.take(limit).map((entry) => entry.$2).toList(growable: false);
  }

  static final List<UnitDefinition> builtInUnits = List<UnitDefinition>.unmodifiable(<UnitDefinition>[
    // Length.
    _u('meter', UnitCategory.length, 'Meter', 'm', '1', aliases: <String>['metre', 'meters', 'metres']),
    _u('kilometer', UnitCategory.length, 'Kilometer', 'km', '1000', aliases: <String>['kilometre', 'kilo meter']),
    _u('centimeter', UnitCategory.length, 'Centimeter', 'cm', '0.01', aliases: <String>['centimetre']),
    _u('millimeter', UnitCategory.length, 'Millimeter', 'mm', '0.001', aliases: <String>['millimetre']),
    _u('micrometer', UnitCategory.length, 'Micrometer', 'µm', '0.000001', aliases: <String>['micrometre', 'um', 'micron']),
    _u('nanometer', UnitCategory.length, 'Nanometer', 'nm', '0.000000001', aliases: <String>['nanometre']),
    _u('inch', UnitCategory.length, 'Inch', 'in', '0.0254', aliases: <String>['inches']),
    _u('foot', UnitCategory.length, 'Foot', 'ft', '0.3048', aliases: <String>['feet']),
    _u('yard', UnitCategory.length, 'Yard', 'yd', '0.9144', aliases: <String>['yards']),
    _u('mile', UnitCategory.length, 'Mile', 'mi', '1609.344', aliases: <String>['miles', 'statute mile']),
    _u('nautical_mile', UnitCategory.length, 'Nautical Mile', 'nmi', '1852', aliases: <String>['nautical miles']),

    // Area.
    _u('square_meter', UnitCategory.area, 'Square Meter', 'm²', '1', aliases: <String>['m2', 'square metre']),
    _u('square_kilometer', UnitCategory.area, 'Square Kilometer', 'km²', '1000000', aliases: <String>['km2', 'square kilometre']),
    _u('square_centimeter', UnitCategory.area, 'Square Centimeter', 'cm²', '0.0001', aliases: <String>['cm2']),
    _u('square_millimeter', UnitCategory.area, 'Square Millimeter', 'mm²', '0.000001', aliases: <String>['mm2']),
    _u('hectare', UnitCategory.area, 'Hectare', 'ha', '10000', aliases: <String>['hectares']),
    _u('acre', UnitCategory.area, 'Acre', 'ac', '4046.8564224', aliases: <String>['acres']),
    _u('square_foot', UnitCategory.area, 'Square Foot', 'ft²', '0.09290304', aliases: <String>['ft2', 'square feet']),
    _u('square_inch', UnitCategory.area, 'Square Inch', 'in²', '0.00064516', aliases: <String>['in2', 'square inches']),
    _u('square_mile', UnitCategory.area, 'Square Mile', 'mi²', '2589988.110336', aliases: <String>['mi2']),

    // Volume.
    _u('liter', UnitCategory.volume, 'Liter', 'L', '1', aliases: <String>['litre', 'liters', 'litres']),
    _u('milliliter', UnitCategory.volume, 'Milliliter', 'mL', '0.001', aliases: <String>['millilitre', 'ml']),
    _u('cubic_meter', UnitCategory.volume, 'Cubic Meter', 'm³', '1000', aliases: <String>['m3', 'cubic metre']),
    _u('cubic_centimeter', UnitCategory.volume, 'Cubic Centimeter', 'cm³', '0.001', aliases: <String>['cm3', 'cc']),
    _u('teaspoon_us', UnitCategory.volume, 'US Teaspoon', 'tsp', '0.00492892159375', aliases: <String>['teaspoon']),
    _u('tablespoon_us', UnitCategory.volume, 'US Tablespoon', 'tbsp', '0.01478676478125', aliases: <String>['tablespoon']),
    _u('fluid_ounce_us', UnitCategory.volume, 'US Fluid Ounce', 'fl oz', '0.0295735295625', aliases: <String>['fluid ounce']),
    _u('cup_us', UnitCategory.volume, 'US Cup', 'cup', '0.2365882365', aliases: <String>['cups']),
    _u('pint_us', UnitCategory.volume, 'US Pint', 'pt', '0.473176473', aliases: <String>['pints']),
    _u('quart_us', UnitCategory.volume, 'US Quart', 'qt', '0.946352946', aliases: <String>['quarts']),
    _u('gallon_us', UnitCategory.volume, 'US Gallon', 'gal', '3.785411784', aliases: <String>['us gallon', 'gallons']),
    _u('gallon_imperial', UnitCategory.volume, 'Imperial Gallon', 'imp gal', '4.54609', aliases: <String>['uk gallon']),

    // Mass.
    _u('kilogram', UnitCategory.mass, 'Kilogram', 'kg', '1', aliases: <String>['kilograms', 'kilo']),
    _u('gram', UnitCategory.mass, 'Gram', 'g', '0.001', aliases: <String>['grams']),
    _u('milligram', UnitCategory.mass, 'Milligram', 'mg', '0.000001', aliases: <String>['milligrams']),
    _u('microgram', UnitCategory.mass, 'Microgram', 'µg', '0.000000001', aliases: <String>['ug', 'micrograms']),
    _u('metric_tonne', UnitCategory.mass, 'Metric Tonne', 't', '1000', aliases: <String>['tonne', 'metric ton']),
    _u('pound', UnitCategory.mass, 'Pound', 'lb', '0.45359237', aliases: <String>['pounds', 'lbs']),
    _u('ounce', UnitCategory.mass, 'Ounce', 'oz', '0.028349523125', aliases: <String>['ounces']),
    _u('stone', UnitCategory.mass, 'Stone', 'st', '6.35029318', aliases: <String>['stones']),

    // Speed.
    _u('meter_per_second', UnitCategory.speed, 'Meter per Second', 'm/s', '1', aliases: <String>['mps', 'meters per second']),
    _u('kilometer_per_hour', UnitCategory.speed, 'Kilometer per Hour', 'km/h', '0.2777777777777777777777777778', aliases: <String>['kph', 'kmph']),
    _u('mile_per_hour', UnitCategory.speed, 'Mile per Hour', 'mph', '0.44704', aliases: <String>['miles per hour']),
    _u('foot_per_second', UnitCategory.speed, 'Foot per Second', 'ft/s', '0.3048', aliases: <String>['fps', 'feet per second']),
    _u('knot', UnitCategory.speed, 'Knot', 'kn', '0.5144444444444444444444444444', aliases: <String>['knots']),

    // Pressure.
    _u('pascal', UnitCategory.pressure, 'Pascal', 'Pa', '1', aliases: <String>['pascals']),
    _u('kilopascal', UnitCategory.pressure, 'Kilopascal', 'kPa', '1000', aliases: <String>['kilopascals']),
    _u('megapascal', UnitCategory.pressure, 'Megapascal', 'MPa', '1000000', aliases: <String>['megapascals']),
    _u('bar', UnitCategory.pressure, 'Bar', 'bar', '100000', aliases: <String>['bars']),
    _u('millibar', UnitCategory.pressure, 'Millibar', 'mbar', '100', aliases: <String>['millibars', 'hectopascal']),
    _u('standard_atmosphere', UnitCategory.pressure, 'Standard Atmosphere', 'atm', '101325', aliases: <String>['atmosphere']),
    _u('psi', UnitCategory.pressure, 'Pound per Square Inch', 'psi', '6894.757293168361', aliases: <String>['pounds per square inch']),
    _u('torr', UnitCategory.pressure, 'Torr', 'Torr', '133.3223684210526315789473684', aliases: <String>['mmhg']),

    // Energy.
    _u('joule', UnitCategory.energy, 'Joule', 'J', '1', aliases: <String>['joules']),
    _u('kilojoule', UnitCategory.energy, 'Kilojoule', 'kJ', '1000', aliases: <String>['kilojoules']),
    _u('calorie', UnitCategory.energy, 'Calorie', 'cal', '4.184', aliases: <String>['thermochemical calorie']),
    _u('kilocalorie', UnitCategory.energy, 'Kilocalorie', 'kcal', '4184', aliases: <String>['food calorie']),
    _u('watt_hour', UnitCategory.energy, 'Watt-hour', 'Wh', '3600', aliases: <String>['watt hour']),
    _u('kilowatt_hour', UnitCategory.energy, 'Kilowatt-hour', 'kWh', '3600000', aliases: <String>['kilowatt hour']),
    _u('btu_it', UnitCategory.energy, 'British Thermal Unit (IT)', 'BTU', '1055.05585262', aliases: <String>['btu']),
    _u('electronvolt', UnitCategory.energy, 'Electronvolt', 'eV', '0.0000000000000000001602176634', aliases: <String>['electron volt']),

    // Power.
    _u('watt', UnitCategory.power, 'Watt', 'W', '1', aliases: <String>['watts']),
    _u('kilowatt', UnitCategory.power, 'Kilowatt', 'kW', '1000', aliases: <String>['kilowatts']),
    _u('megawatt', UnitCategory.power, 'Megawatt', 'MW', '1000000', aliases: <String>['megawatts']),
    _u('gigawatt', UnitCategory.power, 'Gigawatt', 'GW', '1000000000', aliases: <String>['gigawatts']),
    _u('horsepower_mechanical', UnitCategory.power, 'Mechanical Horsepower', 'hp', '745.69987158227022', aliases: <String>['horsepower']),
    _u('horsepower_metric', UnitCategory.power, 'Metric Horsepower', 'PS', '735.49875', aliases: <String>['metric hp']),

    // Angle.
    _u('radian', UnitCategory.angle, 'Radian', 'rad', '1', aliases: <String>['radians']),
    _u('degree', UnitCategory.angle, 'Degree', '°', '0.0174532925199432957692369077', aliases: <String>['degrees', 'deg']),
    _u('gradian', UnitCategory.angle, 'Gradian', 'gon', '0.0157079632679489661923132169', aliases: <String>['grad']),
    _u('turn', UnitCategory.angle, 'Turn', 'turn', '6.2831853071795864769252867666', aliases: <String>['revolution', 'cycle']),
    _u('arcminute', UnitCategory.angle, 'Arcminute', '′', '0.0002908882086657215961539485', aliases: <String>['arcmin']),
    _u('arcsecond', UnitCategory.angle, 'Arcsecond', '″', '0.0000048481368110953599358991', aliases: <String>['arcsec']),

    // Data size.
    _u('byte', UnitCategory.dataSize, 'Byte', 'B', '1', aliases: <String>['bytes', 'octet']),
    _u('bit', UnitCategory.dataSize, 'Bit', 'bit', '0.125', aliases: <String>['bits']),
    _u('kilobyte', UnitCategory.dataSize, 'Kilobyte', 'kB', '1000', aliases: <String>['kb decimal']),
    _u('megabyte', UnitCategory.dataSize, 'Megabyte', 'MB', '1000000', aliases: <String>['mb decimal']),
    _u('gigabyte', UnitCategory.dataSize, 'Gigabyte', 'GB', '1000000000', aliases: <String>['gb decimal']),
    _u('terabyte', UnitCategory.dataSize, 'Terabyte', 'TB', '1000000000000', aliases: <String>['tb decimal']),
    _u('kibibyte', UnitCategory.dataSize, 'Kibibyte', 'KiB', '1024', aliases: <String>['kib']),
    _u('mebibyte', UnitCategory.dataSize, 'Mebibyte', 'MiB', '1048576', aliases: <String>['mib']),
    _u('gibibyte', UnitCategory.dataSize, 'Gibibyte', 'GiB', '1073741824', aliases: <String>['gib']),
    _u('tebibyte', UnitCategory.dataSize, 'Tebibyte', 'TiB', '1099511627776', aliases: <String>['tib']),

    // Frequency.
    _u('hertz', UnitCategory.frequency, 'Hertz', 'Hz', '1', aliases: <String>['hz', 'cycles per second']),
    _u('kilohertz', UnitCategory.frequency, 'Kilohertz', 'kHz', '1000', aliases: <String>['khz']),
    _u('megahertz', UnitCategory.frequency, 'Megahertz', 'MHz', '1000000', aliases: <String>['mhz']),
    _u('gigahertz', UnitCategory.frequency, 'Gigahertz', 'GHz', '1000000000', aliases: <String>['ghz']),
    _u('revolution_per_minute', UnitCategory.frequency, 'Revolution per Minute', 'rpm', '0.0166666666666666666666666667', aliases: <String>['revolutions per minute']),

    // Time.
    _u('second', UnitCategory.time, 'Second', 's', '1', aliases: <String>['seconds', 'sec']),
    _u('millisecond', UnitCategory.time, 'Millisecond', 'ms', '0.001', aliases: <String>['milliseconds']),
    _u('microsecond', UnitCategory.time, 'Microsecond', 'µs', '0.000001', aliases: <String>['us', 'microseconds']),
    _u('nanosecond', UnitCategory.time, 'Nanosecond', 'ns', '0.000000001', aliases: <String>['nanoseconds']),
    _u('minute', UnitCategory.time, 'Minute', 'min', '60', aliases: <String>['minutes']),
    _u('hour', UnitCategory.time, 'Hour', 'h', '3600', aliases: <String>['hours', 'hr']),
    _u('day', UnitCategory.time, 'Day', 'd', '86400', aliases: <String>['days']),
    _u('week', UnitCategory.time, 'Week', 'wk', '604800', aliases: <String>['weeks']),
    _u('julian_year', UnitCategory.time, 'Julian Year', 'a', '31557600', aliases: <String>['year 365.25 days']),

    // Temperature.
    _u('kelvin', UnitCategory.temperature, 'Kelvin', 'K', '1', aliases: <String>['kelvins']),
    _u('celsius', UnitCategory.temperature, 'Celsius', '°C', '1', offset: '273.15', aliases: <String>['centigrade', 'degrees celsius']),
    _u('fahrenheit', UnitCategory.temperature, 'Fahrenheit', '°F', '0.5555555555555555555555555556', offset: '255.3722222222222222222222222', aliases: <String>['degrees fahrenheit']),
    _u('rankine', UnitCategory.temperature, 'Rankine', '°R', '0.5555555555555555555555555556', aliases: <String>['degrees rankine']),
  ]);
}

int _score(UnitDefinition unit, String query) {
  if (query.isEmpty) {
    return 3;
  }
  final fields = <String>[unit.id, unit.name, unit.symbol, ...unit.aliases]
      .map((value) => value.toLowerCase());
  var best = 3;
  for (final field in fields) {
    if (field == query) {
      return 0;
    }
    if (field.startsWith(query)) {
      best = best > 1 ? 1 : best;
    } else if (field.contains(query)) {
      best = best > 2 ? 2 : best;
    }
  }
  return best;
}

UnitDefinition _u(
  String id,
  UnitCategory category,
  String name,
  String symbol,
  String scale, {
  String offset = '0',
  List<String> aliases = const <String>[],
  String description = '',
}) => UnitDefinition(
  id: id,
  category: category,
  name: name,
  symbol: symbol,
  scale: ExactDecimal.parse(scale),
  offset: ExactDecimal.parse(offset),
  aliases: aliases,
  description: description,
);
