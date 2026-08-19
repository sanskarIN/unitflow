use std::collections::HashSet;
use std::fmt;

use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};

use crate::error::UnitFlowError;

/// Stable category identifiers used by the conversion engine and persisted user data.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, Serialize, Deserialize)]
#[serde(rename_all = "snake_case")]
pub enum Category {
    Length,
    Area,
    Volume,
    Mass,
    Speed,
    Pressure,
    Energy,
    Power,
    Angle,
    DataSize,
    Frequency,
    Time,
    Temperature,
}

impl Category {
    pub const ALL: [Self; 13] = [
        Self::Length,
        Self::Area,
        Self::Volume,
        Self::Mass,
        Self::Speed,
        Self::Pressure,
        Self::Energy,
        Self::Power,
        Self::Angle,
        Self::DataSize,
        Self::Frequency,
        Self::Time,
        Self::Temperature,
    ];

    /// Stable identifier of the built-in base unit used for this category.
    #[must_use]
    pub const fn base_unit_id(self) -> &'static str {
        match self {
            Self::Length => "meter",
            Self::Area => "square_meter",
            Self::Volume => "liter",
            Self::Mass => "kilogram",
            Self::Speed => "meter_per_second",
            Self::Pressure => "pascal",
            Self::Energy => "joule",
            Self::Power => "watt",
            Self::Angle => "radian",
            Self::DataSize => "byte",
            Self::Frequency => "hertz",
            Self::Time => "second",
            Self::Temperature => "kelvin",
        }
    }
}

impl fmt::Display for Category {
    fn fmt(&self, formatter: &mut fmt::Formatter<'_>) -> fmt::Result {
        let value = match self {
            Self::Length => "length",
            Self::Area => "area",
            Self::Volume => "volume",
            Self::Mass => "mass",
            Self::Speed => "speed",
            Self::Pressure => "pressure",
            Self::Energy => "energy",
            Self::Power => "power",
            Self::Angle => "angle",
            Self::DataSize => "data size",
            Self::Frequency => "frequency",
            Self::Time => "time",
            Self::Temperature => "temperature",
        };
        formatter.write_str(value)
    }
}

/// A validated unit and its affine relationship to a category base unit.
///
/// The relationship is `base = input * scale + offset`.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct UnitDefinition {
    pub id: String,
    pub category: Category,
    pub name: String,
    pub symbol: String,
    pub aliases: Vec<String>,
    pub description: String,
    pub scale: Decimal,
    pub offset: Decimal,
    pub is_builtin: bool,
}

impl UnitDefinition {
    #[allow(clippy::too_many_arguments)]
    pub fn new(
        id: impl Into<String>,
        category: Category,
        name: impl Into<String>,
        symbol: impl Into<String>,
        aliases: Vec<String>,
        description: impl Into<String>,
        scale: Decimal,
        offset: Decimal,
        is_builtin: bool,
    ) -> Result<Self, UnitFlowError> {
        let id = id.into().trim().to_owned();
        let name = name.into().trim().to_owned();
        let symbol = symbol.into().trim().to_owned();
        let description = description.into().trim().to_owned();

        if id.is_empty() {
            return Err(UnitFlowError::EmptyUnitId);
        }
        if id.chars().count() > 64 {
            return Err(UnitFlowError::FieldTooLong {
                field: "id",
                max: 64,
            });
        }
        if !id
            .chars()
            .all(|character| character.is_ascii_lowercase() || character.is_ascii_digit() || character == '_' || character == '-')
        {
            return Err(UnitFlowError::InvalidUnitId(id));
        }
        if name.is_empty() {
            return Err(UnitFlowError::EmptyUnitName);
        }
        if name.chars().count() > 128 {
            return Err(UnitFlowError::FieldTooLong {
                field: "name",
                max: 128,
            });
        }
        if symbol.is_empty() {
            return Err(UnitFlowError::EmptyUnitSymbol);
        }
        if symbol.chars().count() > 32 {
            return Err(UnitFlowError::FieldTooLong {
                field: "symbol",
                max: 32,
            });
        }
        if description.chars().count() > 512 {
            return Err(UnitFlowError::FieldTooLong {
                field: "description",
                max: 512,
            });
        }
        if scale <= Decimal::ZERO {
            return Err(UnitFlowError::InvalidScale);
        }

        let mut normalized_aliases = Vec::with_capacity(aliases.len());
        let mut seen = HashSet::new();
        for alias in aliases {
            let alias = alias.trim().to_owned();
            if alias.is_empty() {
                return Err(UnitFlowError::EmptyAlias);
            }
            if alias.chars().count() > 64 {
                return Err(UnitFlowError::FieldTooLong {
                    field: "alias",
                    max: 64,
                });
            }
            let key = alias.to_lowercase();
            if seen.insert(key) {
                normalized_aliases.push(alias);
            }
        }

        Ok(Self {
            id,
            category,
            name,
            symbol,
            aliases: normalized_aliases,
            description,
            scale,
            offset,
            is_builtin,
        })
    }

    #[must_use]
    pub fn matches_query(&self, query: &str) -> bool {
        let query = query.trim().to_lowercase();
        if query.is_empty() {
            return true;
        }

        self.id.to_lowercase().contains(&query)
            || self.name.to_lowercase().contains(&query)
            || self.symbol.to_lowercase().contains(&query)
            || self
                .aliases
                .iter()
                .any(|alias| alias.to_lowercase().contains(&query))
    }
}
