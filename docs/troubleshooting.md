# Troubleshooting

## Rust toolchain not found

If `cargo` or `rustc` is unavailable, install stable Rust with `rustup`, restart the shell, and verify both commands are on `PATH`.

## Clippy or rustfmt missing

```bash
rustup component add clippy rustfmt
```

## Flutter command not found

Add the Flutter SDK `bin` directory to `PATH`, restart the terminal, and run:

```bash
flutter doctor -v
```

## Flutter desktop target unavailable

Enable the intended platform and install its native prerequisites. Desktop builds require platform-specific compilers/libraries; `flutter doctor -v` is the first diagnostic source.

## Android build problems

Check:

- Android SDK/JDK compatibility with the installed Flutter channel;
- accepted SDK licenses;
- `android/local.properties` paths (local only; do not commit machine-specific paths);
- available disk space;
- Gradle error output above the final failure line.

## Conversion seems incorrect

Before reporting a bug:

1. record source/target units and exact input;
2. note notation/rounding settings;
3. compare with the unit metadata/factor in the Rust catalog;
4. add or run a focused Rust regression test.

Do not “fix” a display mismatch by changing a conversion constant without verifying the unit definition and base relation.

## Decimal input rejected

Locale-aware parsing distinguishes decimal separators from grouping separators. Include the active locale and exact input in bug reports. The parser should reject ambiguous or malformed values rather than silently changing meaning.

## CI differs from local results

Compare Rust/Flutter versions and lockfiles first. CI configuration is the reproducibility source for required checks. Avoid solving a mismatch by disabling a failing check.

## Clean rebuild

```bash
cargo clean
cd apps/unitflow_app
flutter clean
flutter pub get
flutter analyze
flutter test
```

## Reporting unresolved problems

See `SUPPORT.md`. Remove secrets and personal data from logs before sharing them.
