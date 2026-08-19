use core::fmt;

/// Errors returned by the UnitFlow conversion engine.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum ConversionError {
    UnknownUnit(String),
    CategoryMismatch { from: String, to: String },
    InvalidNumber(String),
    InvalidPrecision(u32),
    InvalidCustomUnit(String),
    Arithmetic(String),
}

impl fmt::Display for ConversionError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::UnknownUnit(unit) => write!(f, "unknown unit: {unit}"),
            Self::CategoryMismatch { from, to } => {
                write!(f, "cannot convert between different categories: {from} -> {to}")
            }
            Self::InvalidNumber(value) => write!(f, "invalid decimal value: {value}"),
            Self::InvalidPrecision(value) => write!(f, "precision must be between 0 and 28, got {value}"),
            Self::InvalidCustomUnit(message) => write!(f, "invalid custom unit: {message}"),
            Self::Arithmetic(message) => write!(f, "arithmetic error: {message}"),
        }
    }
}

impl std::error::Error for ConversionError {}
