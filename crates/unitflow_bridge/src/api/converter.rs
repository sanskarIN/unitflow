use std::str::FromStr;

use rust_decimal::Decimal;
use unitflow_core::{
    ConversionRequest, Converter, Notation, RoundMode, UnitCatalog, UnitDefinition,
};

#[derive(Debug, Clone)]
pub struct BridgeUnit {
    pub id: String,
    pub category: String,
    pub name: String,
    pub symbol: String,
    pub aliases: Vec<String>,
    pub description: String,
    pub scale: String,
    pub offset: String,
    pub is_builtin: bool,
}

#[derive(Debug, Clone)]
pub struct BridgeConversionResult {
    pub input: String,
    pub output: String,
    pub from_unit_id: String,
    pub to_unit_id: String,
    pub category: String,
}

#[derive(Debug, Clone, Copy)]
pub enum BridgeRoundMode {
    NearestEven,
    HalfAwayFromZero,
    TowardZero,
    AwayFromZero,
    Floor,
    Ceiling,
}

#[derive(Debug, Clone, Copy)]
pub enum BridgeNotation {
    Plain,
    Scientific,
    Engineering,
}

impl From<BridgeRoundMode> for RoundMode {
    fn from(value: BridgeRoundMode) -> Self {
        match value {
            BridgeRoundMode::NearestEven => Self::NearestEven,
            BridgeRoundMode::HalfAwayFromZero => Self::HalfAwayFromZero,
            BridgeRoundMode::TowardZero => Self::TowardZero,
            BridgeRoundMode::AwayFromZero => Self::AwayFromZero,
            BridgeRoundMode::Floor => Self::Floor,
            BridgeRoundMode::Ceiling => Self::Ceiling,
        }
    }
}

impl From<BridgeNotation> for Notation {
    fn from(value: BridgeNotation) -> Self {
        match value {
            BridgeNotation::Plain => Self::Plain,
            BridgeNotation::Scientific => Self::Scientific,
            BridgeNotation::Engineering => Self::Engineering,
        }
    }
}

#[flutter_rust_bridge::frb(sync)]
pub fn bridge_version() -> String {
    unitflow_core::VERSION.to_owned()
}

#[flutter_rust_bridge::frb(sync)]
pub fn list_units() -> Result<Vec<BridgeUnit>, String> {
    let catalog = UnitCatalog::built_in().map_err(|error| error.to_string())?;
    Ok(catalog.all().iter().map(BridgeUnit::from).collect())
}

#[flutter_rust_bridge::frb(sync)]
pub fn search_units(
    query: String,
    category: Option<String>,
    limit: u32,
) -> Result<Vec<BridgeUnit>, String> {
    let catalog = UnitCatalog::built_in().map_err(|error| error.to_string())?;
    let category = match category {
        Some(value) => Some(parse_category(&value)?),
        None => None,
    };
    Ok(catalog
        .search(&query, category, usize::try_from(limit).unwrap_or(usize::MAX))
        .into_iter()
        .map(BridgeUnit::from)
        .collect())
}

#[flutter_rust_bridge::frb(sync)]
pub fn convert_value(
    input: String,
    from_unit_id: String,
    to_unit_id: String,
    decimal_places: Option<u32>,
    round_mode: BridgeRoundMode,
) -> Result<BridgeConversionResult, String> {
    let value = Decimal::from_str(input.trim()).map_err(|_| "invalid decimal input".to_owned())?;
    let converter = Converter::with_built_in_catalog().map_err(|error| error.to_string())?;
    let result = converter
        .convert(&ConversionRequest {
            value,
            from_unit_id,
            to_unit_id,
            decimal_places,
            round_mode: round_mode.into(),
        })
        .map_err(|error| error.to_string())?;

    Ok(BridgeConversionResult {
        input: result.input.normalize().to_string(),
        output: result.output.normalize().to_string(),
        from_unit_id: result.from_unit_id,
        to_unit_id: result.to_unit_id,
        category: result.category.to_string(),
    })
}

#[flutter_rust_bridge::frb(sync)]
pub fn format_value(
    input: String,
    notation: BridgeNotation,
    decimal_places: Option<u32>,
    round_mode: BridgeRoundMode,
) -> Result<String, String> {
    let value = Decimal::from_str(input.trim()).map_err(|_| "invalid decimal input".to_owned())?;
    unitflow_core::format_decimal(value, notation.into(), decimal_places, round_mode.into())
        .map_err(|error| error.to_string())
}

fn parse_category(value: &str) -> Result<unitflow_core::Category, String> {
    match value.trim().to_ascii_lowercase().replace([' ', '-'], "_").as_str() {
        "length" => Ok(unitflow_core::Category::Length),
        "area" => Ok(unitflow_core::Category::Area),
        "volume" => Ok(unitflow_core::Category::Volume),
        "mass" => Ok(unitflow_core::Category::Mass),
        "speed" => Ok(unitflow_core::Category::Speed),
        "pressure" => Ok(unitflow_core::Category::Pressure),
        "energy" => Ok(unitflow_core::Category::Energy),
        "power" => Ok(unitflow_core::Category::Power),
        "angle" => Ok(unitflow_core::Category::Angle),
        "data_size" => Ok(unitflow_core::Category::DataSize),
        "frequency" => Ok(unitflow_core::Category::Frequency),
        "time" => Ok(unitflow_core::Category::Time),
        "temperature" => Ok(unitflow_core::Category::Temperature),
        _ => Err(format!("unknown category `{value}`")),
    }
}

impl From<&UnitDefinition> for BridgeUnit {
    fn from(unit: &UnitDefinition) -> Self {
        Self {
            id: unit.id.clone(),
            category: unit.category.to_string(),
            name: unit.name.clone(),
            symbol: unit.symbol.clone(),
            aliases: unit.aliases.clone(),
            description: unit.description.clone(),
            scale: unit.scale.normalize().to_string(),
            offset: unit.offset.normalize().to_string(),
            is_builtin: unit.is_builtin,
        }
    }
}
