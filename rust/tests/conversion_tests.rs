use std::str::FromStr;

use rust_decimal::Decimal;
use unitflow_core::{
    convert, convert_custom, convert_str, search_units, ConversionError, ConversionOptions,
    CustomUnit, RoundingMode,
};

fn options(dp: u32) -> ConversionOptions {
    ConversionOptions {
        decimal_places: dp,
        rounding: RoundingMode::HalfEven,
    }
}

#[test]
fn kilometer_to_meter_is_exact() {
    let result = convert_str("1.25", "km", "m", options(6)).expect("conversion should succeed");
    assert_eq!(result.value, Decimal::from_str("1250").unwrap());
}

#[test]
fn pounds_to_kilograms_matches_exact_definition() {
    let result = convert_str("2", "lb", "kg", options(12)).expect("conversion should succeed");
    assert_eq!(result.value, Decimal::from_str("0.90718474").unwrap());
}

#[test]
fn celsius_to_fahrenheit_handles_affine_transform() {
    let result = convert_str("100", "celsius", "fahrenheit", options(8))
        .expect("conversion should succeed");
    assert_eq!(result.value, Decimal::from(212u32));
}

#[test]
fn fahrenheit_to_celsius_handles_affine_transform() {
    let result = convert_str("32", "fahrenheit", "celsius", options(8))
        .expect("conversion should succeed");
    assert_eq!(result.value, Decimal::ZERO);
}

#[test]
fn decimal_and_binary_data_units_are_distinct() {
    let decimal = convert_str("1", "MB", "B", options(0)).unwrap();
    let binary = convert_str("1", "MiB", "B", options(0)).unwrap();
    assert_eq!(decimal.value, Decimal::from(1_000_000u32));
    assert_eq!(binary.value, Decimal::from(1_048_576u32));
}

#[test]
fn category_mismatch_is_rejected() {
    let error = convert_str("10", "m", "kg", options(4)).expect_err("must reject mismatch");
    assert!(matches!(error, ConversionError::CategoryMismatch { .. }));
}

#[test]
fn invalid_precision_is_rejected() {
    let error = convert(
        Decimal::ONE,
        "m",
        "cm",
        ConversionOptions {
            decimal_places: 29,
            rounding: RoundingMode::HalfEven,
        },
    )
    .expect_err("must reject unsupported precision");
    assert_eq!(error, ConversionError::InvalidPrecision(29));
}

#[test]
fn catalog_search_matches_aliases_and_descriptions() {
    assert!(search_units("metre").iter().any(|unit| unit.id == "meter"));
    assert!(search_units("thermodynamic")
        .iter()
        .any(|unit| unit.id == "kelvin"));
}

#[test]
fn custom_affine_units_round_trip() {
    let from = CustomUnit::new(
        "Double plus three",
        "d3",
        Decimal::from(2u32),
        Decimal::from(3u32),
    )
    .unwrap();
    let to = CustomUnit::new("Identity", "i", Decimal::ONE, Decimal::ZERO).unwrap();

    let output = convert_custom(Decimal::from(5u32), &from, &to).unwrap();
    assert_eq!(output, Decimal::from(13u32));
}

#[test]
fn zero_custom_factor_is_rejected() {
    let error = CustomUnit::new("Broken", "x", Decimal::ZERO, Decimal::ZERO)
        .expect_err("zero factor must be invalid");
    assert!(matches!(error, ConversionError::InvalidCustomUnit(_)));
}
