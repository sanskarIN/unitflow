# Development Guide

## Working principles

- Keep Rust as the authoritative native conversion domain.
- Keep Flutter widgets thin and testable.
- Prefer small cohesive modules and explicit dependencies.
- Add regression tests with behavior changes and confirmed bug fixes.
- Update `what_changed.md` at meaningful continuation/release checkpoints.
- Never bypass validation to make a UI path appear to work.
- Keep test adapters subject to the same externally relevant validation bounds as production adapters.
- Distinguish generated scaffold compatibility from reviewed native release evidence.

## Typical workflow

Create a focused branch:

```bash
git switch -c feat/example
```

Run the complete repository verification from the repository root whenever the required toolchains are available:

```bash
bash scripts/verify.sh
```

or on PowerShell:

```powershell
./scripts/verify.ps1
```

The verification scripts test the Python validators, run repository integrity checks, then run the Rust and Flutter source quality gates. See `docs/testing.md` for individual commands and `docs/release-checklist.md` for release-only platform/manual checks.

Commit focused changes using Conventional Commits.

## Rust conventions

- Domain-facing numeric values use `rust_decimal::Decimal`.
- Parse user decimal text explicitly; do not silently fall back to zero.
- Unit definitions are immutable values after validation.
- Conversion functions return typed `Result` values.
- Avoid `unwrap()`/`expect()` in production paths unless an invariant is provably established at construction and documented.
- Catalog identifiers must remain stable once released because favorites/custom data may reference them.
- Preserve exact/checked arithmetic and explicit rounding semantics across bridge/API changes.

## Flutter conventions

- Use `ThemeData`/design tokens instead of scattered visual literals.
- Externalize user-facing strings through generated localization resources.
- Provide semantic labels for non-text controls.
- Keep tap targets large enough for touch and expose keyboard focus on desktop/web.
- Treat loading, empty, validation, and failure states as first-class UI states.
- Avoid networking in static conversion flows.
- Preserve locale-formatted original input text where product history intentionally stores user-entered text.
- Serialize persistence mutations that could otherwise race, especially reset/import/save paths.

## Adding a conversion category

1. Add a stable category identifier.
2. Choose/document the category base unit.
3. Add validated built-in unit definitions in the Rust catalog and the temporary Dart compatibility catalog while parity is required.
4. Add bidirectional conversion/invariant tests.
5. Add search aliases.
6. Add educational copy.
7. Verify notation and batch conversion behavior.
8. Update the bridge parity fixture when the protocol/catalog contract requires it.
9. Update documentation if the category introduces special constraints.

## Persistence changes

Persisted state is versioned. For any stored-data change:

1. decide whether `schemaVersion` must change;
2. preserve or explicitly migrate supported older payloads;
3. bound untrusted imported collections/strings before expensive processing;
4. validate complete imported state and catalog references before replacing active state;
5. add migration, rejection, and atomicity regression tests;
6. update `docs/data-format.md` and `scripts/check_release_consistency.py` when declarations change.

Never make the in-memory test repository more permissive than the production repository for externally relevant import validation.

## Dependencies

Prefer mature, maintained dependencies with clear licensing. Avoid adding a package for trivial helpers that can be implemented clearly with the standard library. Review Dependabot pull requests exactly as you would manual dependency updates; automated discovery is not approval.

See `docs/dependencies.md`.

## Generated code and platform projects

Generated localization/bridge/platform code should be reproducible from checked-in configuration and source. Do not manually edit generated files unless the generator explicitly supports it.

The generated-platform smoke workflow intentionally creates temporary native projects for compatibility evidence. When a native project is ready for release, generate it deliberately, review identifiers/permissions/entitlements/settings, commit it, then change CI to build the committed project directly for that target.

## Logging

Use structured, bounded diagnostic fields. Redact data that could reveal user content, file contents, credentials, or future network tokens. Do not log complete backup payloads or conversion history simply to make a failure easier to reproduce.

## Documentation

Public APIs and non-obvious invariants should be documented in source. Architecture-impacting decisions belong in `docs/adr/`.

Before broad changes or release work, run:

```bash
python3 scripts/check_markdown_links.py
python3 scripts/check_release_consistency.py
python3 scripts/check_repository_hygiene.py
```

These checks prevent documentation/version/schema/protocol drift from being silently accepted by otherwise unrelated code tests.
