use std::str::FromStr;

use rust_decimal::Decimal;
use unitflow_core::{Category, ConversionRequest, Notation, RoundMode, UnitCatalog};

#[test]
fn category_serialization_uses_stable_snake_case_ids() {
    assert_eq!(serde_json::to_string(&Category::DataSize).unwrap(), "\"data_size\"");
    assert_eq!(serde_json::to_string(&Category::Temperature).unwrap(), "\"temperature\"");
    assert_eq!(
        serde_json::from_str::<Category>("\"data_size\"").unwrap(),
        Category::DataSize
    );
}

#[test]
fn rounding_and_notation_enums_round_trip() {
    for mode in [
        RoundMode::NearestEven,
        RoundMode::HalfAwayFromZero,
        RoundMode::TowardZero,
        RoundMode::AwayFromZero,
        RoundMode::Floor,
        RoundMode::Ceiling,
    ] {
        let json = serde_json::to_string(&mode).unwrap();
        assert_eq!(serde_json::from_str::<RoundMode>(&json).unwrap(), mode);
    }

    for notation in [Notation::Plain, Notation::Scientific, Notation::Engineering] {
        let json = serde_json::to_string(&notation).unwrap();
        assert_eq!(serde_json::from_str::<Notation>(&json).unwrap(), notation);
    }
}

#[test]
fn conversion_request_round_trips_without_binary_float() {
    let request = ConversionRequest {
        value: Decimal::from_str("1234567890.000000123456789").unwrap(),
        from_unit_id: "meter".to_owned(),
        to_unit_id: "inch".to_owned(),
        decimal_places: Some(18),
        round_mode: RoundMode::NearestEven,
    };

    let json = serde_json::to_string(&request).unwrap();
    let restored: ConversionRequest = serde_json::from_str(&json).unwrap();
    assert_eq!(restored, request);
}

#[test]
fn builtin_unit_definition_round_trips() {
    let catalog = UnitCatalog::built_in().expect("catalog");
    let fahrenheit = catalog.get("fahrenheit").expect("fahrenheit");
    let json = serde_json::to_string(fahrenheit).unwrap();
    let restored = serde_json::from_str(&json).unwrap();
    assert_eq!(fahrenheit, &restored);
}
