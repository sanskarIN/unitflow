use std::str::FromStr;

use rust_decimal::Decimal;
use serde::Deserialize;
use unitflow_core::{ConversionRequest, Converter, RoundMode};

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Fixture {
    protocol_version: u32,
    cases: Vec<Vector>,
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Vector {
    name: String,
    value: String,
    from_unit_id: String,
    to_unit_id: String,
    decimal_places: u32,
    round_mode: RoundMode,
    expected: String,
}

#[test]
fn rust_engine_satisfies_shared_bridge_parity_vectors() {
    let fixture: Fixture = serde_json::from_str(include_str!(
        "../../../fixtures/bridge_parity_v1.json"
    ))
    .expect("bridge parity fixture");
    assert_eq!(fixture.protocol_version, 1, "unsupported parity fixture");

    let converter = Converter::with_built_in_catalog().expect("built-in catalog");
    for vector in fixture.cases {
        let request = ConversionRequest {
            value: Decimal::from_str(&vector.value).expect("vector decimal"),
            from_unit_id: vector.from_unit_id,
            to_unit_id: vector.to_unit_id,
            decimal_places: Some(vector.decimal_places),
            round_mode: vector.round_mode,
        };
        let result = converter.convert(&request).expect(&vector.name);

        assert_eq!(
            result.output.normalize().to_string(),
            vector.expected,
            "{}",
            vector.name
        );
    }
}
