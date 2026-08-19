use thiserror::Error;

use crate::model::Category;

/// Domain failures returned by the UnitFlow conversion engine.
#[derive(Debug, Error, Clone, PartialEq, Eq)]
pub enum UnitFlowError {
    #[error("unit identifier cannot be empty")]
    EmptyUnitId,

    #[error("unit identifier `{0}` is invalid; use lowercase ASCII letters, digits, `_`, or `-`")]
    InvalidUnitId(String),

    #[error("unit name cannot be empty")]
    EmptyUnitName,

    #[error("unit symbol cannot be empty")]
    EmptyUnitSymbol,

    #[error("unit scale must be greater than zero")]
    InvalidScale,

    #[error("duplicate unit identifier `{0}`")]
    DuplicateUnitId(String),

    #[error("unknown unit `{0}`")]
    UnknownUnit(String),

    #[error("cannot convert between category `{from}` and `{to}`")]
    CategoryMismatch { from: Category, to: Category },

    #[error("decimal precision {0} exceeds the supported maximum of 28 places")]
    InvalidPrecision(u32),

    #[error("decimal arithmetic overflow")]
    ArithmeticOverflow,

    #[error("division by zero")]
    DivisionByZero,

    #[error("invalid built-in decimal constant `{0}`")]
    InvalidDecimalConstant(String),

    #[error("field `{field}` exceeds the maximum length of {max} characters")]
    FieldTooLong { field: &'static str, max: usize },

    #[error("alias cannot be empty")]
    EmptyAlias,
}
