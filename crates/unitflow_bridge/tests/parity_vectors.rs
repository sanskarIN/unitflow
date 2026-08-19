use std::str::FromStr;

use rust_decimal::Decimal;
use unitflow_bridge::api::converter::{convert_value, BridgeRoundMode};
use unitflow_core::{ConversionRequest, Converter, RoundMode};

#[test]
fn representative_bridge_vectors_match_core_results() {
    let core = Converter::with_built_in_catalog().expect("catalog");
    let vectors = [
        ("123.456", "meter", "foot", 12_u32),
        ("-40", "celsius", "fahrenheit", 8_u32),
        ("1", "gallon_us", "liter", 12_u32),
        ("1024", "byte", "kibibyte", 12_u32),
        ("60", "revolution_per_minute", "hertz", 12_u32),
        ("180", "degree", "radian", 18_u32),
    ];

    for (input, from, to, places) in vectors {
        let core_result = core
            .convert(&ConversionRequest {
                value: Decimal::from_str(input).expect("test decimal"),
                from_unit_id: from.to_owned(),
                to_unit_id: to.to_owned(),
                decimal_places: Some(places),
                round_mode: RoundMode::NearestEven,
            })
            .expect("core conversion");

        let bridge_result = convert_value(
            input.to_owned(),
            from.to_owned(),
            to.to_owned(),
            Some(places),
            BridgeRoundMode::NearestEven,
        )
        .expect("bridge conversion");

        assert_eq!(
            bridge_result.output,
            core_result.output.normalize().to_string(),
            "bridge parity failed for {input} {from} -> {to}"
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
