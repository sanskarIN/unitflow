use std::collections::HashMap;
use std::str::FromStr;

use rust_decimal::Decimal;

use crate::error::UnitFlowError;
use crate::model::{Category, UnitDefinition};

/// In-memory catalog with stable unit identifiers and fast direct lookup.
#[derive(Debug, Clone)]
pub struct UnitCatalog {
    units: Vec<UnitDefinition>,
    by_id: HashMap<String, usize>,
}

impl UnitCatalog {
    pub fn new(units: Vec<UnitDefinition>) -> Result<Self, UnitFlowError> {
        let mut by_id = HashMap::with_capacity(units.len());
        for (index, unit) in units.iter().enumerate() {
            if by_id.insert(unit.id.clone(), index).is_some() {
                return Err(UnitFlowError::DuplicateUnitId(unit.id.clone()));
            }
        }
        Ok(Self { units, by_id })
    }

    /// Builds the versioned static catalog shipped with UnitFlow.
    ///
    /// The catalog intentionally keeps one dense row per built-in unit so factors, aliases, and
    /// descriptions remain easy to audit side-by-side. Skip rustfmt for this data table only;
    /// executable logic in the rest of the module remains normally formatted.
    #[rustfmt::skip]
    pub fn built_in() -> Result<Self, UnitFlowError> {
        let units = vec![
            // Length — base meter.
            u("meter", Category::Length, "Meter", "m", &["metre", "meters", "metres"], "SI base unit of length.", "1", "0")?,
            u("kilometer", Category::Length, "Kilometer", "km", &["kilometre", "kilometers", "kilometres"], "One thousand meters.", "1000", "0")?,
            u("centimeter", Category::Length, "Centimeter", "cm", &["centimetre", "centimeters"], "One hundredth of a meter.", "0.01", "0")?,
            u("millimeter", Category::Length, "Millimeter", "mm", &["millimetre", "millimeters"], "One thousandth of a meter.", "0.001", "0")?,
            u("micrometer", Category::Length, "Micrometer", "µm", &["micrometre", "um", "micron"], "One millionth of a meter.", "0.000001", "0")?,
            u("nanometer", Category::Length, "Nanometer", "nm", &["nanometre"], "One billionth of a meter.", "0.000000001", "0")?,
            u("inch", Category::Length, "Inch", "in", &["inches"], "International inch, exactly 0.0254 meter.", "0.0254", "0")?,
            u("foot", Category::Length, "Foot", "ft", &["feet"], "International foot, exactly 0.3048 meter.", "0.3048", "0")?,
            u("yard", Category::Length, "Yard", "yd", &["yards"], "International yard, exactly 0.9144 meter.", "0.9144", "0")?,
            u("mile", Category::Length, "Mile", "mi", &["miles", "statute mile"], "International mile, exactly 1609.344 meters.", "1609.344", "0")?,
            u("nautical_mile", Category::Length, "Nautical Mile", "nmi", &["nautical miles"], "International nautical mile, exactly 1852 meters.", "1852", "0")?,

            // Area — base square meter.
            u("square_meter", Category::Area, "Square Meter", "m²", &["m2", "square metre"], "Area of a one-meter by one-meter square.", "1", "0")?,
            u("square_kilometer", Category::Area, "Square Kilometer", "km²", &["km2", "square kilometre"], "One million square meters.", "1000000", "0")?,
            u("square_centimeter", Category::Area, "Square Centimeter", "cm²", &["cm2", "square centimetre"], "One ten-thousandth of a square meter.", "0.0001", "0")?,
            u("square_millimeter", Category::Area, "Square Millimeter", "mm²", &["mm2", "square millimetre"], "One millionth of a square meter.", "0.000001", "0")?,
            u("hectare", Category::Area, "Hectare", "ha", &["hectares"], "Exactly 10,000 square meters.", "10000", "0")?,
            u("acre", Category::Area, "Acre", "ac", &["acres"], "International acre.", "4046.8564224", "0")?,
            u("square_foot", Category::Area, "Square Foot", "ft²", &["ft2", "square feet"], "Area of a one-foot square.", "0.09290304", "0")?,
            u("square_inch", Category::Area, "Square Inch", "in²", &["in2", "square inches"], "Area of a one-inch square.", "0.00064516", "0")?,
            u("square_mile", Category::Area, "Square Mile", "mi²", &["mi2", "square miles"], "Area of a one-mile square.", "2589988.110336", "0")?,

            // Volume — base liter.
            u("liter", Category::Volume, "Liter", "L", &["litre", "liters", "litres"], "Metric unit of volume used as UnitFlow's volume base.", "1", "0")?,
            u("milliliter", Category::Volume, "Milliliter", "mL", &["millilitre", "ml"], "One thousandth of a liter.", "0.001", "0")?,
            u("cubic_meter", Category::Volume, "Cubic Meter", "m³", &["m3", "cubic metre"], "Exactly one thousand liters.", "1000", "0")?,
            u("cubic_centimeter", Category::Volume, "Cubic Centimeter", "cm³", &["cm3", "cc"], "Exactly one milliliter.", "0.001", "0")?,
            u("teaspoon_us", Category::Volume, "US Teaspoon", "tsp", &["teaspoon"], "US customary teaspoon.", "0.00492892159375", "0")?,
            u("tablespoon_us", Category::Volume, "US Tablespoon", "tbsp", &["tablespoon"], "US customary tablespoon.", "0.01478676478125", "0")?,
            u("fluid_ounce_us", Category::Volume, "US Fluid Ounce", "fl oz", &["fluid ounce"], "US customary fluid ounce.", "0.0295735295625", "0")?,
            u("cup_us", Category::Volume, "US Cup", "cup", &["cups"], "US customary cup.", "0.2365882365", "0")?,
            u("pint_us", Category::Volume, "US Pint", "pt", &["pints"], "US liquid pint.", "0.473176473", "0")?,
            u("quart_us", Category::Volume, "US Quart", "qt", &["quarts"], "US liquid quart.", "0.946352946", "0")?,
            u("gallon_us", Category::Volume, "US Gallon", "gal", &["us gallon", "gallons"], "US liquid gallon.", "3.785411784", "0")?,
            u("gallon_imperial", Category::Volume, "Imperial Gallon", "imp gal", &["uk gallon", "imperial gallons"], "Imperial gallon.", "4.54609", "0")?,

            // Mass — base kilogram.
            u("kilogram", Category::Mass, "Kilogram", "kg", &["kilograms", "kilo"], "SI base unit of mass.", "1", "0")?,
            u("gram", Category::Mass, "Gram", "g", &["grams"], "One thousandth of a kilogram.", "0.001", "0")?,
            u("milligram", Category::Mass, "Milligram", "mg", &["milligrams"], "One millionth of a kilogram.", "0.000001", "0")?,
            u("microgram", Category::Mass, "Microgram", "µg", &["ug", "micrograms"], "One billionth of a kilogram.", "0.000000001", "0")?,
            u("metric_tonne", Category::Mass, "Metric Tonne", "t", &["tonne", "metric ton"], "Exactly one thousand kilograms.", "1000", "0")?,
            u("pound", Category::Mass, "Pound", "lb", &["pounds", "lbs"], "International avoirdupois pound.", "0.45359237", "0")?,
            u("ounce", Category::Mass, "Ounce", "oz", &["ounces"], "International avoirdupois ounce.", "0.028349523125", "0")?,
            u("stone", Category::Mass, "Stone", "st", &["stones"], "Exactly fourteen international pounds.", "6.35029318", "0")?,

            // Speed — base meter per second.
            u("meter_per_second", Category::Speed, "Meter per Second", "m/s", &["meters per second", "metres per second", "mps"], "SI coherent speed unit.", "1", "0")?,
            u("kilometer_per_hour", Category::Speed, "Kilometer per Hour", "km/h", &["kilometre per hour", "kph", "kmph"], "Metric road-speed unit.", "0.2777777777777777777777777778", "0")?,
            u("mile_per_hour", Category::Speed, "Mile per Hour", "mph", &["miles per hour"], "International miles per hour.", "0.44704", "0")?,
            u("foot_per_second", Category::Speed, "Foot per Second", "ft/s", &["feet per second", "fps"], "International feet per second.", "0.3048", "0")?,
            u("knot", Category::Speed, "Knot", "kn", &["knots", "nautical mile per hour"], "One nautical mile per hour.", "0.5144444444444444444444444444", "0")?,

            // Pressure — base pascal.
            u("pascal", Category::Pressure, "Pascal", "Pa", &["pascals"], "SI pressure unit, one newton per square meter.", "1", "0")?,
            u("kilopascal", Category::Pressure, "Kilopascal", "kPa", &["kilopascals"], "One thousand pascals.", "1000", "0")?,
            u("megapascal", Category::Pressure, "Megapascal", "MPa", &["megapascals"], "One million pascals.", "1000000", "0")?,
            u("bar", Category::Pressure, "Bar", "bar", &["bars"], "Exactly 100,000 pascals.", "100000", "0")?,
            u("millibar", Category::Pressure, "Millibar", "mbar", &["millibars", "hectopascal"], "Exactly 100 pascals.", "100", "0")?,
            u("standard_atmosphere", Category::Pressure, "Standard Atmosphere", "atm", &["atmosphere"], "Standard atmosphere, exactly 101325 pascals.", "101325", "0")?,
            u("psi", Category::Pressure, "Pound per Square Inch", "psi", &["pounds per square inch"], "Pressure from one pound-force per square inch.", "6894.757293168361", "0")?,
            u("torr", Category::Pressure, "Torr", "Torr", &["mmhg", "millimeter mercury"], "Approximately one 760th of a standard atmosphere.", "133.3223684210526315789473684", "0")?,

            // Energy — base joule.
            u("joule", Category::Energy, "Joule", "J", &["joules"], "SI energy unit.", "1", "0")?,
            u("kilojoule", Category::Energy, "Kilojoule", "kJ", &["kilojoules"], "One thousand joules.", "1000", "0")?,
            u("calorie", Category::Energy, "Calorie", "cal", &["thermochemical calorie"], "Thermochemical calorie, exactly 4.184 joules.", "4.184", "0")?,
            u("kilocalorie", Category::Energy, "Kilocalorie", "kcal", &["food calorie", "calorie food"], "Thermochemical kilocalorie.", "4184", "0")?,
            u("watt_hour", Category::Energy, "Watt-hour", "Wh", &["watt hour"], "Exactly 3600 joules.", "3600", "0")?,
            u("kilowatt_hour", Category::Energy, "Kilowatt-hour", "kWh", &["kilowatt hour"], "Exactly 3.6 megajoules.", "3600000", "0")?,
            u("btu_it", Category::Energy, "British Thermal Unit (IT)", "BTU", &["btu"], "International Table British thermal unit.", "1055.05585262", "0")?,
            u("electronvolt", Category::Energy, "Electronvolt", "eV", &["electron volt"], "Energy acquired by one elementary charge through one volt.", "0.0000000000000000001602176634", "0")?,

            // Power — base watt.
            u("watt", Category::Power, "Watt", "W", &["watts"], "SI power unit, one joule per second.", "1", "0")?,
            u("kilowatt", Category::Power, "Kilowatt", "kW", &["kilowatts"], "One thousand watts.", "1000", "0")?,
            u("megawatt", Category::Power, "Megawatt", "MW", &["megawatts"], "One million watts.", "1000000", "0")?,
            u("gigawatt", Category::Power, "Gigawatt", "GW", &["gigawatts"], "One billion watts.", "1000000000", "0")?,
            u("horsepower_mechanical", Category::Power, "Mechanical Horsepower", "hp", &["horsepower", "imperial horsepower"], "Mechanical horsepower.", "745.69987158227022", "0")?,
            u("horsepower_metric", Category::Power, "Metric Horsepower", "PS", &["metric hp"], "Metric horsepower.", "735.49875", "0")?,

            // Angle — base radian.
            u("radian", Category::Angle, "Radian", "rad", &["radians"], "SI coherent unit for plane angle.", "1", "0")?,
            u("degree", Category::Angle, "Degree", "°", &["degrees", "deg"], "One 360th of a full turn.", "0.0174532925199432957692369077", "0")?,
            u("gradian", Category::Angle, "Gradian", "gon", &["grad", "gradians"], "One 400th of a full turn.", "0.0157079632679489661923132169", "0")?,
            u("turn", Category::Angle, "Turn", "turn", &["revolution", "cycle"], "One complete rotation.", "6.2831853071795864769252867666", "0")?,
            u("arcminute", Category::Angle, "Arcminute", "′", &["minute of arc", "arcmin"], "One sixtieth of a degree.", "0.0002908882086657215961539485", "0")?,
            u("arcsecond", Category::Angle, "Arcsecond", "″", &["second of arc", "arcsec"], "One sixtieth of an arcminute.", "0.0000048481368110953599358991", "0")?,

            // Data size — base byte.
            u("byte", Category::DataSize, "Byte", "B", &["bytes", "octet"], "Eight bits.", "1", "0")?,
            u("bit", Category::DataSize, "Bit", "bit", &["bits", "b"], "One eighth of a byte.", "0.125", "0")?,
            u("kilobyte", Category::DataSize, "Kilobyte", "kB", &["kb decimal"], "Decimal kilobyte, 1000 bytes.", "1000", "0")?,
            u("megabyte", Category::DataSize, "Megabyte", "MB", &["mb decimal"], "Decimal megabyte, 1,000,000 bytes.", "1000000", "0")?,
            u("gigabyte", Category::DataSize, "Gigabyte", "GB", &["gb decimal"], "Decimal gigabyte, 1,000,000,000 bytes.", "1000000000", "0")?,
            u("terabyte", Category::DataSize, "Terabyte", "TB", &["tb decimal"], "Decimal terabyte, 1,000,000,000,000 bytes.", "1000000000000", "0")?,
            u("kibibyte", Category::DataSize, "Kibibyte", "KiB", &["kib"], "Binary data unit, 1024 bytes.", "1024", "0")?,
            u("mebibyte", Category::DataSize, "Mebibyte", "MiB", &["mib"], "Binary data unit, 1,048,576 bytes.", "1048576", "0")?,
            u("gibibyte", Category::DataSize, "Gibibyte", "GiB", &["gib"], "Binary data unit, 1,073,741,824 bytes.", "1073741824", "0")?,
            u("tebibyte", Category::DataSize, "Tebibyte", "TiB", &["tib"], "Binary data unit, 1,099,511,627,776 bytes.", "1099511627776", "0")?,

            // Frequency — base hertz.
            u("hertz", Category::Frequency, "Hertz", "Hz", &["hz", "cycles per second"], "SI unit of frequency.", "1", "0")?,
            u("kilohertz", Category::Frequency, "Kilohertz", "kHz", &["khz"], "One thousand hertz.", "1000", "0")?,
            u("megahertz", Category::Frequency, "Megahertz", "MHz", &["mhz"], "One million hertz.", "1000000", "0")?,
            u("gigahertz", Category::Frequency, "Gigahertz", "GHz", &["ghz"], "One billion hertz.", "1000000000", "0")?,
            u("revolution_per_minute", Category::Frequency, "Revolution per Minute", "rpm", &["revolutions per minute"], "One revolution per minute.", "0.0166666666666666666666666667", "0")?,

            // Time — base second.
            u("second", Category::Time, "Second", "s", &["seconds", "sec"], "SI base unit of time.", "1", "0")?,
            u("millisecond", Category::Time, "Millisecond", "ms", &["milliseconds"], "One thousandth of a second.", "0.001", "0")?,
            u("microsecond", Category::Time, "Microsecond", "µs", &["us", "microseconds"], "One millionth of a second.", "0.000001", "0")?,
            u("nanosecond", Category::Time, "Nanosecond", "ns", &["nanoseconds"], "One billionth of a second.", "0.000000001", "0")?,
            u("minute", Category::Time, "Minute", "min", &["minutes"], "Exactly sixty seconds.", "60", "0")?,
            u("hour", Category::Time, "Hour", "h", &["hours", "hr"], "Exactly 3600 seconds.", "3600", "0")?,
            u("day", Category::Time, "Day", "d", &["days"], "Exactly 86,400 seconds.", "86400", "0")?,
            u("week", Category::Time, "Week", "wk", &["weeks"], "Exactly seven days.", "604800", "0")?,
            u("julian_year", Category::Time, "Julian Year", "a", &["year 365.25 days"], "Exactly 365.25 days.", "31557600", "0")?,

            // Temperature — base kelvin. base = input * scale + offset.
            u("kelvin", Category::Temperature, "Kelvin", "K", &["kelvins"], "SI base unit of thermodynamic temperature.", "1", "0")?,
            u("celsius", Category::Temperature, "Celsius", "°C", &["centigrade", "degrees celsius"], "Celsius temperature scale.", "1", "273.15")?,
            u("fahrenheit", Category::Temperature, "Fahrenheit", "°F", &["degrees fahrenheit"], "Fahrenheit temperature scale.", "0.5555555555555555555555555556", "255.3722222222222222222222222")?,
            u("rankine", Category::Temperature, "Rankine", "°R", &["degrees rankine"], "Absolute temperature scale using Fahrenheit-sized degrees.", "0.5555555555555555555555555556", "0")?,
        ];

        Self::new(units)
    }

    #[must_use]
    pub fn all(&self) -> &[UnitDefinition] {
        &self.units
    }

    #[must_use]
    pub fn len(&self) -> usize {
        self.units.len()
    }

    #[must_use]
    pub fn is_empty(&self) -> bool {
        self.units.is_empty()
    }

    #[must_use]
    pub fn get(&self, id: &str) -> Option<&UnitDefinition> {
        self.by_id.get(id).map(|index| &self.units[*index])
    }

    #[must_use]
    pub fn units_for_category(&self, category: Category) -> Vec<&UnitDefinition> {
        self.units
            .iter()
            .filter(|unit| unit.category == category)
            .collect()
    }

    /// Searches names, IDs, symbols, and aliases. Exact matches sort before prefixes,
    /// which sort before substring matches.
    #[must_use]
    pub fn search(
        &self,
        query: &str,
        category: Option<Category>,
        limit: usize,
    ) -> Vec<&UnitDefinition> {
        if limit == 0 {
            return Vec::new();
        }

        let normalized = query.trim().to_lowercase();
        let mut matches: Vec<(u8, &UnitDefinition)> = self
            .units
            .iter()
            .filter(|unit| category.is_none_or(|value| unit.category == value))
            .filter_map(|unit| score(unit, &normalized).map(|value| (value, unit)))
            .collect();

        matches.sort_by(|(left_score, left), (right_score, right)| {
            left_score
                .cmp(right_score)
                .then_with(|| left.name.cmp(&right.name))
        });
        matches.truncate(limit);
        matches.into_iter().map(|(_, unit)| unit).collect()
    }
}

fn score(unit: &UnitDefinition, query: &str) -> Option<u8> {
    if query.is_empty() {
        return Some(3);
    }

    let fields = std::iter::once(unit.id.as_str())
        .chain(std::iter::once(unit.name.as_str()))
        .chain(std::iter::once(unit.symbol.as_str()))
        .chain(unit.aliases.iter().map(String::as_str));

    let mut best: Option<u8> = None;
    for field in fields {
        let field = field.to_lowercase();
        let candidate = if field == query {
            Some(0)
        } else if field.starts_with(query) {
            Some(1)
        } else if field.contains(query) {
            Some(2)
        } else {
            None
        };

        if let Some(candidate) = candidate {
            best = Some(best.map_or(candidate, |current| current.min(candidate)));
        }
    }
    best
}

#[allow(clippy::too_many_arguments)]
fn u(
    id: &str,
    category: Category,
    name: &str,
    symbol: &str,
    aliases: &[&str],
    description: &str,
    scale: &str,
    offset: &str,
) -> Result<UnitDefinition, UnitFlowError> {
    UnitDefinition::new(
        id,
        category,
        name,
        symbol,
        aliases.iter().map(|value| (*value).to_owned()).collect(),
        description,
        d(scale)?,
        d(offset)?,
        true,
    )
}

fn d(value: &str) -> Result<Decimal, UnitFlowError> {
    Decimal::from_str(value).map_err(|_| UnitFlowError::InvalidDecimalConstant(value.to_owned()))
}
