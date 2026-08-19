use rust_decimal::{Decimal, RoundingStrategy};
use serde::{Deserialize, Serialize};

use crate::converter::RoundMode;
use crate::error::UnitFlowError;

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
#[serde(rename_all = "snake_case")]
pub enum Notation {
    #[default]
    Plain,
    Scientific,
    Engineering,
}

/// Formats a decimal without converting through binary floating point.
pub fn format_decimal(
    value: Decimal,
    notation: Notation,
    decimal_places: Option<u32>,
    round_mode: RoundMode,
) -> Result<String, UnitFlowError> {
    if decimal_places.is_some_and(|places| places > 28) {
        return Err(UnitFlowError::InvalidPrecision(decimal_places.unwrap_or(29)));
    }

    match notation {
        Notation::Plain => Ok(format_mantissa(value, decimal_places, round_mode)),
        Notation::Scientific => format_scientific(value, decimal_places, round_mode),
        Notation::Engineering => format_engineering(value, decimal_places, round_mode),
    }
}

fn format_scientific(
    value: Decimal,
    decimal_places: Option<u32>,
    round_mode: RoundMode,
) -> Result<String, UnitFlowError> {
    if value.is_zero() {
        return Ok("0".to_owned());
    }

    let ten = Decimal::TEN;
    let one = Decimal::ONE;
    let mut mantissa = value;
    let mut exponent = 0_i32;

    while mantissa.abs() >= ten {
        mantissa = mantissa
            .checked_div(ten)
            .ok_or(UnitFlowError::ArithmeticOverflow)?;
        exponent += 1;
    }
    while mantissa.abs() < one {
        mantissa = mantissa
            .checked_mul(ten)
            .ok_or(UnitFlowError::ArithmeticOverflow)?;
        exponent -= 1;
    }

    if let Some(places) = decimal_places {
        mantissa = mantissa.round_dp_with_strategy(places, strategy(round_mode));
        if mantissa.abs() >= ten {
            mantissa = mantissa
                .checked_div(ten)
                .ok_or(UnitFlowError::ArithmeticOverflow)?;
            exponent += 1;
        }
    }

    Ok(format!("{}e{:+}", canonical(mantissa), exponent))
}

fn format_engineering(
    value: Decimal,
    decimal_places: Option<u32>,
    round_mode: RoundMode,
) -> Result<String, UnitFlowError> {
    if value.is_zero() {
        return Ok("0".to_owned());
    }

    let thousand = Decimal::from(1000_u32);
    let one = Decimal::ONE;
    let mut mantissa = value;
    let mut exponent = 0_i32;

    while mantissa.abs() >= thousand {
        mantissa = mantissa
            .checked_div(thousand)
            .ok_or(UnitFlowError::ArithmeticOverflow)?;
        exponent += 3;
    }
    while mantissa.abs() < one {
        mantissa = mantissa
            .checked_mul(thousand)
            .ok_or(UnitFlowError::ArithmeticOverflow)?;
        exponent -= 3;
    }

    if let Some(places) = decimal_places {
        mantissa = mantissa.round_dp_with_strategy(places, strategy(round_mode));
        if mantissa.abs() >= thousand {
            mantissa = mantissa
                .checked_div(thousand)
                .ok_or(UnitFlowError::ArithmeticOverflow)?;
            exponent += 3;
        }
    }

    Ok(format!("{}e{:+}", canonical(mantissa), exponent))
}

fn format_mantissa(value: Decimal, decimal_places: Option<u32>, round_mode: RoundMode) -> String {
    let value = decimal_places.map_or(value, |places| {
        value.round_dp_with_strategy(places, strategy(round_mode))
    });
    canonical(value)
}

fn canonical(value: Decimal) -> String {
    value.normalize().to_string()
}

const fn strategy(mode: RoundMode) -> RoundingStrategy {
    match mode {
        RoundMode::NearestEven => RoundingStrategy::MidpointNearestEven,
        RoundMode::HalfAwayFromZero => RoundingStrategy::MidpointAwayFromZero,
        RoundMode::TowardZero => RoundingStrategy::ToZero,
        RoundMode::AwayFromZero => RoundingStrategy::AwayFromZero,
        RoundMode::Floor => RoundingStrategy::ToNegativeInfinity,
        RoundMode::Ceiling => RoundingStrategy::ToPositiveInfinity,
    }
}
