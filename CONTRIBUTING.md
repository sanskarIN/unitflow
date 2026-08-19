# Contributing to UnitFlow

Thank you for helping improve UnitFlow.

## Development setup

1. Install stable Rust with `rustfmt` and `clippy`.
2. Install the stable Flutter SDK and platform prerequisites for your target.
3. Clone the repository.
4. Configure the requested project commit identity when contributing under the maintainer account:

```bash
git config user.name "Sanskar"
git config user.email "sanskarin@outlook.in"
```

5. Run the checks documented in `docs/testing.md` before opening a pull request.

## Branches and commits

Create a focused branch from `main`. Prefer Conventional Commits such as `feat:`, `fix:`, `test:`, `docs:`, `refactor:`, `perf:`, `build:`, `ci:`, and `chore:`. Keep each commit reviewable and avoid unrelated formatting churn.

## Pull requests

A pull request should:

- explain the problem and solution;
- include tests for changed behavior;
- update documentation when behavior or setup changes;
- pass Rust formatting, Clippy, tests, Flutter analysis, and Flutter tests;
- avoid secrets, real user data, generated signing material, or private endpoints;
- preserve accessibility and offline behavior.

## Code quality

- Keep domain rules outside UI widgets.
- Prefer immutable data and explicit dependencies.
- Validate external and user-defined input at boundaries.
- Never use floating-point arithmetic for authoritative conversion values when a decimal representation is appropriate.
- Add regression coverage for every bug fix.
- Keep user-facing errors safe and actionable.

## Adding units

When adding a unit:

1. choose the correct base unit for the category;
2. define the scale/offset relation to that base;
3. add symbols and useful aliases;
4. add conversion tests in both directions;
5. add at least one edge/precision test;
6. update educational/category documentation when relevant.

## Security reports

Do not open public issues for vulnerabilities. Follow `SECURITY.md`.

## Conduct

Participation is governed by `CODE_OF_CONDUCT.md`.
