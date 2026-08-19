# UnitFlow documentation

This directory contains the engineering and maintainer documentation for UnitFlow. Start with the topic that matches the work you are doing rather than treating the docs as a linear book.

## Product and architecture

- [Architecture](architecture.md) — high-level Rust/Flutter ownership and data flow.
- [Unit model](unit-model.md) — category/unit semantics, stable IDs, scale/offset behavior.
- [Rust↔Flutter bridge](bridge.md) — bridge integration direction.
- [Bridge protocol](bridge-protocol.md) — stable decimal-string protocol and parity contract.
- [Local data format](data-format.md) — backup schema, migration, validation, and reset behavior.
- [Platform support](platform-support.md) — target/support terminology.
- [Native platform completion](native-platforms.md) — required scaffolding/build review per platform.

## Development

- [Setup](setup.md) — Git, Rust, Flutter, platform prerequisites, and troubleshooting.
- [Testing](testing.md) — quality gates and regression strategy.
- [Performance](performance.md) — measurement policy and benchmark entry point.
- [Localization](localization.md) — ARB/gen-l10n workflow and locale-review rules.
- [Keyboard shortcuts](keyboard-shortcuts.md) — desktop navigation shortcuts and accessibility expectations.
- [Diagnostics](diagnostics.md) — privacy-preserving structured debug logging.
- [Dependency maintenance](dependencies.md) — dependency review/update policy.

## Security and operations

- [Threat model](threat-model.md) — trust boundaries and abuse/failure cases.
- [Release guide](release.md) — evidence-based release procedure.
- [Release checklist](release-checklist.md) — concrete release-candidate gates.
- [GitHub maintenance](github-maintenance.md) — repository settings that are not fully represented by committed files.

## Architecture decision records

- [ADR 0001: Rust core with Flutter UI](adr/0001-rust-core-flutter-ui.md)
- [ADR 0002: Exact decimal arithmetic](adr/0002-exact-decimal-arithmetic.md)
- [ADR 0003: Local-first persistence](adr/0003-local-first-persistence.md)
- [ADR 0004: Deterministic Dart fallback](adr/0004-deterministic-dart-fallback.md)

## Repository-level policy files

The repository root also contains:

- [`README.md`](../README.md)
- [`ROADMAP.md`](../ROADMAP.md)
- [`CHANGELOG.md`](../CHANGELOG.md)
- [`CONTRIBUTING.md`](../CONTRIBUTING.md)
- [`SECURITY.md`](../SECURITY.md)
- [`PRIVACY.md`](../PRIVACY.md)
- [`SUPPORT.md`](../SUPPORT.md)
- [`CODE_OF_CONDUCT.md`](../CODE_OF_CONDUCT.md)
- [`what_changed.md`](../what_changed.md)

## Automated documentation checks

Run from the repository root:

```bash
python3 scripts/check_markdown_links.py
python3 scripts/check_release_consistency.py
```

The first command validates repository-local Markdown targets. The second guards version/schema/protocol declarations against drift. Both are part of CI/release verification.
