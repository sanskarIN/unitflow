# Testing Strategy

UnitFlow treats conversion correctness as the primary quality requirement.

## Rust core

Run:

```bash
cargo fmt --manifest-path rust/Cargo.toml --check
cargo clippy --manifest-path rust/Cargo.toml --all-targets --all-features -- -D warnings
cargo test --manifest-path rust/Cargo.toml
```

Core regression tests cover:

- exact decimal linear conversions
- affine temperature conversions
- decimal versus binary data units
- category mismatch rejection
- precision validation
- alias/description search
- custom affine-unit validation and round trips

Every new unit or formula change should include at least one known-value regression test.

## Flutter app

After bootstrapping platform folders:

```bash
cd app
flutter analyze
flutter test
```

Flutter tests cover adapter conversion behavior and a UI smoke test.

## Cross-engine parity

Until the Flutter frontend is directly connected to the Rust core, any conversion constant changed in one engine must be changed in the other. The native-bridge milestone will add shared golden fixtures so parity is mechanically verified.

## Manual checks

Before release, verify:

- keyboard and touch navigation
- light and dark system themes
- narrow phone and wide desktop layouts
- copy and batch conversion flows
- invalid numeric input
- unit search by name, symbol, and alias
- swap behavior
- precision/scientific notation controls
