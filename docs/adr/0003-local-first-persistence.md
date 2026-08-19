# ADR 0003: Keep user state local by default

- Status: Accepted
- Date: 2026-08-19

## Context

UnitFlow is intended to be useful immediately without registration or connectivity. Favorites, custom units, history, pinned pairs, and display preferences do not inherently require a server.

Remote storage would add privacy, authentication, availability, and data-retention concerns to a utility that can otherwise operate entirely on-device.

## Decision

User state is persisted locally through an abstract repository. The initial Flutter implementation uses Shared Preferences for the versioned JSON payload and also provides an in-memory repository for deterministic tests.

Backups are explicit user-driven JSON export/import operations. UnitFlow does not silently upload local conversion history or custom units.

Any future sync feature must be opt-in, separated from the core local repository, documented as an online-data boundary, and designed so the application remains fully useful without an account.

## Consequences

Positive:

- offline operation is the default rather than a degraded mode;
- the privacy model is simpler and easier to explain;
- tests can use the same persistence contract without platform storage;
- server outages cannot block conversion or access to local units.

Costs:

- users are responsible for backups when moving devices until optional sync exists;
- local platform storage limitations must be handled carefully;
- conflict resolution is deferred rather than hidden inside the initial architecture.

## Rejected alternatives

### Mandatory account and cloud database

Rejected because it creates unnecessary collection and availability dependencies for core conversion workflows.

### Unversioned key-per-setting storage

Rejected because backup/import, validation, and migration become harder to reason about as the product grows.
