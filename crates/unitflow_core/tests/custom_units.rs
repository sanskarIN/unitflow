use rust_decimal::Decimal;
use unitflow_core::{
    convert_between, Category, CustomUnitDraft, RoundMode, UnitCatalog, UnitFlowError,
};

fn custom_scale(scale: Decimal) -> CustomUnitDraft {
    CustomUnitDraft {
        id: "custom_length".to_owned(),
        category: Category::Length,
        name: "Custom Length".to_owned(),
        symbol: "cl".to_owned(),
        aliases: vec!["custom len".to_owned()],
        description: "Test-only custom unit".to_owned(),
        scale,
        offset: Decimal::ZERO,
    }
}

#[test]
fn validates_and_converts_custom_affine_unit() {
    let catalog = UnitCatalog::built_in().expect("catalog");
    let meter = catalog.get("meter").expect("meter");
    let custom = custom_scale(Decimal::from(2_u32))
        .validate()
        .expect("valid custom unit");

    let value = convert_between(
        Decimal::from(3_u32),
        &custom,
        meter,
        None,
        RoundMode::NearestEven,
    )
    .expect("conversion");

    assert_eq!(value, Decimal::from(6_u32));
    assert!(!custom.is_builtin);
}

#[test]
fn zero_scale_is_rejected() {
    let error = custom_scale(Decimal::ZERO)
        .validate()
        .expect_err("zero scale must fail");
    assert_eq!(error, UnitFlowError::InvalidScale);
}

#[test]
fn unsafe_identifier_characters_are_rejected() {
    let mut draft = custom_scale(Decimal::ONE);
    draft.id = "../../unit".to_owned();

    assert!(matches!(
        draft.validate(),
        Err(UnitFlowError::InvalidUnitId(_))
    ));
}

#[test]
fn aliases_are_trimmed_and_deduplicated_case_insensitively() {
    let mut draft = custom_scale(Decimal::ONE);
    draft.aliases = vec!["Example".to_owned(), " example ".to_owned()];

    let unit = draft.validate().expect("unit");
    assert_eq!(unit.aliases, vec!["Example"]);
}
