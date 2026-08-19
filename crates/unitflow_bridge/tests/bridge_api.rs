use unitflow_bridge::api::converter::{
    bridge_version, convert_value, list_units, search_units, BridgeRoundMode,
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

    assert_eq!(result.output, "1");
}

#[test]
fn searches_by_category_string() {
    let results = search_units("meter".to_owned(), Some("length".to_owned()), 20)
        .expect("search");
    assert!(results.iter().all(|unit| unit.category == "length"));
}
