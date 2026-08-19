//! UnitFlow high-precision conversion core.
//!
//! The crate provides a searchable built-in catalog, decimal conversion,
//! explicit rounding, and validated affine custom units.

pub mod catalog;
pub mod converter;
pub mod custom;
pub mod error;

pub use catalog::{find_unit, search_units, units_for_category, Category, UnitDef, UNITS};
pub use converter::{convert, convert_str, ConversionOptions, ConversionResult, RoundingMode};
pub use custom::{convert_custom, CustomUnit};
pub use error::ConversionError;
