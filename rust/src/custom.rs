use rust_decimal::Decimal;

use crate::ConversionError;

/// A validated affine custom unit formula: `base = value * factor + offset`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct CustomUnit {
    pub name: String,
    pub symbol: String,
    pub factor_to_base: Decimal,
    pub offset_to_base: Decimal,
}

impl CustomUnit {
    pub fn new(
        name: impl Into<String>,
        symbol: impl Into<String>,
        factor_to_base: Decimal,
        offset_to_base: Decimal,
    ) -> Result<Self, ConversionError> {
        let name = name.into().trim().to_owned();
        let symbol = symbol.into().trim().to_owned();

        if name.is_empty() {
            return Err(ConversionError::InvalidCustomUnit("name cannot be empty".into()));
        }
        if symbol.is_empty() {
            return Err(ConversionError::InvalidCustomUnit("symbol cannot be empty".into()));
        }
        if factor_to_base.is_zero() {
            return Err(ConversionError::InvalidCustomUnit(
                "factor_to_base cannot be zero".into(),
            ));
        }

        Ok(Self {
            name,
            symbol,
            factor_to_base,
            offset_to_base,
        })
    }

    pub fn to_base(&self, value: Decimal) -> Result<Decimal, ConversionError> {
        value
            .checked_mul(self.factor_to_base)
            .and_then(|v| v.checked_add(self.offset_to_base))
            .ok_or_else(|| ConversionError::Arithmetic("custom unit overflow".into()))
    }

    pub fn from_base(&self, value: Decimal) -> Result<Decimal, ConversionError> {
        value
            .checked_sub(self.offset_to_base)
            .and_then(|v| v.checked_div(self.factor_to_base))
            .ok_or_else(|| ConversionError::Arithmetic("custom unit conversion failed".into()))
    }
}

pub fn convert_custom(
    value: Decimal,
    from: &CustomUnit,
    to: &CustomUnit,
) -> Result<Decimal, ConversionError> {
    to.from_base(from.to_base(value)?)
}
