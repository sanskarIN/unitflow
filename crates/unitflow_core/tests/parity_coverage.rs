use std::collections::HashSet;

use serde::Deserialize;
use unitflow_core::{Category, UnitCatalog};

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Vector {
    name: String,
    from: String,
    to: String,
    rounding_mode: String,
}

#[test]
fn shared_vectors_cover_every_category_and_rounding_mode() {
    let vectors: Vec<Vector> = serde_json::from_str(include_str!(
        "../../../test_vectors/conversions.json"
    ))
    .expect("shared conversion vectors must be valid JSON");
    let catalog = UnitCatalog::built_in().expect("built-in catalog must validate");

    let mut categories = HashSet::new();
    let mut round_modes = HashSet::new();
    for vector in &vectors {
        let from = catalog
            .get(&vector.from)
            .unwrap_or_else(|| panic!("{} references unknown source {}", vector.name, vector.from));
        let to = catalog
            .get(&vector.to)
            .unwrap_or_else(|| panic!("{} references unknown target {}", vector.name, vector.to));
        assert_eq!(
            from.category, to.category,
            "{} crosses categories in parity data",
            vector.name
        );
        categories.insert(from.category);
        round_modes.insert(vector.rounding_mode.as_str());
    }

    for category in Category::ALL {
        assert!(
            categories.contains(&category),
            "shared conversion vectors do not cover category {category}"
        );
    }

    for round_mode in [
        "nearestEven",
        "halfAwayFromZero",
        "towardZero",
        "awayFromZero",
        "floor",
        "ceiling",
    ] {
        assert!(
            round_modes.contains(round_mode),
            "shared conversion vectors do not cover rounding mode {round_mode}"
        );
    }
}
