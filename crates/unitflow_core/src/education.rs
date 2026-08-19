use crate::model::Category;

/// Stable educational copy that can be surfaced by any UnitFlow client.
///
/// The guide intentionally contains short, offline-safe explanations rather than
/// network-fetched articles so that the core learning experience is deterministic.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct CategoryGuide {
    pub category: Category,
    pub title: &'static str,
    pub summary: &'static str,
    pub base_unit_id: &'static str,
    pub example: &'static str,
}

/// Returns concise educational metadata for a conversion category.
#[must_use]
pub const fn category_guide(category: Category) -> CategoryGuide {
    match category {
        Category::Length => CategoryGuide {
            category,
            title: "Length",
            summary: "Length measures distance between two points.",
            base_unit_id: "meter",
            example: "1 kilometer = 1,000 meters.",
        },
        Category::Area => CategoryGuide {
            category,
            title: "Area",
            summary: "Area measures the size of a two-dimensional surface.",
            base_unit_id: "square_meter",
            example: "1 hectare = 10,000 square meters.",
        },
        Category::Volume => CategoryGuide {
            category,
            title: "Volume",
            summary: "Volume measures the amount of three-dimensional space occupied.",
            base_unit_id: "liter",
            example: "1 liter = 1,000 milliliters.",
        },
        Category::Mass => CategoryGuide {
            category,
            title: "Mass",
            summary: "Mass measures the amount of matter in an object.",
            base_unit_id: "kilogram",
            example: "1 kilogram = 1,000 grams.",
        },
        Category::Speed => CategoryGuide {
            category,
            title: "Speed",
            summary: "Speed measures distance traveled per unit of time.",
            base_unit_id: "meter_per_second",
            example: "1 meter per second = 3.6 kilometers per hour.",
        },
        Category::Pressure => CategoryGuide {
            category,
            title: "Pressure",
            summary: "Pressure measures force applied over an area.",
            base_unit_id: "pascal",
            example: "1 bar = 100,000 pascals.",
        },
        Category::Energy => CategoryGuide {
            category,
            title: "Energy",
            summary: "Energy measures the capacity to perform work or transfer heat.",
            base_unit_id: "joule",
            example: "1 kilojoule = 1,000 joules.",
        },
        Category::Power => CategoryGuide {
            category,
            title: "Power",
            summary: "Power measures the rate at which energy is transferred or used.",
            base_unit_id: "watt",
            example: "1 kilowatt = 1,000 watts.",
        },
        Category::Angle => CategoryGuide {
            category,
            title: "Angle",
            summary: "Angle measures rotation or separation between two directions.",
            base_unit_id: "radian",
            example: "A full turn is 360 degrees.",
        },
        Category::DataSize => CategoryGuide {
            category,
            title: "Data size",
            summary: "Data size measures digital information storage or transfer quantities.",
            base_unit_id: "byte",
            example: "1 byte = 8 bits.",
        },
        Category::Frequency => CategoryGuide {
            category,
            title: "Frequency",
            summary: "Frequency measures how often a repeating event occurs per second.",
            base_unit_id: "hertz",
            example: "1 kilohertz = 1,000 hertz.",
        },
        Category::Time => CategoryGuide {
            category,
            title: "Time",
            summary: "Time measures duration or intervals between events.",
            base_unit_id: "second",
            example: "1 hour = 3,600 seconds.",
        },
        Category::Temperature => CategoryGuide {
            category,
            title: "Temperature",
            summary: "Temperature describes how hot or cold a system is on a defined scale.",
            base_unit_id: "kelvin",
            example: "0 degrees Celsius = 273.15 kelvin.",
        },
    }
}
