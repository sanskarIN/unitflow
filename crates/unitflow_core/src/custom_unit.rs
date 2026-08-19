use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};

use crate::error::UnitFlowError;
use crate::model::{Category, UnitDefinition};

/// User-editable definition for an affine custom unit.
///
/// UnitFlow intentionally starts with an affine formula instead of evaluating arbitrary
/// executable expressions. This supports common linear/temperature-like units while keeping
/// validation deterministic and safe: `base = input * scale + offset`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct CustomUnitDraft {
    pub id: String,
    pub category: Category,
    pub name: String,
    pub symbol: String,
    pub aliases: Vec<String>,
    pub description: String,
    pub scale: Decimal,
    pub offset: Decimal,
}

impl CustomUnitDraft {
    pub fn validate(self) -> Result<UnitDefinition, UnitFlowError> {
        UnitDefinition::new(
            self.id,
            self.category,
            self.name,
            self.symbol,
            self.aliases,
            self.description,
            self.scale,
            self.offset,
            false,
        )
    }
}

/// Combines built-in and custom units while protecting stable identifiers from collisions.
pub fn merged_catalog(
    built_ins: impl IntoIterator<Item = UnitDefinition>,
    custom_units: impl IntoIterator<Item = UnitDefinition>,
) -> Result<crate::catalog::UnitCatalog, UnitFlowError> {
    let mut units: Vec<UnitDefinition> = built_ins.into_iter().collect();
    units.extend(custom_units);
    crate::catalog::UnitCatalog::new(units)
}
