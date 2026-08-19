use serde::Deserialize;
use unitflow_bridge::api::converter::{convert_value, BridgeRoundMode};

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
fn bridge_matches_shared_conversion_vectors() {
    let vectors: Vec<Vector> = serde_json::from_str(include_str!(
        "../../../test_vectors/conversions.json"
    ))
    .expect("shared conversion vectors must be valid JSON");

    for vector in vectors {
        let bridge_result = convert_value(
            vector.input.clone(),
            vector.from.clone(),
            vector.to.clone(),
            Some(vector.decimal_places),
            bridge_round_mode(&vector.rounding_mode),
        )
        .unwrap_or_else(|error| panic!("{} failed: {error}", vector.name));

        assert_eq!(
            bridge_result.output, vector.expected,
            "shared bridge vector mismatch: {}",
            vector.name
        );
    }
}

#[test]
fn bridge_rejects_invalid_decimal_text() {
    let error = convert_value(
        "1.2.3".to_owned(),
        "meter".to_owned(),
        "kilometer".to_owned(),
        Some(6),
        BridgeRoundMode::NearestEven,
    )
    .expect_err("malformed decimal must fail");

    assert_eq!(error, "invalid decimal input");
}

fn bridge_round_mode(value: &str) -> BridgeRoundMode {
    match value {
        "nearestEven" => BridgeRoundMode::NearestEven,
        "halfAwayFromZero" => BridgeRoundMode::HalfAwayFromZero,
        "towardZero" => BridgeRoundMode::TowardZero,
        "awayFromZero" => BridgeRoundMode::AwayFromZero,
        "floor" => BridgeRoundMode::Floor,
        "ceiling" => BridgeRoundMode::Ceiling,
        other => panic!("unsupported shared vector round mode: {other}"),
    }
}
