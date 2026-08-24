# Native bridge protocol

This document defines the stable application-level contract that the generated Rust↔Flutter binding must preserve. It remains intentionally separate from the binding generator so UnitFlow can change generator/tooling details without silently changing decimal, catalog, or runtime-session semantics.

## Protocol version

Current protocol version: `1`.

The bridge protocol version is independent of the application version and local backup schema version.

Current required capabilities: `convert`, `batchConvert`, `canonicalDecimalText`.

Current maximum batch targets: `256`.

Current maximum custom units: `200`.

A backend is compatible only when it reports the exact supported protocol version and contains every required capability. It may report additional forward-compatible capabilities, but removing or renaming a required capability is a breaking bridge change and must be reviewed together with protocol versioning.

Catalog synchronization is currently an optional adapter extension rather than a required protocol-v1 startup capability. If persisted custom units exist and the selected adapter cannot synchronize them, startup fails closed to the Dart backend with `catalog_sync_unsupported`; UnitFlow never exposes a native session with a divergent user catalog.

## Decimal rule

**All conversion values, custom-unit scales, and custom-unit offsets cross the bridge as canonical base-10 text.**

Do not expose user values, scales, offsets, or conversion outputs as `double`/`f64` DTO fields. The Rust side parses canonical text into its decimal domain representation and returns canonical decimal text.

## Unit identifier rule

Bridge unit identifiers use stable catalog IDs rather than localized names or symbols. Boundary identifiers are limited to 1–64 ASCII lowercase letters, digits, `_`, and `-`. Malformed identifiers are rejected before catalog lookup and surfaced through the same safe `unknown_unit` contract without echoing the supplied identifier.

## Conversion request

Logical fields:

```text
value: string
fromUnitId: string
toUnitId: string
decimalPlaces: integer or null
roundMode: enum/string
```

Supported rounding identifiers:

- `nearestEven`
- `halfAwayFromZero`
- `towardZero`
- `awayFromZero`
- `floor`
- `ceiling`

## Batch conversion request

Logical fields:

```text
value: string
fromUnitId: string
targetUnitIds: list<string>
decimalPlaces: integer or null
roundMode: enum/string
```

Target order is semantically significant and must be preserved in the returned result list. One request may contain at most `256` targets. Oversized native requests fail with `invalid_batch` before conversion work begins. An empty target list is valid and returns an empty result list.

## Custom-unit catalog snapshot

The Flutter persistence boundary and the native bridge share the same `200` custom-unit ceiling. The Rust bridge accepts a complete replacement snapshot rather than individual mutation events.

Each custom-unit payload contains:

```text
id: string
category: stable category identifier
name: string
symbol: string
aliases: list<string>
description: string
scale: canonical decimal string
offset: canonical decimal string
```

The Rust service validates every incoming definition, rebuilds the merged built-in + custom catalog, and replaces the active converter only after the entire snapshot is valid. A failed snapshot therefore leaves the previously active native catalog untouched. A successful replacement also removes stale custom units that are no longer present in the supplied snapshot.

`ConversionSession.bootstrap()` synchronizes non-empty persisted custom-unit state before returning a native session. `AppController` creates a fresh conversion session whenever a catalog-changing operation occurs. During that refresh it immediately exposes a new Dart fallback session built from the new catalog, so an older native session can never continue processing against stale custom-unit definitions. Native routing is promoted only after the new bridge instance and catalog snapshot validate.

## Conversion response

Logical fields:

```text
input: string
output: string
fromUnitId: string
toUnitId: string
```

The response echoes the normalized input and stable IDs used by the native conversion operation. Flutter resolves presentation metadata through its active synchronized catalog.

Batch responses use the same response shape for each target and preserve request target order.

Flutter does not trust a typed generated response merely because it has already been constructed. The application boundary reparses response fields through `NativeBridgeConversionResponse.fromMap`, enforcing canonical decimal text and stable unit-ID syntax before accepting the result. It then verifies that echoed input/source/target metadata matches the originating request. Batch responses additionally must have the same cardinality and target ordering as the request.

## Failure contract

Binding-specific exceptions must be converted into a small safe application error contract. Rust/domain-oriented stable codes include:

- `invalid_decimal`
- `unknown_unit`
- `category_mismatch`
- `invalid_precision`
- `invalid_rounding_mode`
- `invalid_batch`
- `invalid_catalog_snapshot`
- `catalog_invalid`
- `conversion_failed`
- `bridge_unavailable`
- `protocol_mismatch`
- `capability_mismatch`

User-facing UI must not display raw Rust panic text, backtraces, file paths, arbitrary imported content, or generated-binding internals.

The current Rust source service maps domain failures into safe codes/messages without echoing untrusted unit identifiers. Typed Rust DTOs make an invalid rounding identifier a deserialization/binding-layer concern; generated adapters must normalize that case to `invalid_rounding_mode`.

The Flutter application boundary additionally classifies failures that can occur around loading/generated adapters:

- `native_load_failed` — loading or constructing the native adapter failed before session selection;
- `native_unavailable` — no native bridge is available for the current target/session;
- `metadata_invalid` — startup metadata failed bounded structural validation;
- `startup_failed` — another adapter startup failure occurred before selection;
- `invalid_response` — a returned response failed Flutter-side structural/canonical validation;
- `response_mismatch` — response identity, cardinality, or target ordering does not match the request;
- `backend_failure` — an unexpected adapter/backend execution failure occurred after native selection;
- `catalog_sync_unsupported` — custom units exist but the selected native adapter cannot synchronize them;
- `catalog_sync_failed` — the adapter failed while replacing the native custom-unit snapshot;
- `invalid_catalog_snapshot` — a supplied custom-unit snapshot violates application bounds or structure.

These Flutter-side codes are application-boundary diagnostics unless explicitly added to a generated wire contract later. Any such wire-contract expansion must be reviewed with protocol versioning.

## Startup negotiation

A native backend must expose bounded, validated startup metadata:

```text
protocolVersion: integer
backendId: string
capabilities: list<string>
```

Protocol version `1` currently requires:

- `convert` — single conversion requests are supported;
- `batchConvert` — ordered, resource-bounded batch conversion requests are supported;
- `canonicalDecimalText` — decimal inputs and outputs use canonical base-10 text.

Flutter parses startup metadata before native routing. Backend and capability identifiers are bounded stable diagnostic tokens; malformed payloads are rejected rather than trusted. `NativeBridgeInfo.toMap()` produces deterministic capability ordering, and `validatedCopy()` ensures directly constructed metadata objects are revalidated through the same parsing boundary before selection.

`ConversionSession.bootstrap()` invokes a supplied native bridge loader exactly once per session. A loader failure selects Dart with `native_load_failed`; a null result selects Dart with `native_unavailable`. `ConversionSession.select()` then performs structural metadata validation followed by protocol/capability validation. Protocol mismatch produces `protocol_mismatch`; a missing required capability produces `capability_mismatch`; malformed metadata selects Dart with `metadata_invalid`; another startup-adapter failure selects Dart with `startup_failed`.

When persisted custom units are present, bootstrap then requires catalog synchronization before exposing native routing. Synchronization failure selects Dart before the session begins. Once a native backend is returned, the selected engine remains stable for that session and runtime failures do not trigger a silent fallback.

## Runtime selection and publication boundary

The runtime router is `apps/unitflow_app/lib/features/converter/domain/conversion_session.dart`. `AppController` owns the active session, and `ConverterController` routes both single and batch presentation work through it.

Current guarantees are:

1. a candidate native bridge is loaded at most once during one session bootstrap;
2. protocol and capability compatibility are checked before native routing;
3. non-empty custom-unit state is synchronized before native startup succeeds;
4. catalog-changing app operations invalidate the previous native session and create a fresh session;
5. request DTOs are validated before native invocation;
6. adapter exceptions/errors are contained at startup, catalog-sync, single-conversion, and batch-conversion boundaries;
7. bridge-reported `NativeBridgeFailure` values propagate without changing the selected engine;
8. native response fields are structurally revalidated after invocation;
9. response identity/order/cardinality is validated before publishing typed conversion results;
10. no native runtime failure causes a mid-session engine switch.

The current presentation migration preserves the previous synchronous UI contract by calculating an exact Dart preview immediately. If a native session is selected, the asynchronous native completion becomes authoritative. A native failure removes that preview and publishes a safe error rather than silently treating the preview as a successful fallback result.

## Asynchronous publication rule

A slower older conversion must never overwrite state derived from newer input, category, source unit, target unit, rounding settings, locale, or catalog state.

`apps/unitflow_app/lib/features/converter/domain/latest_conversion_request.dart` provides a generation-token gate. `ConverterController` now applies independent gates to native single and batch operations. Every recompute invalidates previous in-flight work; only the newest live request may publish success or failure. Controller disposal invalidates all pending publication.

This race-safety rule is covered both by unit tests of the coordinator and by a controller regression where a newer native result completes before an older request and the late older completion is ignored.

## Source contracts

`apps/unitflow_app/lib/core/bridge/native_conversion_bridge.dart` contains the Flutter DTO/interface contract, custom-unit snapshot DTO, and optional `NativeCatalogSyncBridge` extension.

`apps/unitflow_app/lib/features/converter/domain/conversion_session.dart` contains one-shot loader/bootstrap selection, immutable session backend state, catalog synchronization, request/response validation, safe failure classification, and no-mid-session-fallback behavior.

`apps/unitflow_app/lib/app/app_controller.dart` owns and refreshes the active session when catalog authority changes.

`apps/unitflow_app/lib/features/converter/presentation/converter_controller.dart` performs synchronous exact previews and session-routed asynchronous single/batch publication with stale-result suppression.

`crates/unitflow_core/src/bridge.rs` contains the Rust protocol service. It exposes protocol version `1`, backend metadata, the stable capability set, generator-friendly conversion/batch/custom-unit DTOs, the shared `256` batch ceiling, the shared `200` custom-unit ceiling, bridge unit-ID validation, canonical decimal validation, atomic custom-catalog replacement, safe failure mapping, and a long-lived conversion service.

`scripts/check_release_consistency.py` prevents application versions, data schema, bridge protocol declarations, capabilities, batch bounds, and custom-unit bounds from drifting between documentation, fixtures, Rust source, Flutter bridge source, and persistence boundaries. `scripts/check_conversion_session_contract.py` separately locks runtime-selection and race-safety source semantics plus verification wiring.

These source contracts are prerequisites for generated bindings. Their presence does not prove that a production binding has been generated, loaded, packaged, or validated on any native platform.

## Remaining generated/native binding work

The production integration still must:

1. expose the long-lived Rust `BridgeService` through a reviewed binding generator or FFI layer;
2. implement a production adapter for `NativeConversionBridge` and `NativeCatalogSyncBridge` without weakening DTO validation;
3. expose `BridgeService::info()`, `convert()`, `batch_convert()`, and custom-catalog replacement through that adapter;
4. provide platform-specific native-library loading consumed once by `ConversionSession.bootstrap()`;
5. package the native library for every verified native platform;
6. prove Rust/Dart parity through the generated boundary rather than only source-level service tests;
7. keep Web on the deterministic Dart path unless a separately verified Web Rust backend is introduced.

## Generated-boundary parity suite

At minimum compare Rust and Dart behavior for:

- zero and negative inputs;
- exact SI scaling;
- temperature affine conversions;
- very small and large decimal magnitudes within supported bounds;
- all rounding modes at tie boundaries;
- custom multiplicative and affine units;
- custom-catalog replacement, stale-unit removal, malformed snapshots, and the 200-unit limit;
- batch conversion ordering and exact decimal text;
- empty, maximum-size, and oversized batch requests;
- invalid IDs, category mismatches, and malformed decimal text;
- startup protocol mismatch, missing required capability, malformed metadata, missing bridge, and loader failure behavior;
- malformed native responses, response mismatches, and unexpected generated-adapter failures;
- stale asynchronous single and batch completion suppression.

A native bridge is not release-ready until those generated-boundary parity tests and per-platform native packaging checks pass on the release candidate commit.
