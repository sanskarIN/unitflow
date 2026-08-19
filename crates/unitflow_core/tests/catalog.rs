use std::collections::HashSet;

use unitflow_core::{Category, UnitCatalog};

#[test]
fn built_in_catalog_covers_every_declared_category() {
    let catalog = UnitCatalog::built_in().expect("built-in constants must be valid");

    assert!(catalog.len() >= 100, "catalog should remain broad enough for the MVP");
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
    assert_eq!(catalog.search("metre", Some(Category::Length), 5)[0].id, "meter");
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
fn symbol_search_ranks_exact_match_before_prefixes() {
    let catalog = UnitCatalog::built_in().expect("catalog");
    let results = catalog.search("m", Some(Category::Length), 20);

    assert!(!results.is_empty());
    assert_eq!(results[0].id, "meter");
    assert_eq!(results[0].symbol, "m");
}

#[test]
fn alias_search_is_case_insensitive() {
    let catalog = UnitCatalog::built_in().expect("catalog");
    let results = catalog.search("STATUTE MILE", Some(Category::Length), 10);

    assert_eq!(results.len(), 1);
    assert_eq!(results[0].id, "mile");
}

#[test]
fn category_filter_prevents_cross_category_results() {
    let catalog = UnitCatalog::built_in().expect("catalog");
    let results = catalog.search("meter", Some(Category::Area), 100);

    assert!(results.iter().all(|unit| unit.category == Category::Area));
    assert!(results.iter().any(|unit| unit.id == "square_meter"));
    assert!(!results.iter().any(|unit| unit.id == "meter"));
}

#[test]
fn search_respects_requested_limit() {
    let catalog = UnitCatalog::built_in().expect("catalog");
    assert_eq!(catalog.search("", None, 3).len(), 3);
    assert!(catalog.search("", None, 0).is_empty());
}

#[test]
fn built_in_ids_are_unique_and_nonempty() {
    let catalog = UnitCatalog::built_in().expect("catalog");
    let mut ids = HashSet::new();

    for unit in catalog.all() {
        assert!(!unit.id.is_empty());
        assert!(ids.insert(unit.id.as_str()), "duplicate ID: {}", unit.id);
    }
    assert_eq!(ids.len(), catalog.len());
}
