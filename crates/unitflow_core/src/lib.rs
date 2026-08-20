#![forbid(unsafe_code)]
#![deny(missing_debug_implementations)]

//! UnitFlow's authoritative, offline-first unit conversion domain engine.
//!
//! The crate keeps conversion rules independent from Flutter and platform services.

pub mod bridge;
pub mod catalog;
pub mod converter;
pub mod custom_unit;
pub mod education;
pub mod error;
pub mod model;
pub mod notation;

pub use bridge::{
    BridgeBatchConversionRequest, BridgeConversionRequest, BridgeConversionResponse,
    BridgeFailure, BridgeService, BRIDGE_BACKEND_ID, BRIDGE_PROTOCOL_VERSION,
};
pub use catalog::UnitCatalog;
pub use converter::{convert_between, ConversionRequest, ConversionResult, Converter, RoundMode};
pub use custom_unit::{merged_catalog, CustomUnitDraft};
pub use education::{category_guide, CategoryGuide};
pub use error::UnitFlowError;
pub use model::{Category, UnitDefinition};
pub use notation::{format_decimal, Notation};

/// Crate/application version used in diagnostics and About surfaces.
pub const VERSION: &str = env!("CARGO_PKG_VERSION");
