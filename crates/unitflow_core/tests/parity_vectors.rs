use std::str::FromStr;

use rust_decimal::Decimal;
use serde::Deserialize;
use unitflow_core::{ConversionRequest, Converter, RoundMode, UnitCatalog};

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Vector {
    name: String,
    input: String,
    from: String,
    to: String,
    decimal_places: u32,
    rounding_mode: String,
    expected: String,
}

#[test]
fn rust_core_matches_shared_conversion_vectors() {
    let vectors: Vec<Vector> = serde_json::from_str(include_str!(
        "../../../test_vectors/conversions.json"
    ))
    .expect("shared conversion vectors must be valid JSON");
    let converter = Converter::new(UnitCatalog::built_in().expect("built-in catalog must validate"));

    for vector in vectors {
        let result = converter
            .convert(&ConversionRequest {
                value: Decimal::from_str(&vector.input).expect("vector input must be decimal"),
                from_unit_id: vector.from,
                to_unit_id: vector.to,
                decimal_places: Some(vector.decimal_places),
                round_mode: round_mode(&vector.rounding_mode),
            })
            .unwrap_or_else(|error| panic!("{} failed: {error}", vector.name));

        assert_eq!(
            result.output.normalize().to_string(),
            vector.expected,
            "shared vector mismatch: {}",
            vector.name
        );
    }
}

fn round_mode(value: &str) -> RoundMode {
    match value {
        "nearestEven" => RoundMode::NearestEven,
        "halfAwayFromZero" => RoundMode::HalfAwayFromZero,
        "towardZero" => RoundMode::TowardZero,
        "awayFromZero" => RoundMode::AwayFromZero,
        "floor" => RoundMode::Floor,
        "ceiling" => RoundMode::Ceiling,
        other => panic!("unsupported shared vector round mode: {other}"),
    }
}
