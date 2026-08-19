use std::str::FromStr;

use rust_decimal::{Decimal, RoundingStrategy};

use crate::{catalog::find_unit, ConversionError};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum RoundingMode {
    HalfEven,
    HalfAwayFromZero,
    TowardZero,
    AwayFromZero,
    Floor,
    Ceiling,
}

impl RoundingMode {
    const fn strategy(self) -> RoundingStrategy {
        match self {
            Self::HalfEven => RoundingStrategy::MidpointNearestEven,
            Self::HalfAwayFromZero => RoundingStrategy::MidpointAwayFromZero,
            Self::TowardZero => RoundingStrategy::ToZero,
            Self::AwayFromZero => RoundingStrategy::AwayFromZero,
            Self::Floor => RoundingStrategy::ToNegativeInfinity,
            Self::Ceiling => RoundingStrategy::ToPositiveInfinity,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ConversionResult {
    pub value: Decimal,
    pub from_id: &'static str,
    pub to_id: &'static str,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct ConversionOptions {
    pub decimal_places: u32,
    pub rounding: RoundingMode,
}

impl Default for ConversionOptions {
    fn default() -> Self {
        Self {
            decimal_places: 12,
            rounding: RoundingMode::HalfEven,
        }
    }
}

pub fn convert(
    value: Decimal,
    from: &str,
    to: &str,
    options: ConversionOptions,
) -> Result<ConversionResult, ConversionError> {
    if options.decimal_places > 28 {
        return Err(ConversionError::InvalidPrecision(options.decimal_places));
    }

    let from_unit = find_unit(from).ok_or_else(|| ConversionError::UnknownUnit(from.to_owned()))?;
    let to_unit = find_unit(to).ok_or_else(|| ConversionError::UnknownUnit(to.to_owned()))?;

    if from_unit.category != to_unit.category {
        return Err(ConversionError::CategoryMismatch {
            from: from_unit.category.label().to_owned(),
            to: to_unit.category.label().to_owned(),
        });
    }

    let raw = if from_unit.category == crate::catalog::Category::Temperature {
        convert_temperature(value, from_unit.id, to_unit.id)?
    } else {
        let from_factor = parse_factor(from_unit.factor_to_base)?;
        let to_factor = parse_factor(to_unit.factor_to_base)?;
        let base = value
            .checked_mul(from_factor)
            .ok_or_else(|| ConversionError::Arithmetic("overflow converting to base unit".into()))?;
        base.checked_div(to_factor)
            .ok_or_else(|| ConversionError::Arithmetic("division failed converting from base unit".into()))?
    };

    Ok(ConversionResult {
        value: raw.round_dp_with_strategy(options.decimal_places, options.rounding.strategy()),
        from_id: from_unit.id,
        to_id: to_unit.id,
    })
}

pub fn convert_str(
    value: &str,
    from: &str,
    to: &str,
    options: ConversionOptions,
) -> Result<ConversionResult, ConversionError> {
    let decimal = Decimal::from_str(value.trim())
        .map_err(|_| ConversionError::InvalidNumber(value.to_owned()))?;
    convert(decimal, from, to, options)
}

fn parse_factor(value: &str) -> Result<Decimal, ConversionError> {
    Decimal::from_str(value)
        .map_err(|_| ConversionError::Arithmetic(format!("invalid catalog factor: {value}")))
}

fn convert_temperature(value: Decimal, from: &str, to: &str) -> Result<Decimal, ConversionError> {
    if from == to {
        return Ok(value);
    }

    let kelvin = match from {
        "kelvin" => value,
        "celsius" => value
            .checked_add(Decimal::new(27_315, 2))
            .ok_or_else(|| ConversionError::Arithmetic("temperature overflow".into()))?,
        "fahrenheit" => {
            let shifted = value
                .checked_add(Decimal::new(45_967, 2))
                .ok_or_else(|| ConversionError::Arithmetic("temperature overflow".into()))?;
            shifted
                .checked_mul(Decimal::from(5u32))
                .and_then(|v| v.checked_div(Decimal::from(9u32)))
                .ok_or_else(|| ConversionError::Arithmetic("temperature conversion failed".into()))?
        }
        _ => return Err(ConversionError::UnknownUnit(from.to_owned())),
    };

    match to {
        "kelvin" => Ok(kelvin),
        "celsius" => kelvin
            .checked_sub(Decimal::new(27_315, 2))
            .ok_or_else(|| ConversionError::Arithmetic("temperature overflow".into())),
        "fahrenheit" => {
            let scaled = kelvin
                .checked_mul(Decimal::from(9u32))
                .and_then(|v| v.checked_div(Decimal::from(5u32)))
                .ok_or_else(|| ConversionError::Arithmetic("temperature conversion failed".into()))?;
            scaled
                .checked_sub(Decimal::new(45_967, 2))
                .ok_or_else(|| ConversionError::Arithmetic("temperature overflow".into()))
        }
        _ => Err(ConversionError::UnknownUnit(to.to_owned())),
    }
}
