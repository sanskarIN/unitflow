use unitflow_core::{Category, UnitCatalog};

#[test]
fn built_in_catalog_covers_every_declared_category() {
    let catalog = UnitCatalog::built_in().expect("built-in constants must be valid");

    assert!(
        catalog.len() >= 100,
        "catalog should remain broad enough for the MVP"
    );
    for category in Category::ALL {
        assert!(
            catalog.get(category.base_unit_id()).is_some(),
            "missing base unit for {category}"
        );
        assert!(
            !catalog.units_for_category(category).is_empty(),
            "missing units for {category}"
        );
    }
}

#[test]
fn search_matches_symbols_names_and_aliases() {
    let catalog = UnitCatalog::built_in().expect("catalog");

    assert_eq!(catalog.search("psi", None, 5)[0].id, "psi");
    assert_eq!(
        catalog.search("metre", Some(Category::Length), 5)[0].id,
        "meter"
    );
    assert!(catalog
        .search("gallon", Some(Category::Volume), 10)
        .iter()
        .any(|unit| unit.id == "gallon_imperial"));
}

#[test]
fn exact_search_ranks_before_substring_matches() {
    let catalog = UnitCatalog::built_in().expect("catalog");
    let results = catalog.search("bar", Some(Category::Pressure), 10);

    assert_eq!(results.first().map(|unit| unit.id.as_str()), Some("bar"));
}

#[test]
fn zero_limit_returns_no_search_results() {
    let catalog = UnitCatalog::built_in().expect("catalog");
    assert!(catalog.search("meter", None, 0).is_empty());
}
