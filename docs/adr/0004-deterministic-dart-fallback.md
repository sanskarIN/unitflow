# ADR 0004: Keep a deterministic Dart conversion fallback

- Status: Accepted
- Date: 2026-08-19

## Context

The product architecture uses Rust as the authoritative native domain core, but Flutter development and Web execution should not depend on a native FFI library. Generated bindings can also be temporarily unavailable during bootstrap or tooling maintenance.

A fallback that uses ordinary binary floating point would make parity failures hard to distinguish from representation differences.

## Decision

Maintain a pure-Dart exact-decimal conversion engine that mirrors the same catalog structure, affine formula, precision bounds, and deterministic formatting assumptions as the Rust core.

The fallback is a supported execution path for Web and test environments and a development compatibility path elsewhere. Native applications should move to the Rust bridge after bridge parity and packaging are proven.

The app must not silently switch engines in the middle of a calculation after a native failure. Engine selection occurs intentionally at startup or platform composition time.

## Consequences

Positive:

- widget and Web tests can execute without native compilation;
- the Flutter UI remains independently testable;
- bridge parity can be measured against deterministic expected behavior;
- native bridge downtime does not block all product development.

Costs:

- two implementations must remain aligned;
- catalog duplication needs tooling or generated snapshots before 1.0;
- parity tests become a release requirement.

## Follow-up

Before 1.0, add a reproducible catalog-generation or bridge-query workflow so the Flutter catalog cannot drift silently from the Rust source of truth.
