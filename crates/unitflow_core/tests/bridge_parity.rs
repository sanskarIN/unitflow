use std::str::FromStr;

use rust_decimal::Decimal;
use unitflow_core::{ConversionRequest, Converter, RoundMode};

struct Vector {
    name: &'static str,
    value: &'static str,
    from: &'static str,
    to: &'static str,
    decimal_places: u32,
    round_mode: RoundMode,
    expected: &'static str,
}

#[test]
fn rust_engine_satisfies_bridge_parity_vectors() {
    let converter = Converter::with_built_in_catalog().expect("built-in catalog");
    let vectors = [
        Vector {
            name: "meters to kilometers",
            value: "1500",
            from: "meter",
            to: "kilometer",
            decimal_places: 12,
            round_mode: RoundMode::NearestEven,
            expected: "1.5",
        },
        Vector {
            name: "kilometers to meters",
            value: "1.5",
            from: "kilometer",
            to: "meter",
            decimal_places: 12,
            round_mode: RoundMode::NearestEven,
            expected: "1500",
        },
        Vector {
            name: "celsius freezing point to fahrenheit",
            value: "0",
            from: "celsius",
            to: "fahrenheit",
            decimal_places: 12,
            round_mode: RoundMode::NearestEven,
            expected: "32",
        },
        Vector {
            name: "hours to seconds",
            value: "1",
            from: "hour",
            to: "second",
            decimal_places: 12,
            round_mode: RoundMode::NearestEven,
            expected: "3600",
        },
        Vector {
            name: "kibibyte to byte",
            value: "1",
            from: "kibibyte",
            to: "byte",
            decimal_places: 12,
            round_mode: RoundMode::NearestEven,
            expected: "1024",
        },
        Vector {
            name: "floor positive sub-centimeter kilometer result",
            value: "1",
            from: "meter",
            to: "kilometer",
            decimal_places: 2,
            round_mode: RoundMode::Floor,
            expected: "0",
        },
        Vector {
            name: "ceiling positive sub-centimeter kilometer result",
            value: "1",
            from: "meter",
            to: "kilometer",
            decimal_places: 2,
            round_mode: RoundMode::Ceiling,
            expected: "0.01",
        },
    ];

    for vector in vectors {
        let request = ConversionRequest {
            value: Decimal::from_str(vector.value).expect("vector decimal"),
            from_unit_id: vector.from.to_owned(),
            to_unit_id: vector.to.to_owned(),
            decimal_places: Some(vector.decimal_places),
            round_mode: vector.round_mode,
        };
        let result = converter.convert(&request).expect(vector.name);

        assert_eq!(
            result.output.normalize().to_string(),
            vector.expected,
            "{}",
            vector.name
        );
    }
}
