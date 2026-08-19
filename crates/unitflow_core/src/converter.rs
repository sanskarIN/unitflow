use rust_decimal::{Decimal, RoundingStrategy};
use serde::{Deserialize, Serialize};

use crate::catalog::UnitCatalog;
use crate::error::UnitFlowError;
use crate::model::{Category, UnitDefinition};

/// Explicit rounding modes exposed by the domain API.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
#[serde(rename_all = "camelCase")]
pub enum RoundMode {
    /// Banker's rounding: ties go to the nearest even digit.
    #[default]
    NearestEven,
    /// Ties are rounded away from zero.
    HalfAwayFromZero,
    /// Truncate discarded digits toward zero.
    TowardZero,
    /// Round any discarded magnitude away from zero.
    AwayFromZero,
    /// Round toward negative infinity.
    Floor,
    /// Round toward positive infinity.
    Ceiling,
}

impl RoundMode {
    const fn strategy(self) -> RoundingStrategy {
        match self {
            Self::NearestEven => RoundingStrategy::MidpointNearestEven,
            Self::HalfAwayFromZero => RoundingStrategy::MidpointAwayFromZero,
            Self::TowardZero => RoundingStrategy::ToZero,
            Self::AwayFromZero => RoundingStrategy::AwayFromZero,
            Self::Floor => RoundingStrategy::ToNegativeInfinity,
            Self::Ceiling => RoundingStrategy::ToPositiveInfinity,
        }
    }
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ConversionRequest {
    pub value: Decimal,
    pub from_unit_id: String,
    pub to_unit_id: String,
    /// Decimal places to keep. `None` preserves the calculation's representable precision.
    pub decimal_places: Option<u32>,
    pub round_mode: RoundMode,
}

#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct ConversionResult {
    pub input: Decimal,
    pub output: Decimal,
    pub from_unit_id: String,
    pub to_unit_id: String,
    pub category: Category,
    pub decimal_places: Option<u32>,
    pub round_mode: RoundMode,
}

/// High-precision converter backed by a validated unit catalog.
#[derive(Debug, Clone)]
pub struct Converter {
    catalog: UnitCatalog,
}

impl Converter {
    #[must_use]
    pub fn new(catalog: UnitCatalog) -> Self {
        Self { catalog }
    }

    pub fn with_built_in_catalog() -> Result<Self, UnitFlowError> {
        Ok(Self::new(UnitCatalog::built_in()?))
    }

    #[must_use]
    pub fn catalog(&self) -> &UnitCatalog {
        &self.catalog
    }

    pub fn convert(&self, request: &ConversionRequest) -> Result<ConversionResult, UnitFlowError> {
        validate_precision(request.decimal_places)?;

        let from = self
            .catalog
            .get(&request.from_unit_id)
            .ok_or_else(|| UnitFlowError::UnknownUnit(request.from_unit_id.clone()))?;
        let to = self
            .catalog
            .get(&request.to_unit_id)
            .ok_or_else(|| UnitFlowError::UnknownUnit(request.to_unit_id.clone()))?;

        let output = convert_between(
            request.value,
            from,
            to,
            request.decimal_places,
            request.round_mode,
        )?;

        Ok(ConversionResult {
            input: request.value,
            output,
            from_unit_id: from.id.clone(),
            to_unit_id: to.id.clone(),
            category: from.category,
            decimal_places: request.decimal_places,
            round_mode: request.round_mode,
        })
    }

    /// Converts one source value to multiple target units while preserving target order.
    pub fn batch_convert(
        &self,
        value: Decimal,
        from_unit_id: &str,
        target_unit_ids: &[String],
        decimal_places: Option<u32>,
        round_mode: RoundMode,
    ) -> Result<Vec<ConversionResult>, UnitFlowError> {
        validate_precision(decimal_places)?;
        let mut results = Vec::with_capacity(target_unit_ids.len());
        for target in target_unit_ids {
            results.push(self.convert(&ConversionRequest {
                value,
                from_unit_id: from_unit_id.to_owned(),
                to_unit_id: target.clone(),
                decimal_places,
                round_mode,
            })?);
        }
        Ok(results)
    }
}

/// Converts between two validated definitions. This is also useful for custom-unit tests
/// before a custom unit has been merged into a user catalog.
pub fn convert_between(
    value: Decimal,
    from: &UnitDefinition,
    to: &UnitDefinition,
    decimal_places: Option<u32>,
    round_mode: RoundMode,
) -> Result<Decimal, UnitFlowError> {
    validate_precision(decimal_places)?;

    if from.category != to.category {
        return Err(UnitFlowError::CategoryMismatch {
            from: from.category,
            to: to.category,
        });
    }
    if to.scale.is_zero() {
        return Err(UnitFlowError::DivisionByZero);
    }

    let base = value
        .checked_mul(from.scale)
        .and_then(|scaled| scaled.checked_add(from.offset))
        .ok_or(UnitFlowError::ArithmeticOverflow)?;

    let output = base
        .checked_sub(to.offset)
        .and_then(|shifted| shifted.checked_div(to.scale))
        .ok_or(UnitFlowError::ArithmeticOverflow)?;

    match decimal_places {
        Some(places) => Ok(output.round_dp_with_strategy(places, round_mode.strategy())),
        None => Ok(output),
    }
}

fn validate_precision(decimal_places: Option<u32>) -> Result<(), UnitFlowError> {
    if let Some(places) = decimal_places {
        if places > 28 {
            return Err(UnitFlowError::InvalidPrecision(places));
        }
    }
    Ok(())
}
