use std::str::FromStr;

use rust_decimal::Decimal;
use unitflow_core::{format_decimal, Notation, RoundMode, UnitFlowError};

fn dec(value: &str) -> Decimal {
    Decimal::from_str(value).expect("valid test decimal")
}

#[test]
fn formats_scientific_notation() {
    let formatted = format_decimal(
        dec("12345"),
        Notation::Scientific,
        Some(4),
        RoundMode::NearestEven,
    )
    .expect("format");
    assert_eq!(formatted, "1.2345e+4");
}

#[test]
fn formats_engineering_notation() {
    let formatted = format_decimal(
        dec("12345"),
        Notation::Engineering,
        Some(4),
        RoundMode::NearestEven,
    )
    .expect("format");
    assert_eq!(formatted, "12.345e+3");

    let small = format_decimal(
        dec("0.12"),
        Notation::Engineering,
        Some(4),
        RoundMode::NearestEven,
    )
    .expect("format");
    assert_eq!(small, "120e-3");
}

#[test]
fn zero_is_canonical() {
    let formatted = format_decimal(
        Decimal::ZERO,
        Notation::Scientific,
        Some(3),
        RoundMode::NearestEven,
    )
    .expect("format");
    assert_eq!(formatted, "0");
}

#[test]
fn rejects_precision_above_decimal_capacity() {
    assert_eq!(
        format_decimal(
            Decimal::ONE,
            Notation::Plain,
            Some(29),
            RoundMode::NearestEven,
        ),
        Err(UnitFlowError::InvalidPrecision(29))
    );
}
