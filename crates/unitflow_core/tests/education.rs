use unitflow_core::{category_guide, Category, UnitCatalog};

#[test]
fn every_category_guide_points_to_a_real_base_unit() {
    let catalog = UnitCatalog::built_in().expect("catalog");

    for category in Category::ALL {
        let guide = category_guide(category);
        let base = catalog.get(guide.base_unit_id).expect("guide base unit");
        assert_eq!(guide.category, category);
        assert_eq!(base.category, category);
        assert!(!guide.title.is_empty());
        assert!(!guide.summary.is_empty());
        assert!(!guide.example.is_empty());
    }
}

#[test]
fn guide_base_ids_match_category_contract() {
    for category in Category::ALL {
        assert_eq!(category_guide(category).base_unit_id, category.base_unit_id());
    }
}
