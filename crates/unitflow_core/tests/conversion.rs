use std::str::FromStr;

use rust_decimal::Decimal;
use unitflow_core::{ConversionRequest, Converter, RoundMode, UnitFlowError};

fn d(value: &str) -> Decimal {
    Decimal::from_str(value).expect("test decimal")
}

#[test]
fn converts_metric_length_exactly() {
    let converter = Converter::with_built_in_catalog().expect("catalog");
    let result = converter
        .convert(&ConversionRequest {
            value: d("1000"),
            from_unit_id: "meter".to_owned(),
            to_unit_id: "kilometer".to_owned(),
            decimal_places: None,
            round_mode: RoundMode::NearestEven,
        })
        .expect("conversion");

    assert_eq!(result.output, d("1"));
}

#[test]
fn converts_international_mile_to_kilometers() {
    let converter = Converter::with_built_in_catalog().expect("catalog");
    let result = converter
        .convert(&ConversionRequest {
            value: Decimal::ONE,
            from_unit_id: "mile".to_owned(),
            to_unit_id: "kilometer".to_owned(),
            decimal_places: Some(6),
            round_mode: RoundMode::NearestEven,
        })
        .expect("conversion");

    assert_eq!(result.output, d("1.609344"));
}

#[test]
fn affine_temperature_conversion_works_both_directions() {
    let converter = Converter::with_built_in_catalog().expect("catalog");

    let freezing_f = converter
        .convert(&ConversionRequest {
            value: Decimal::ZERO,
            from_unit_id: "celsius".to_owned(),
            to_unit_id: "fahrenheit".to_owned(),
            decimal_places: Some(6),
            round_mode: RoundMode::NearestEven,
        })
        .expect("celsius to fahrenheit");
    assert_eq!(freezing_f.output, d("32"));

    let boiling_c = converter
        .convert(&ConversionRequest {
            value: d("212"),
            from_unit_id: "fahrenheit".to_owned(),
            to_unit_id: "celsius".to_owned(),
            decimal_places: Some(6),
            round_mode: RoundMode::NearestEven,
        })
        .expect("fahrenheit to celsius");
    assert_eq!(boiling_c.output, d("100"));
}

#[test]
fn rejects_cross_category_conversion() {
    let converter = Converter::with_built_in_catalog().expect("catalog");
    let error = converter
        .convert(&ConversionRequest {
            value: Decimal::ONE,
            from_unit_id: "meter".to_owned(),
            to_unit_id: "second".to_owned(),
            decimal_places: None,
            round_mode: RoundMode::NearestEven,
        })
        .expect_err("category mismatch should fail");

    assert!(matches!(error, UnitFlowError::CategoryMismatch { .. }));
}

#[test]
fn explicit_round_modes_are_respected() {
    let converter = Converter::with_built_in_catalog().expect("catalog");

    let nearest_even = converter
        .convert(&ConversionRequest {
            value: d("2.5"),
            from_unit_id: "meter".to_owned(),
            to_unit_id: "meter".to_owned(),
            decimal_places: Some(0),
            round_mode: RoundMode::NearestEven,
        })
        .expect("round");
    assert_eq!(nearest_even.output, d("2"));

    let half_away = converter
        .convert(&ConversionRequest {
            value: d("2.5"),
            from_unit_id: "meter".to_owned(),
            to_unit_id: "meter".to_owned(),
            decimal_places: Some(0),
            round_mode: RoundMode::HalfAwayFromZero,
        })
        .expect("round");
    assert_eq!(half_away.output, d("3"));
}

#[test]
fn batch_conversion_preserves_requested_target_order() {
    let converter = Converter::with_built_in_catalog().expect("catalog");
    let targets = vec![
        "centimeter".to_owned(),
        "kilometer".to_owned(),
        "inch".to_owned(),
    ];

    let results = converter
        .batch_convert(
            Decimal::ONE,
            "meter",
            &targets,
            Some(6),
            RoundMode::NearestEven,
        )
        .expect("batch conversion");

    assert_eq!(results.len(), 3);
    assert_eq!(results[0].to_unit_id, "centimeter");
    assert_eq!(results[1].to_unit_id, "kilometer");
    assert_eq!(results[2].to_unit_id, "inch");
}

#[test]
fn rejects_precision_above_decimal_capacity() {
    let converter = Converter::with_built_in_catalog().expect("catalog");
    let error = converter
        .convert(&ConversionRequest {
            value: Decimal::ONE,
            from_unit_id: "meter".to_owned(),
            to_unit_id: "foot".to_owned(),
            decimal_places: Some(29),
            round_mode: RoundMode::NearestEven,
        })
        .expect_err("precision should be bounded");

    assert_eq!(error, UnitFlowError::InvalidPrecision(29));
}
