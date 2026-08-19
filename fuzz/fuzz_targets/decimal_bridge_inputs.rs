#![no_main]

use std::str::FromStr;

use libfuzzer_sys::fuzz_target;
use rust_decimal::Decimal;
use unitflow_core::{format_decimal, Notation, RoundMode};

fuzz_target!(|data: &[u8]| {
    let Ok(input) = std::str::from_utf8(data) else {
        return;
    };
    let Ok(value) = Decimal::from_str(input.trim()) else {
        return;
    };

    for notation in [Notation::Plain, Notation::Scientific, Notation::Engineering] {
        let _ = format_decimal(
            value,
            notation,
            Some(12),
            RoundMode::NearestEven,
        );
    }
});
