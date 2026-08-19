# Contributing to UnitFlow

Thanks for improving UnitFlow.

## Development setup

1. Install a current stable Rust toolchain and Flutter SDK.
2. Clone the repository.
3. Configure the preferred commit identity when appropriate:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

4. Bootstrap Flutter platform folders when needed:

```bash
./tool/bootstrap_platforms.sh
```

On Windows PowerShell:

```powershell
./tool/bootstrap_platforms.ps1
```

## Before opening a pull request

Run the complete quality suite:

```bash
cargo fmt --manifest-path rust/Cargo.toml --check
cargo clippy --manifest-path rust/Cargo.toml --all-targets --all-features -- -D warnings
cargo test --manifest-path rust/Cargo.toml

cd app
flutter analyze
flutter test
```

## Change expectations

- Keep conversion factors traceable and documented.
- Add regression tests for conversion changes.
- Avoid network requirements for static unit conversions.
- Preserve accessibility labels and keyboard-friendly flows.
- Keep UI logic separate from conversion logic.
- Update `CHANGELOG.md` and `what_changed.md` for meaningful user-facing changes.
- Never commit secrets, private keys, tokens, or credentials.

## Commit style

Use focused commits with descriptive Conventional Commit-style subjects, for example:

- `feat(core): add pressure conversions`
- `fix(app): preserve input after unit swap`
- `test(core): cover affine temperature conversions`
- `docs: explain release checklist`

## Pull requests

Explain the problem, implementation, validation performed, screenshots for UI changes when useful, and any remaining limitations.
