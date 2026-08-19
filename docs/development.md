# Development Guide

## Working principles

- Keep Rust as the authoritative conversion domain.
- Keep Flutter widgets thin and testable.
- Prefer small cohesive modules and explicit dependencies.
- Add tests with behavior changes.
- Update `what_changed.md` at meaningful checkpoints.
- Never bypass validation to make a UI path appear to work.

## Typical workflow

```bash
git switch -c feat/example
cargo fmt --all
cargo clippy --workspace --all-targets --all-features -- -D warnings
cargo test --workspace
cd apps/unitflow_app
flutter analyze
flutter test
```

Commit focused changes using Conventional Commits.

## Rust conventions

- Domain-facing numeric values use `rust_decimal::Decimal`.
- Parse user decimal text explicitly; do not silently fall back to zero.
- Unit definitions are immutable values after validation.
- Conversion functions return typed `Result` values.
- Avoid `unwrap()`/`expect()` in production paths unless an invariant is provably established at construction and documented.
- Catalog identifiers must remain stable once released because favorites/custom data may reference them.

## Flutter conventions

- Use `ThemeData`/design tokens instead of scattered literals.
- Externalize user-facing strings through a localization-ready layer.
- Provide semantic labels for non-text controls.
- Keep tap targets large enough for touch and expose keyboard focus on desktop/web.
- Treat loading, empty, validation, and failure states as first-class UI states.
- Avoid networking in static conversion flows.

## Adding a conversion category

1. Add a stable category identifier.
2. Choose/document the category base unit.
3. Add validated built-in unit definitions.
4. Add bidirectional conversion tests.
5. Add search aliases.
6. Add educational copy in the Flutter catalog layer.
7. Verify notation and batch conversion behavior.
8. Update documentation if the category introduces special constraints.

## Dependencies

Prefer mature, maintained dependencies with clear licensing. Avoid adding a package for trivial helpers that can be implemented clearly with the standard library. Lockfiles used by applications should be committed; library dependency ranges should remain intentional.

## Generated code

Generated bridge/platform code should be reproducible from checked-in configuration and source. Do not manually edit generated files unless the generator explicitly supports it.

## Logging

Use structured, bounded diagnostic fields. Redact data that could reveal user content, file contents, credentials, or future network tokens.

## Documentation

Public APIs and non-obvious invariants should be documented in source. Architecture-impacting decisions belong in `docs/adr/`.
