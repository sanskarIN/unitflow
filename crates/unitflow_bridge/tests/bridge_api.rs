use unitflow_bridge::api::converter::{
    batch_convert_value, bridge_version, convert_value, format_value, list_units, search_units,
    BridgeNotation, BridgeRoundMode,
};

#[test]
fn exposes_core_version() {
    assert!(!bridge_version().is_empty());
}

#[test]
fn exposes_catalog_units() {
    let units = list_units().expect("catalog should be valid");
    assert!(units.iter().any(|unit| unit.id == "meter"));
    assert!(units.iter().any(|unit| unit.id == "fahrenheit"));
}

#[test]
fn converts_through_bridge_using_decimal_strings() {
    let result = convert_value(
        "1000".to_owned(),
        "meter".to_owned(),
        "kilometer".to_owned(),
        Some(6),
        BridgeRoundMode::NearestEven,
    )
    .expect("conversion");

    assert_eq!(result.input, "1000");
    assert_eq!(result.output, "1");
    assert_eq!(result.from_unit_id, "meter");
    assert_eq!(result.to_unit_id, "kilometer");
    assert_eq!(result.category, "length");
}

#[test]
fn batch_conversion_preserves_requested_target_order() {
    let results = batch_convert_value(
        "1".to_owned(),
        "meter".to_owned(),
        vec![
            "centimeter".to_owned(),
            "kilometer".to_owned(),
            "inch".to_owned(),
        ],
        Some(6),
        BridgeRoundMode::NearestEven,
    )
    .expect("batch conversion");

    assert_eq!(results.len(), 3);
    assert_eq!(results[0].to_unit_id, "centimeter");
    assert_eq!(results[0].output, "100");
    assert_eq!(results[1].to_unit_id, "kilometer");
    assert_eq!(results[1].output, "0.001");
    assert_eq!(results[2].to_unit_id, "inch");
}

#[test]
fn empty_batch_returns_no_results() {
    let results = batch_convert_value(
        "1".to_owned(),
        "meter".to_owned(),
        Vec::new(),
        Some(6),
        BridgeRoundMode::NearestEven,
    )
    .expect("empty batch conversion");

    assert!(results.is_empty());
}

#[test]
fn batch_conversion_rejects_unknown_target_without_partial_results() {
    let error = batch_convert_value(
        "1".to_owned(),
        "meter".to_owned(),
        vec!["kilometer".to_owned(), "missing_unit".to_owned()],
        Some(6),
        BridgeRoundMode::NearestEven,
    )
    .expect_err("unknown target should reject the whole batch");

    assert!(error.contains("missing_unit"));
}

#[test]
fn formats_through_bridge_with_explicit_notation_and_rounding() {
    let formatted = format_value(
        "1234.5".to_owned(),
        BridgeNotation::Scientific,
        Some(2),
        BridgeRoundMode::NearestEven,
    )
    .expect("formatting");

    assert_eq!(formatted, "1.23e3");
}

#[test]
fn searches_by_category_string() {
    let results = search_units("meter".to_owned(), Some("length".to_owned()), 20)
        .expect("search");
    assert!(results.iter().all(|unit| unit.category == "length"));
}

#[test]
fn rejects_invalid_decimal_input_consistently() {
    let single = convert_value(
        "not-a-number".to_owned(),
        "meter".to_owned(),
        "kilometer".to_owned(),
        Some(6),
        BridgeRoundMode::NearestEven,
    );
    let batch = batch_convert_value(
        "not-a-number".to_owned(),
        "meter".to_owned(),
        vec!["kilometer".to_owned()],
        Some(6),
        BridgeRoundMode::NearestEven,
    );

    assert_eq!(single.expect_err("single invalid decimal"), "invalid decimal input");
    assert_eq!(batch.expect_err("batch invalid decimal"), "invalid decimal input");
}
