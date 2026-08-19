/// A conversion category supported by UnitFlow.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum Category {
    Length,
    Mass,
    Temperature,
    Time,
    Area,
    Volume,
    Speed,
    Data,
    Pressure,
    Energy,
    Power,
    Angle,
}

impl Category {
    #[must_use]
    pub const fn label(self) -> &'static str {
        match self {
            Self::Length => "Length",
            Self::Mass => "Mass",
            Self::Temperature => "Temperature",
            Self::Time => "Time",
            Self::Area => "Area",
            Self::Volume => "Volume",
            Self::Speed => "Speed",
            Self::Data => "Data",
            Self::Pressure => "Pressure",
            Self::Energy => "Energy",
            Self::Power => "Power",
            Self::Angle => "Angle",
        }
    }
}

/// Metadata plus a linear factor to the category base unit.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct UnitDef {
    pub id: &'static str,
    pub category: Category,
    pub name: &'static str,
    pub symbol: &'static str,
    pub factor_to_base: &'static str,
    pub aliases: &'static [&'static str],
    pub description: &'static str,
}

pub const UNITS: &[UnitDef] = &[
    UnitDef { id: "meter", category: Category::Length, name: "Meter", symbol: "m", factor_to_base: "1", aliases: &["metre", "meters", "metres"], description: "SI base unit of length." },
    UnitDef { id: "kilometer", category: Category::Length, name: "Kilometer", symbol: "km", factor_to_base: "1000", aliases: &["kilometre", "kilometers", "kilometres"], description: "One thousand meters." },
    UnitDef { id: "centimeter", category: Category::Length, name: "Centimeter", symbol: "cm", factor_to_base: "0.01", aliases: &["centimetre"], description: "One hundredth of a meter." },
    UnitDef { id: "millimeter", category: Category::Length, name: "Millimeter", symbol: "mm", factor_to_base: "0.001", aliases: &["millimetre"], description: "One thousandth of a meter." },
    UnitDef { id: "micrometer", category: Category::Length, name: "Micrometer", symbol: "µm", factor_to_base: "0.000001", aliases: &["micrometre", "micron"], description: "One millionth of a meter." },
    UnitDef { id: "nanometer", category: Category::Length, name: "Nanometer", symbol: "nm", factor_to_base: "0.000000001", aliases: &["nanometre"], description: "One billionth of a meter." },
    UnitDef { id: "inch", category: Category::Length, name: "Inch", symbol: "in", factor_to_base: "0.0254", aliases: &["inches"], description: "Exactly 2.54 centimeters." },
    UnitDef { id: "foot", category: Category::Length, name: "Foot", symbol: "ft", factor_to_base: "0.3048", aliases: &["feet"], description: "Twelve inches." },
    UnitDef { id: "yard", category: Category::Length, name: "Yard", symbol: "yd", factor_to_base: "0.9144", aliases: &["yards"], description: "Three feet." },
    UnitDef { id: "mile", category: Category::Length, name: "Mile", symbol: "mi", factor_to_base: "1609.344", aliases: &["miles"], description: "5,280 feet." },
    UnitDef { id: "nautical_mile", category: Category::Length, name: "Nautical mile", symbol: "nmi", factor_to_base: "1852", aliases: &["nautical miles"], description: "International nautical mile." },

    UnitDef { id: "kilogram", category: Category::Mass, name: "Kilogram", symbol: "kg", factor_to_base: "1", aliases: &["kilograms"], description: "SI base unit of mass." },
    UnitDef { id: "gram", category: Category::Mass, name: "Gram", symbol: "g", factor_to_base: "0.001", aliases: &["grams"], description: "One thousandth of a kilogram." },
    UnitDef { id: "milligram", category: Category::Mass, name: "Milligram", symbol: "mg", factor_to_base: "0.000001", aliases: &["milligrams"], description: "One millionth of a kilogram." },
    UnitDef { id: "microgram", category: Category::Mass, name: "Microgram", symbol: "µg", factor_to_base: "0.000000001", aliases: &["micrograms"], description: "One billionth of a kilogram." },
    UnitDef { id: "tonne", category: Category::Mass, name: "Metric tonne", symbol: "t", factor_to_base: "1000", aliases: &["metric ton", "tonnes"], description: "One thousand kilograms." },
    UnitDef { id: "ounce", category: Category::Mass, name: "Ounce", symbol: "oz", factor_to_base: "0.028349523125", aliases: &["ounces"], description: "International avoirdupois ounce." },
    UnitDef { id: "pound", category: Category::Mass, name: "Pound", symbol: "lb", factor_to_base: "0.45359237", aliases: &["pounds", "lbs"], description: "International avoirdupois pound." },
    UnitDef { id: "stone", category: Category::Mass, name: "Stone", symbol: "st", factor_to_base: "6.35029318", aliases: &["stones"], description: "Fourteen pounds." },

    UnitDef { id: "kelvin", category: Category::Temperature, name: "Kelvin", symbol: "K", factor_to_base: "1", aliases: &["kelvins"], description: "SI base unit of thermodynamic temperature." },
    UnitDef { id: "celsius", category: Category::Temperature, name: "Celsius", symbol: "°C", factor_to_base: "1", aliases: &["centigrade"], description: "Temperature scale offset from kelvin by 273.15." },
    UnitDef { id: "fahrenheit", category: Category::Temperature, name: "Fahrenheit", symbol: "°F", factor_to_base: "1", aliases: &["fahrenheits"], description: "Fahrenheit temperature scale." },

    UnitDef { id: "second", category: Category::Time, name: "Second", symbol: "s", factor_to_base: "1", aliases: &["seconds", "sec"], description: "SI base unit of time." },
    UnitDef { id: "millisecond", category: Category::Time, name: "Millisecond", symbol: "ms", factor_to_base: "0.001", aliases: &["milliseconds"], description: "One thousandth of a second." },
    UnitDef { id: "microsecond", category: Category::Time, name: "Microsecond", symbol: "µs", factor_to_base: "0.000001", aliases: &["microseconds"], description: "One millionth of a second." },
    UnitDef { id: "minute", category: Category::Time, name: "Minute", symbol: "min", factor_to_base: "60", aliases: &["minutes"], description: "Sixty seconds." },
    UnitDef { id: "hour", category: Category::Time, name: "Hour", symbol: "h", factor_to_base: "3600", aliases: &["hours", "hr"], description: "Sixty minutes." },
    UnitDef { id: "day", category: Category::Time, name: "Day", symbol: "d", factor_to_base: "86400", aliases: &["days"], description: "Twenty-four hours." },
    UnitDef { id: "week", category: Category::Time, name: "Week", symbol: "wk", factor_to_base: "604800", aliases: &["weeks"], description: "Seven days." },

    UnitDef { id: "square_meter", category: Category::Area, name: "Square meter", symbol: "m²", factor_to_base: "1", aliases: &["square metre", "sqm"], description: "Area of a one-meter square." },
    UnitDef { id: "square_kilometer", category: Category::Area, name: "Square kilometer", symbol: "km²", factor_to_base: "1000000", aliases: &["square kilometre", "sq km"], description: "One million square meters." },
    UnitDef { id: "square_centimeter", category: Category::Area, name: "Square centimeter", symbol: "cm²", factor_to_base: "0.0001", aliases: &["sq cm"], description: "One ten-thousandth of a square meter." },
    UnitDef { id: "square_foot", category: Category::Area, name: "Square foot", symbol: "ft²", factor_to_base: "0.09290304", aliases: &["sq ft"], description: "Area of a one-foot square." },
    UnitDef { id: "square_yard", category: Category::Area, name: "Square yard", symbol: "yd²", factor_to_base: "0.83612736", aliases: &["sq yd"], description: "Nine square feet." },
    UnitDef { id: "acre", category: Category::Area, name: "Acre", symbol: "ac", factor_to_base: "4046.8564224", aliases: &["acres"], description: "43,560 square feet." },
    UnitDef { id: "hectare", category: Category::Area, name: "Hectare", symbol: "ha", factor_to_base: "10000", aliases: &["hectares"], description: "Ten thousand square meters." },

    UnitDef { id: "liter", category: Category::Volume, name: "Liter", symbol: "L", factor_to_base: "1", aliases: &["litre", "liters", "litres"], description: "Metric unit of volume." },
    UnitDef { id: "milliliter", category: Category::Volume, name: "Milliliter", symbol: "mL", factor_to_base: "0.001", aliases: &["millilitre", "ml"], description: "One thousandth of a liter." },
    UnitDef { id: "cubic_meter", category: Category::Volume, name: "Cubic meter", symbol: "m³", factor_to_base: "1000", aliases: &["cubic metre"], description: "One thousand liters." },
    UnitDef { id: "cubic_centimeter", category: Category::Volume, name: "Cubic centimeter", symbol: "cm³", factor_to_base: "0.001", aliases: &["cc"], description: "Equivalent to one milliliter." },
    UnitDef { id: "us_teaspoon", category: Category::Volume, name: "US teaspoon", symbol: "tsp", factor_to_base: "0.00492892159375", aliases: &["teaspoon"], description: "US customary teaspoon." },
    UnitDef { id: "us_tablespoon", category: Category::Volume, name: "US tablespoon", symbol: "tbsp", factor_to_base: "0.01478676478125", aliases: &["tablespoon"], description: "US customary tablespoon." },
    UnitDef { id: "us_fluid_ounce", category: Category::Volume, name: "US fluid ounce", symbol: "fl oz", factor_to_base: "0.0295735295625", aliases: &["fluid ounce"], description: "US customary fluid ounce." },
    UnitDef { id: "us_cup", category: Category::Volume, name: "US cup", symbol: "cup", factor_to_base: "0.2365882365", aliases: &["cups"], description: "US customary cup." },
    UnitDef { id: "us_pint", category: Category::Volume, name: "US pint", symbol: "pt", factor_to_base: "0.473176473", aliases: &["pint"], description: "US customary liquid pint." },
    UnitDef { id: "us_gallon", category: Category::Volume, name: "US gallon", symbol: "gal", factor_to_base: "3.785411784", aliases: &["gallon"], description: "US customary liquid gallon." },

    UnitDef { id: "meter_per_second", category: Category::Speed, name: "Meter per second", symbol: "m/s", factor_to_base: "1", aliases: &["mps"], description: "SI derived unit of speed." },
    UnitDef { id: "kilometer_per_hour", category: Category::Speed, name: "Kilometer per hour", symbol: "km/h", factor_to_base: "0.2777777777777777777777777778", aliases: &["kph", "kmph"], description: "Kilometers traveled in one hour." },
    UnitDef { id: "mile_per_hour", category: Category::Speed, name: "Mile per hour", symbol: "mph", factor_to_base: "0.44704", aliases: &["miles per hour"], description: "Miles traveled in one hour." },
    UnitDef { id: "knot", category: Category::Speed, name: "Knot", symbol: "kn", factor_to_base: "0.5144444444444444444444444444", aliases: &["knots", "kt"], description: "One nautical mile per hour." },

    UnitDef { id: "byte", category: Category::Data, name: "Byte", symbol: "B", factor_to_base: "1", aliases: &["bytes"], description: "Eight bits." },
    UnitDef { id: "bit", category: Category::Data, name: "Bit", symbol: "bit", factor_to_base: "0.125", aliases: &["bits"], description: "One eighth of a byte." },
    UnitDef { id: "kilobyte", category: Category::Data, name: "Kilobyte", symbol: "kB", factor_to_base: "1000", aliases: &["KB"], description: "One thousand bytes." },
    UnitDef { id: "megabyte", category: Category::Data, name: "Megabyte", symbol: "MB", factor_to_base: "1000000", aliases: &["megabytes"], description: "One million bytes." },
    UnitDef { id: "gigabyte", category: Category::Data, name: "Gigabyte", symbol: "GB", factor_to_base: "1000000000", aliases: &["gigabytes"], description: "One billion bytes." },
    UnitDef { id: "terabyte", category: Category::Data, name: "Terabyte", symbol: "TB", factor_to_base: "1000000000000", aliases: &["terabytes"], description: "One trillion bytes." },
    UnitDef { id: "kibibyte", category: Category::Data, name: "Kibibyte", symbol: "KiB", factor_to_base: "1024", aliases: &["kibibytes"], description: "1,024 bytes." },
    UnitDef { id: "mebibyte", category: Category::Data, name: "Mebibyte", symbol: "MiB", factor_to_base: "1048576", aliases: &["mebibytes"], description: "1,048,576 bytes." },
    UnitDef { id: "gibibyte", category: Category::Data, name: "Gibibyte", symbol: "GiB", factor_to_base: "1073741824", aliases: &["gibibytes"], description: "1,073,741,824 bytes." },

    UnitDef { id: "pascal", category: Category::Pressure, name: "Pascal", symbol: "Pa", factor_to_base: "1", aliases: &["pascals"], description: "SI derived unit of pressure." },
    UnitDef { id: "kilopascal", category: Category::Pressure, name: "Kilopascal", symbol: "kPa", factor_to_base: "1000", aliases: &["kilopascals"], description: "One thousand pascals." },
    UnitDef { id: "bar", category: Category::Pressure, name: "Bar", symbol: "bar", factor_to_base: "100000", aliases: &["bars"], description: "One hundred kilopascals." },
    UnitDef { id: "atmosphere", category: Category::Pressure, name: "Standard atmosphere", symbol: "atm", factor_to_base: "101325", aliases: &["atmospheres"], description: "Standard atmosphere." },
    UnitDef { id: "psi", category: Category::Pressure, name: "Pound per square inch", symbol: "psi", factor_to_base: "6894.757293168", aliases: &["pounds per square inch"], description: "Pressure in pounds-force per square inch." },

    UnitDef { id: "joule", category: Category::Energy, name: "Joule", symbol: "J", factor_to_base: "1", aliases: &["joules"], description: "SI derived unit of energy." },
    UnitDef { id: "kilojoule", category: Category::Energy, name: "Kilojoule", symbol: "kJ", factor_to_base: "1000", aliases: &["kilojoules"], description: "One thousand joules." },
    UnitDef { id: "calorie", category: Category::Energy, name: "Calorie", symbol: "cal", factor_to_base: "4.184", aliases: &["calories"], description: "Thermochemical calorie." },
    UnitDef { id: "kilocalorie", category: Category::Energy, name: "Kilocalorie", symbol: "kcal", factor_to_base: "4184", aliases: &["food calorie"], description: "One thousand thermochemical calories." },
    UnitDef { id: "watt_hour", category: Category::Energy, name: "Watt-hour", symbol: "Wh", factor_to_base: "3600", aliases: &["watt hour"], description: "Energy from one watt over one hour." },
    UnitDef { id: "kilowatt_hour", category: Category::Energy, name: "Kilowatt-hour", symbol: "kWh", factor_to_base: "3600000", aliases: &["kilowatt hour"], description: "Energy from one kilowatt over one hour." },

    UnitDef { id: "watt", category: Category::Power, name: "Watt", symbol: "W", factor_to_base: "1", aliases: &["watts"], description: "SI derived unit of power." },
    UnitDef { id: "kilowatt", category: Category::Power, name: "Kilowatt", symbol: "kW", factor_to_base: "1000", aliases: &["kilowatts"], description: "One thousand watts." },
    UnitDef { id: "megawatt", category: Category::Power, name: "Megawatt", symbol: "MW", factor_to_base: "1000000", aliases: &["megawatts"], description: "One million watts." },
    UnitDef { id: "horsepower", category: Category::Power, name: "Mechanical horsepower", symbol: "hp", factor_to_base: "745.69987158227022", aliases: &["horse power"], description: "Mechanical horsepower." },

    UnitDef { id: "radian", category: Category::Angle, name: "Radian", symbol: "rad", factor_to_base: "1", aliases: &["radians"], description: "SI derived unit of plane angle." },
    UnitDef { id: "degree", category: Category::Angle, name: "Degree", symbol: "°", factor_to_base: "0.0174532925199432957692369077", aliases: &["degrees", "deg"], description: "One 360th of a full turn." },
    UnitDef { id: "gradian", category: Category::Angle, name: "Gradian", symbol: "gon", factor_to_base: "0.0157079632679489661923132169", aliases: &["gradians", "grad"], description: "One 400th of a full turn." },
    UnitDef { id: "turn", category: Category::Angle, name: "Turn", symbol: "turn", factor_to_base: "6.2831853071795864769252867666", aliases: &["revolution", "rev"], description: "One full revolution." },
];

#[must_use]
pub fn find_unit(query: &str) -> Option<&'static UnitDef> {
    let needle = query.trim();
    UNITS.iter().find(|unit| {
        unit.id.eq_ignore_ascii_case(needle)
            || unit.name.eq_ignore_ascii_case(needle)
            || unit.symbol.eq_ignore_ascii_case(needle)
            || unit.aliases.iter().any(|alias| alias.eq_ignore_ascii_case(needle))
    })
}

#[must_use]
pub fn units_for_category(category: Category) -> Vec<&'static UnitDef> {
    UNITS.iter().filter(|unit| unit.category == category).collect()
}

#[must_use]
pub fn search_units(query: &str) -> Vec<&'static UnitDef> {
    let needle = query.trim().to_ascii_lowercase();
    if needle.is_empty() {
        return UNITS.iter().collect();
    }

    UNITS.iter()
        .filter(|unit| {
            unit.id.to_ascii_lowercase().contains(&needle)
                || unit.name.to_ascii_lowercase().contains(&needle)
                || unit.symbol.to_ascii_lowercase().contains(&needle)
                || unit.description.to_ascii_lowercase().contains(&needle)
                || unit.aliases.iter().any(|alias| alias.to_ascii_lowercase().contains(&needle))
        })
        .collect()
}
