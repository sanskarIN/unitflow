use std::str::FromStr;

use rust_decimal::Decimal;
use unitflow_core::{Category, ConversionRequest, Converter, RoundMode, UnitCatalog};

fn d(value: &str) -> Decimal {
    Decimal::from_str(value).expect("test decimal")
}

#[test]
fn every_category_has_a_valid_identity_base_unit() {
    let catalog = UnitCatalog::built_in().expect("catalog");

    for category in Category::ALL {
        let units = catalog.units_for_category(category);
        assert!(!units.is_empty(), "{category} should contain units");

        let base = catalog.get(category.base_unit_id()).expect("base unit");
        assert_eq!(base.category, category);
        assert_eq!(base.scale, Decimal::ONE);
        assert_eq!(base.offset, Decimal::ZERO);
    }
}

#[test]
fn every_builtin_unit_converts_to_itself_without_change() {
    let converter = Converter::with_built_in_catalog().expect("catalog");
    let samples = [d("-123.456"), Decimal::ZERO, Decimal::ONE, d("987654.321")];

    for unit in converter.catalog().all() {
        for value in samples {
            let result = converter
                .convert(&ConversionRequest {
                    value,
                    from_unit_id: unit.id.clone(),
                    to_unit_id: unit.id.clone(),
                    decimal_places: None,
                    round_mode: RoundMode::NearestEven,
                })
                .expect("identity conversion");
            assert_eq!(result.output, value, "identity failed for {}", unit.id);
        }
    }
}

#[test]
fn base_round_trip_is_stable_for_every_builtin_unit() {
    let converter = Converter::with_built_in_catalog().expect("catalog");
    let lower = d("0.9999999999");
    let upper = d("1.0000000001");

    for unit in converter.catalog().all() {
        let base_id = unit.category.base_unit_id();
        let outbound = converter
            .convert(&ConversionRequest {
                value: Decimal::ONE,
                from_unit_id: unit.id.clone(),
                to_unit_id: base_id.to_owned(),
                decimal_places: Some(18),
                round_mode: RoundMode::NearestEven,
            })
            .expect("outbound conversion");
        let returned = converter
            .convert(&ConversionRequest {
                value: outbound.output,
                from_unit_id: base_id.to_owned(),
                to_unit_id: unit.id.clone(),
                decimal_places: Some(10),
                round_mode: RoundMode::NearestEven,
            })
            .expect("return conversion");

        assert!(
            returned.output >= lower && returned.output <= upper,
            "round trip drifted for {}: {}",
            unit.id,
            returned.output,
        );
    }
}
