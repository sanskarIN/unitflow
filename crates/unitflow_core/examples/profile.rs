use std::hint::black_box;
use std::str::FromStr;
use std::time::{Duration, Instant};

use rust_decimal::Decimal;
use unitflow_core::{Category, ConversionRequest, Converter, RoundMode, UnitCatalog};

const LOOKUP_ITERATIONS: usize = 200_000;
const SEARCH_ITERATIONS: usize = 20_000;
const CONVERSION_ITERATIONS: usize = 20_000;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let catalog = UnitCatalog::built_in()?;
    let converter = Converter::new(catalog.clone());
    let input = Decimal::from_str("1234567.890123")?;

    let lookup = measure(|| {
        for _ in 0..LOOKUP_ITERATIONS {
            black_box(catalog.get(black_box("kilometer")));
        }
    });

    let search = measure(|| {
        for _ in 0..SEARCH_ITERATIONS {
            black_box(catalog.search(
                black_box("meter"),
                black_box(Some(Category::Length)),
                black_box(20),
            ));
        }
    });

    let targets = catalog
        .units_for_category(Category::Length)
        .into_iter()
        .map(|unit| unit.id.clone())
        .collect::<Vec<_>>();
    let batch = measure(|| {
        for _ in 0..CONVERSION_ITERATIONS {
            black_box(
                converter
                    .batch_convert(
                        black_box(input),
                        black_box("meter"),
                        black_box(&targets),
                        black_box(Some(12)),
                        black_box(RoundMode::NearestEven),
                    )
                    .expect("built-in batch conversion must succeed"),
            );
        }
    });

    let single = measure(|| {
        for _ in 0..CONVERSION_ITERATIONS {
            black_box(
                converter
                    .convert(&ConversionRequest {
                        value: black_box(input),
                        from_unit_id: "meter".to_owned(),
                        to_unit_id: "mile".to_owned(),
                        decimal_places: Some(12),
                        round_mode: RoundMode::NearestEven,
                    })
                    .expect("built-in conversion must succeed"),
            );
        }
    });

    println!("UnitFlow core profiling harness (release builds recommended)");
    report("direct lookup", LOOKUP_ITERATIONS, lookup);
    report("catalog search", SEARCH_ITERATIONS, search);
    report("single conversion", CONVERSION_ITERATIONS, single);
    report("length batch conversion", CONVERSION_ITERATIONS, batch);
    println!("catalog_units={}", catalog.len());
    println!("length_batch_targets={}", targets.len());

    Ok(())
}

fn measure(operation: impl FnOnce()) -> Duration {
    let started = Instant::now();
    operation();
    started.elapsed()
}

fn report(label: &str, iterations: usize, elapsed: Duration) {
    let total_ns = elapsed.as_nanos();
    let ns_per_iteration = if iterations == 0 {
        0
    } else {
        total_ns / iterations as u128
    };
    println!(
        "{label}: iterations={iterations} elapsed_ms={} ns_per_iteration={ns_per_iteration}",
        elapsed.as_millis()
    );
}
