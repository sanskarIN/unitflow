import 'unit_model.dart';

const List<ConversionUnit> unitCatalog = <ConversionUnit>[
  ConversionUnit(id: 'meter', category: UnitCategory.length, name: 'Meter', symbol: 'm', factorToBase: 1, aliases: <String>['metre'], description: 'SI base unit of length.'),
  ConversionUnit(id: 'kilometer', category: UnitCategory.length, name: 'Kilometer', symbol: 'km', factorToBase: 1000, aliases: <String>['kilometre'], description: 'One thousand meters.'),
  ConversionUnit(id: 'centimeter', category: UnitCategory.length, name: 'Centimeter', symbol: 'cm', factorToBase: 0.01, description: 'One hundredth of a meter.'),
  ConversionUnit(id: 'millimeter', category: UnitCategory.length, name: 'Millimeter', symbol: 'mm', factorToBase: 0.001, description: 'One thousandth of a meter.'),
  ConversionUnit(id: 'inch', category: UnitCategory.length, name: 'Inch', symbol: 'in', factorToBase: 0.0254, aliases: <String>['inches'], description: 'Exactly 2.54 centimeters.'),
  ConversionUnit(id: 'foot', category: UnitCategory.length, name: 'Foot', symbol: 'ft', factorToBase: 0.3048, aliases: <String>['feet'], description: 'Twelve inches.'),
  ConversionUnit(id: 'yard', category: UnitCategory.length, name: 'Yard', symbol: 'yd', factorToBase: 0.9144, description: 'Three feet.'),
  ConversionUnit(id: 'mile', category: UnitCategory.length, name: 'Mile', symbol: 'mi', factorToBase: 1609.344, description: '5,280 feet.'),
  ConversionUnit(id: 'nautical_mile', category: UnitCategory.length, name: 'Nautical mile', symbol: 'nmi', factorToBase: 1852, description: 'International nautical mile.'),

  ConversionUnit(id: 'kilogram', category: UnitCategory.mass, name: 'Kilogram', symbol: 'kg', factorToBase: 1, description: 'SI base unit of mass.'),
  ConversionUnit(id: 'gram', category: UnitCategory.mass, name: 'Gram', symbol: 'g', factorToBase: 0.001, description: 'One thousandth of a kilogram.'),
  ConversionUnit(id: 'milligram', category: UnitCategory.mass, name: 'Milligram', symbol: 'mg', factorToBase: 0.000001, description: 'One millionth of a kilogram.'),
  ConversionUnit(id: 'tonne', category: UnitCategory.mass, name: 'Metric tonne', symbol: 't', factorToBase: 1000, aliases: <String>['metric ton'], description: 'One thousand kilograms.'),
  ConversionUnit(id: 'ounce', category: UnitCategory.mass, name: 'Ounce', symbol: 'oz', factorToBase: 0.028349523125, description: 'International avoirdupois ounce.'),
  ConversionUnit(id: 'pound', category: UnitCategory.mass, name: 'Pound', symbol: 'lb', factorToBase: 0.45359237, aliases: <String>['lbs'], description: 'International avoirdupois pound.'),

  ConversionUnit(id: 'kelvin', category: UnitCategory.temperature, name: 'Kelvin', symbol: 'K', factorToBase: 1, description: 'SI base unit of thermodynamic temperature.'),
  ConversionUnit(id: 'celsius', category: UnitCategory.temperature, name: 'Celsius', symbol: '°C', factorToBase: 1, aliases: <String>['centigrade'], description: 'Temperature scale offset from kelvin by 273.15.'),
  ConversionUnit(id: 'fahrenheit', category: UnitCategory.temperature, name: 'Fahrenheit', symbol: '°F', factorToBase: 1, description: 'Fahrenheit temperature scale.'),

  ConversionUnit(id: 'second', category: UnitCategory.time, name: 'Second', symbol: 's', factorToBase: 1, description: 'SI base unit of time.'),
  ConversionUnit(id: 'millisecond', category: UnitCategory.time, name: 'Millisecond', symbol: 'ms', factorToBase: 0.001, description: 'One thousandth of a second.'),
  ConversionUnit(id: 'minute', category: UnitCategory.time, name: 'Minute', symbol: 'min', factorToBase: 60, description: 'Sixty seconds.'),
  ConversionUnit(id: 'hour', category: UnitCategory.time, name: 'Hour', symbol: 'h', factorToBase: 3600, description: 'Sixty minutes.'),
  ConversionUnit(id: 'day', category: UnitCategory.time, name: 'Day', symbol: 'd', factorToBase: 86400, description: 'Twenty-four hours.'),
  ConversionUnit(id: 'week', category: UnitCategory.time, name: 'Week', symbol: 'wk', factorToBase: 604800, description: 'Seven days.'),

  ConversionUnit(id: 'square_meter', category: UnitCategory.area, name: 'Square meter', symbol: 'm²', factorToBase: 1, aliases: <String>['sqm'], description: 'Area of a one-meter square.'),
  ConversionUnit(id: 'square_kilometer', category: UnitCategory.area, name: 'Square kilometer', symbol: 'km²', factorToBase: 1000000, description: 'One million square meters.'),
  ConversionUnit(id: 'square_foot', category: UnitCategory.area, name: 'Square foot', symbol: 'ft²', factorToBase: 0.09290304, aliases: <String>['sq ft'], description: 'Area of a one-foot square.'),
  ConversionUnit(id: 'acre', category: UnitCategory.area, name: 'Acre', symbol: 'ac', factorToBase: 4046.8564224, description: '43,560 square feet.'),
  ConversionUnit(id: 'hectare', category: UnitCategory.area, name: 'Hectare', symbol: 'ha', factorToBase: 10000, description: 'Ten thousand square meters.'),

  ConversionUnit(id: 'liter', category: UnitCategory.volume, name: 'Liter', symbol: 'L', factorToBase: 1, aliases: <String>['litre'], description: 'Metric unit of volume.'),
  ConversionUnit(id: 'milliliter', category: UnitCategory.volume, name: 'Milliliter', symbol: 'mL', factorToBase: 0.001, aliases: <String>['ml'], description: 'One thousandth of a liter.'),
  ConversionUnit(id: 'cubic_meter', category: UnitCategory.volume, name: 'Cubic meter', symbol: 'm³', factorToBase: 1000, description: 'One thousand liters.'),
  ConversionUnit(id: 'us_teaspoon', category: UnitCategory.volume, name: 'US teaspoon', symbol: 'tsp', factorToBase: 0.00492892159375, description: 'US customary teaspoon.'),
  ConversionUnit(id: 'us_tablespoon', category: UnitCategory.volume, name: 'US tablespoon', symbol: 'tbsp', factorToBase: 0.01478676478125, description: 'US customary tablespoon.'),
  ConversionUnit(id: 'us_cup', category: UnitCategory.volume, name: 'US cup', symbol: 'cup', factorToBase: 0.2365882365, description: 'US customary cup.'),
  ConversionUnit(id: 'us_gallon', category: UnitCategory.volume, name: 'US gallon', symbol: 'gal', factorToBase: 3.785411784, description: 'US customary liquid gallon.'),

  ConversionUnit(id: 'meter_per_second', category: UnitCategory.speed, name: 'Meter per second', symbol: 'm/s', factorToBase: 1, aliases: <String>['mps'], description: 'SI derived unit of speed.'),
  ConversionUnit(id: 'kilometer_per_hour', category: UnitCategory.speed, name: 'Kilometer per hour', symbol: 'km/h', factorToBase: 1 / 3.6, aliases: <String>['kph', 'kmph'], description: 'Kilometers traveled in one hour.'),
  ConversionUnit(id: 'mile_per_hour', category: UnitCategory.speed, name: 'Mile per hour', symbol: 'mph', factorToBase: 0.44704, description: 'Miles traveled in one hour.'),
  ConversionUnit(id: 'knot', category: UnitCategory.speed, name: 'Knot', symbol: 'kn', factorToBase: 1852 / 3600, aliases: <String>['kt'], description: 'One nautical mile per hour.'),

  ConversionUnit(id: 'byte', category: UnitCategory.data, name: 'Byte', symbol: 'B', factorToBase: 1, description: 'Eight bits.'),
  ConversionUnit(id: 'bit', category: UnitCategory.data, name: 'Bit', symbol: 'bit', factorToBase: 0.125, description: 'One eighth of a byte.'),
  ConversionUnit(id: 'kilobyte', category: UnitCategory.data, name: 'Kilobyte', symbol: 'kB', factorToBase: 1000, description: 'One thousand bytes.'),
  ConversionUnit(id: 'megabyte', category: UnitCategory.data, name: 'Megabyte', symbol: 'MB', factorToBase: 1000000, description: 'One million bytes.'),
  ConversionUnit(id: 'gigabyte', category: UnitCategory.data, name: 'Gigabyte', symbol: 'GB', factorToBase: 1000000000, description: 'One billion bytes.'),
  ConversionUnit(id: 'kibibyte', category: UnitCategory.data, name: 'Kibibyte', symbol: 'KiB', factorToBase: 1024, description: '1,024 bytes.'),
  ConversionUnit(id: 'mebibyte', category: UnitCategory.data, name: 'Mebibyte', symbol: 'MiB', factorToBase: 1048576, description: '1,048,576 bytes.'),

  ConversionUnit(id: 'pascal', category: UnitCategory.pressure, name: 'Pascal', symbol: 'Pa', factorToBase: 1, description: 'SI derived unit of pressure.'),
  ConversionUnit(id: 'kilopascal', category: UnitCategory.pressure, name: 'Kilopascal', symbol: 'kPa', factorToBase: 1000, description: 'One thousand pascals.'),
  ConversionUnit(id: 'bar', category: UnitCategory.pressure, name: 'Bar', symbol: 'bar', factorToBase: 100000, description: 'One hundred kilopascals.'),
  ConversionUnit(id: 'atmosphere', category: UnitCategory.pressure, name: 'Standard atmosphere', symbol: 'atm', factorToBase: 101325, description: 'Standard atmosphere.'),
  ConversionUnit(id: 'psi', category: UnitCategory.pressure, name: 'Pound per square inch', symbol: 'psi', factorToBase: 6894.757293168, description: 'Pressure in pounds-force per square inch.'),

  ConversionUnit(id: 'joule', category: UnitCategory.energy, name: 'Joule', symbol: 'J', factorToBase: 1, description: 'SI derived unit of energy.'),
  ConversionUnit(id: 'kilojoule', category: UnitCategory.energy, name: 'Kilojoule', symbol: 'kJ', factorToBase: 1000, description: 'One thousand joules.'),
  ConversionUnit(id: 'calorie', category: UnitCategory.energy, name: 'Calorie', symbol: 'cal', factorToBase: 4.184, description: 'Thermochemical calorie.'),
  ConversionUnit(id: 'kilocalorie', category: UnitCategory.energy, name: 'Kilocalorie', symbol: 'kcal', factorToBase: 4184, aliases: <String>['food calorie'], description: 'One thousand thermochemical calories.'),
  ConversionUnit(id: 'watt_hour', category: UnitCategory.energy, name: 'Watt-hour', symbol: 'Wh', factorToBase: 3600, description: 'Energy from one watt over one hour.'),
  ConversionUnit(id: 'kilowatt_hour', category: UnitCategory.energy, name: 'Kilowatt-hour', symbol: 'kWh', factorToBase: 3600000, description: 'Energy from one kilowatt over one hour.'),

  ConversionUnit(id: 'watt', category: UnitCategory.power, name: 'Watt', symbol: 'W', factorToBase: 1, description: 'SI derived unit of power.'),
  ConversionUnit(id: 'kilowatt', category: UnitCategory.power, name: 'Kilowatt', symbol: 'kW', factorToBase: 1000, description: 'One thousand watts.'),
  ConversionUnit(id: 'megawatt', category: UnitCategory.power, name: 'Megawatt', symbol: 'MW', factorToBase: 1000000, description: 'One million watts.'),
  ConversionUnit(id: 'horsepower', category: UnitCategory.power, name: 'Mechanical horsepower', symbol: 'hp', factorToBase: 745.69987158227022, description: 'Mechanical horsepower.'),

  ConversionUnit(id: 'radian', category: UnitCategory.angle, name: 'Radian', symbol: 'rad', factorToBase: 1, description: 'SI derived unit of plane angle.'),
  ConversionUnit(id: 'degree', category: UnitCategory.angle, name: 'Degree', symbol: '°', factorToBase: 0.017453292519943295, aliases: <String>['deg'], description: 'One 360th of a full turn.'),
  ConversionUnit(id: 'gradian', category: UnitCategory.angle, name: 'Gradian', symbol: 'gon', factorToBase: 0.015707963267948967, aliases: <String>['grad'], description: 'One 400th of a full turn.'),
  ConversionUnit(id: 'turn', category: UnitCategory.angle, name: 'Turn', symbol: 'turn', factorToBase: 6.283185307179586, aliases: <String>['revolution', 'rev'], description: 'One full revolution.'),
];

List<ConversionUnit> unitsForCategory(UnitCategory category) {
  return unitCatalog
      .where((ConversionUnit unit) => unit.category == category)
      .toList(growable: false);
}

List<ConversionUnit> searchCatalog(String query) {
  return unitCatalog
      .where((ConversionUnit unit) => unit.matches(query))
      .toList(growable: false);
}
