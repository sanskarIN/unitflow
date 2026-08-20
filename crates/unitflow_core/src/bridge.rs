use std::str::FromStr;

use rust_decimal::Decimal;
use serde::{Deserialize, Serialize};

use crate::{ConversionRequest, ConversionResult, Converter, RoundMode, UnitFlowError};

/// Stable application-level protocol version shared with Flutter bridge DTOs.
pub const BRIDGE_PROTOCOL_VERSION: u32 = 1;

/// Diagnostic identifier for the Rust domain bridge implementation.
pub const BRIDGE_BACKEND_ID: &str = "rust-core";

/// Capability identifier for single conversions.
pub const BRIDGE_CAPABILITY_CONVERT: &str = "convert";
/// Capability identifier for ordered batch conversions.
pub const BRIDGE_CAPABILITY_BATCH_CONVERT: &str = "batchConvert";
/// Capability identifier guaranteeing canonical base-10 text at the boundary.
pub const BRIDGE_CAPABILITY_CANONICAL_DECIMAL_TEXT: &str = "canonicalDecimalText";

/// Stable capability set exposed during startup negotiation.
pub const BRIDGE_CAPABILITIES: [&str; 3] = [
    BRIDGE_CAPABILITY_CONVERT,
    BRIDGE_CAPABILITY_BATCH_CONVERT,
    BRIDGE_CAPABILITY_CANONICAL_DECIMAL_TEXT,
];

/// Maximum number of target units accepted by one bridge batch request.
pub const BRIDGE_MAX_BATCH_TARGETS: usize = 256;

const MAX_DECIMAL_TEXT_LENGTH: usize = 1024;
const MAX_UNIT_ID_LENGTH: usize = 64;

/// Generator-friendly startup metadata used before routing conversions natively.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct BridgeInfo {
    pub protocol_version: u32,
    pub backend_id: String,
    pub capabilities: Vec<String>,
}

/// Generator-friendly single-conversion request.
///
/// Decimal values remain canonical base-10 strings at the boundary so generated
/// bindings never need to transport user values through binary floating point.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct BridgeConversionRequest {
    pub value: String,
    pub from_unit_id: String,
    pub to_unit_id: String,
    pub decimal_places: Option<u32>,
    pub round_mode: RoundMode,
}

/// Generator-friendly single-conversion response.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct BridgeConversionResponse {
    pub input: String,
    pub output: String,
    pub from_unit_id: String,
    pub to_unit_id: String,
}

/// Generator-friendly ordered batch-conversion request.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct BridgeBatchConversionRequest {
    pub value: String,
    pub from_unit_id: String,
    pub target_unit_ids: Vec<String>,
    pub decimal_places: Option<u32>,
    pub round_mode: RoundMode,
}

/// Safe bridge failure with a stable machine-readable code.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)]
pub struct BridgeFailure {
    pub code: String,
    pub message: String,
}

impl BridgeFailure {
    fn new(code: &str, message: &str) -> Self {
        Self {
            code: code.to_owned(),
            message: message.to_owned(),
        }
    }

    fn from_domain(error: UnitFlowError) -> Self {
        match error {
            UnitFlowError::UnknownUnit(_) => {
                Self::new("unknown_unit", "Unknown unit identifier.")
            }
            UnitFlowError::CategoryMismatch { .. } => Self::new(
                "category_mismatch",
                "Source and target units must belong to the same category.",
            ),
            UnitFlowError::InvalidPrecision(_) => Self::new(
                "invalid_precision",
                "Decimal precision is outside the supported range.",
            ),
            UnitFlowError::ArithmeticOverflow | UnitFlowError::DivisionByZero => Self::new(
                "conversion_failed",
                "The conversion could not be completed safely.",
            ),
            UnitFlowError::EmptyUnitId
            | UnitFlowError::InvalidUnitId(_)
            | UnitFlowError::EmptyUnitName
            | UnitFlowError::EmptyUnitSymbol
            | UnitFlowError::InvalidScale
            | UnitFlowError::DuplicateUnitId(_)
            | UnitFlowError::InvalidDecimalConstant(_)
            | UnitFlowError::FieldTooLong { .. }
            | UnitFlowError::TooManyAliases { .. }
            | UnitFlowError::EmptyAlias => {
                Self::new("catalog_invalid", "The active unit catalog is invalid.")
            }
        }
    }
}

/// Long-lived Rust conversion service intended to sit behind generated bindings.
#[derive(Debug, Clone)]
pub struct BridgeService {
    converter: Converter,
}

impl BridgeService {
    /// Creates a bridge service over a validated converter/catalog.
    #[must_use]
    pub fn new(converter: Converter) -> Self {
        Self { converter }
    }

    /// Creates a bridge service using UnitFlow's built-in catalog.
    pub fn with_built_in_catalog() -> Result<Self, BridgeFailure> {
        Converter::with_built_in_catalog()
            .map(Self::new)
            .map_err(BridgeFailure::from_domain)
    }

    /// Returns the application-level bridge protocol version.
    #[must_use]
    pub const fn protocol_version(&self) -> u32 {
        BRIDGE_PROTOCOL_VERSION
    }

    /// Returns a diagnostic backend identifier without exposing binding details.
    #[must_use]
    pub const fn backend_id(&self) -> &'static str {
        BRIDGE_BACKEND_ID
    }

    /// Returns startup metadata for protocol and capability negotiation.
    #[must_use]
    pub fn info(&self) -> BridgeInfo {
        BridgeInfo {
            protocol_version: self.protocol_version(),
            backend_id: self.backend_id().to_owned(),
            capabilities: BRIDGE_CAPABILITIES
                .iter()
                .map(|capability| (*capability).to_owned())
                .collect(),
        }
    }

    /// Performs one conversion while preserving the bridge string contract.
    pub fn convert(
        &self,
        request: BridgeConversionRequest,
    ) -> Result<BridgeConversionResponse, BridgeFailure> {
        let value = parse_canonical_decimal(&request.value)?;
        validate_bridge_unit_id(&request.from_unit_id)?;
        validate_bridge_unit_id(&request.to_unit_id)?;
        let result = self
            .converter
            .convert(&ConversionRequest {
                value,
                from_unit_id: request.from_unit_id,
                to_unit_id: request.to_unit_id,
                decimal_places: request.decimal_places,
                round_mode: request.round_mode,
            })
            .map_err(BridgeFailure::from_domain)?;
        Ok(response_from_result(result))
    }

    /// Performs an ordered, resource-bounded batch conversion.
    pub fn batch_convert(
        &self,
        request: BridgeBatchConversionRequest,
    ) -> Result<Vec<BridgeConversionResponse>, BridgeFailure> {
        if request.target_unit_ids.len() > BRIDGE_MAX_BATCH_TARGETS {
            return Err(BridgeFailure::new(
                "invalid_batch",
                "The batch conversion request exceeds the supported target limit.",
            ));
        }

        let value = parse_canonical_decimal(&request.value)?;
        validate_bridge_unit_id(&request.from_unit_id)?;
        for target in &request.target_unit_ids {
            validate_bridge_unit_id(target)?;
        }

        self.converter
            .batch_convert(
                value,
                &request.from_unit_id,
                &request.target_unit_ids,
                request.decimal_places,
                request.round_mode,
            )
            .map(|results| results.into_iter().map(response_from_result).collect())
            .map_err(BridgeFailure::from_domain)
    }
}

fn response_from_result(result: ConversionResult) -> BridgeConversionResponse {
    BridgeConversionResponse {
        input: canonical_decimal(result.input),
        output: canonical_decimal(result.output),
        from_unit_id: result.from_unit_id,
        to_unit_id: result.to_unit_id,
    }
}

fn parse_canonical_decimal(value: &str) -> Result<Decimal, BridgeFailure> {
    if value.is_empty() || value.len() > MAX_DECIMAL_TEXT_LENGTH {
        return Err(invalid_decimal());
    }

    let parsed = Decimal::from_str(value).map_err(|_| invalid_decimal())?;
    if canonical_decimal(parsed) != value {
        return Err(invalid_decimal());
    }
    Ok(parsed)
}

fn validate_bridge_unit_id(value: &str) -> Result<(), BridgeFailure> {
    let valid = !value.is_empty()
        && value.len() <= MAX_UNIT_ID_LENGTH
        && value
            .bytes()
            .all(|byte| byte.is_ascii_lowercase() || byte.is_ascii_digit() || matches!(byte, b'_' | b'-'));
    if valid {
        Ok(())
    } else {
        Err(BridgeFailure::new(
            "unknown_unit",
            "Unknown unit identifier.",
        ))
    }
}

fn canonical_decimal(value: Decimal) -> String {
    value.normalize().to_string()
}

fn invalid_decimal() -> BridgeFailure {
    BridgeFailure::new(
        "invalid_decimal",
        "Decimal text must be canonical and within supported bounds.",
    )
}
