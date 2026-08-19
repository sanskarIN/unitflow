use std::{env, process};

use unitflow_core::{convert_str, ConversionOptions, RoundingMode, UNITS};

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    if args.first().is_some_and(|arg| arg == "--list") {
        for unit in UNITS {
            println!("{}\t{}\t{}\t{}", unit.category.label(), unit.id, unit.symbol, unit.name);
        }
        return;
    }

    if args.len() < 3 || args.len() > 4 {
        eprintln!("Usage: unitflow <value> <from-unit> <to-unit> [decimal-places]");
        eprintln!("       unitflow --list");
        process::exit(2);
    }

    let decimal_places = args
        .get(3)
        .map_or(Ok(12), |value| value.parse::<u32>())
        .unwrap_or_else(|_| {
            eprintln!("decimal-places must be a non-negative integer");
            process::exit(2);
        });

    let options = ConversionOptions {
        decimal_places,
        rounding: RoundingMode::HalfEven,
    };

    match convert_str(&args[0], &args[1], &args[2], options) {
        Ok(result) => println!("{}", result.value.normalize()),
        Err(error) => {
            eprintln!("{error}");
            process::exit(1);
        }
    }
}
