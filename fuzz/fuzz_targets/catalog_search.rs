#![no_main]

use libfuzzer_sys::fuzz_target;
use unitflow_core::UnitCatalog;

fuzz_target!(|data: &[u8]| {
    let Ok(query) = std::str::from_utf8(data) else {
        return;
    };
    let catalog = UnitCatalog::built_in().expect("built-in catalog must stay valid");
    let _ = catalog.search(query, None, 64);
});
