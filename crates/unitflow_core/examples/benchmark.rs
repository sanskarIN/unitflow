use std::hint::black_box;
use std::time::Instant;

use rust_decimal::Decimal;
use unitflow_core::{ConversionRequest, Converter, RoundMode};

fn main() {
    let converter = Converter::with_built_in_catalog().expect("built-in catalog");
    let request = ConversionRequest {
        value: Decimal::new(123_456_789, 6),
        from_unit_id: "mile".to_owned(),
        to_unit_id: "kilometer".to_owned(),
        decimal_places: Some(12),
        round_mode: RoundMode::NearestEven,
    };

    const ITERATIONS: usize = 100_000;
    for _ in 0..1_000 {
        black_box(converter.convert(black_box(&request)).expect("warmup"));
    }

    let started = Instant::now();
    for _ in 0..ITERATIONS {
        black_box(converter.convert(black_box(&request)).expect("conversion"));
    }
    let elapsed = started.elapsed();
    let nanos_per_op = elapsed.as_nanos() / ITERATIONS as u128;

    println!("UnitFlow conversion micro-benchmark");
    println!("iterations: {ITERATIONS}");
    println!("elapsed: {elapsed:?}");
    println!("approx_ns_per_conversion: {nanos_per_op}");
    println!("note: this is a developer smoke benchmark, not a cross-machine guarantee");
}
