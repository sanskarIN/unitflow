use rust_decimal::Decimal;
use unitflow_core::{Category, UnitDefinition};

#[test]
fn unit_definition_matches_description_text() {
    let unit = UnitDefinition::new(
        "sample_unit",
        Category::Length,
        "Sample Unit",
        "su",
        vec!["sample".to_owned()],
        "Useful for calibration reference examples.",
        Decimal::ONE,
        Decimal::ZERO,
        false,
    )
    .expect("valid unit");

    assert!(unit.matches_query("calibration"));
    assert!(unit.matches_query("REFERENCE"));
    assert!(!unit.matches_query("temperature"));
}
