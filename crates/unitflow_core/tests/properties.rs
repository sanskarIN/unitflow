use proptest::prelude::*;
use rust_decimal::Decimal;
use unitflow_core::{ConversionRequest, Converter, RoundMode};

proptest! {
    #[test]
    fn identity_conversion_preserves_integer_values(value in any::<i64>()) {
        let converter = Converter::with_built_in_catalog().expect("catalog");
        let result = converter.convert(&ConversionRequest {
            value: Decimal::from(value),
            from_unit_id: "meter".to_owned(),
            to_unit_id: "meter".to_owned(),
            decimal_places: None,
            round_mode: RoundMode::NearestEven,
        }).expect("identity conversion");

        prop_assert_eq!(result.output, Decimal::from(value));
    }

    #[test]
    fn metric_length_round_trip_is_exact(value in -1_000_000_000_i64..1_000_000_000_i64) {
        let converter = Converter::with_built_in_catalog().expect("catalog");
        let centimeters = converter.convert(&ConversionRequest {
            value: Decimal::from(value),
            from_unit_id: "meter".to_owned(),
            to_unit_id: "centimeter".to_owned(),
            decimal_places: None,
            round_mode: RoundMode::NearestEven,
        }).expect("meter to centimeter");

        let meters = converter.convert(&ConversionRequest {
            value: centimeters.output,
            from_unit_id: "centimeter".to_owned(),
            to_unit_id: "meter".to_owned(),
            decimal_places: None,
            round_mode: RoundMode::NearestEven,
        }).expect("centimeter to meter");

        prop_assert_eq!(meters.output, Decimal::from(value));
    }

    #[test]
    fn batch_conversion_never_reorders_targets(
        value in -1_000_000_i64..1_000_000_i64,
    ) {
        let converter = Converter::with_built_in_catalog().expect("catalog");
        let targets = vec![
            "millimeter".to_owned(),
            "kilometer".to_owned(),
            "inch".to_owned(),
            "foot".to_owned(),
        ];
        let results = converter.batch_convert(
            Decimal::from(value),
            "meter",
            &targets,
            Some(12),
            RoundMode::NearestEven,
        ).expect("batch conversion");

        prop_assert_eq!(
            results.into_iter().map(|result| result.to_unit_id).collect::<Vec<_>>(),
            targets,
        );
    }
}
