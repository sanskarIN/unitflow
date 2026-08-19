# Platform support matrix

UnitFlow is designed as a Flutter client around a portable Rust conversion core. Platform claims are separated into design targets and verified release targets.

| Platform | Product target | Repository status | Release requirement |
| --- | --- | --- | --- |
| Android | Primary | Flutter application code is platform-neutral; native project validation still required | Build, install, conversion, persistence, backup, accessibility smoke test |
| Windows | Supported target | Adaptive desktop navigation and keyboard shortcuts implemented | Native build and installer/package smoke test |
| Linux | Supported target | Adaptive desktop UI implemented | Native build on supported runner/distribution |
| macOS | Supported target | Adaptive desktop UI implemented | Native build and keyboard/accessibility smoke test |
| Web | Supported target | Deterministic Dart conversion fallback supports browser execution | Web build, browser smoke test, persistence review |
| iOS | Ready target | Flutter UI is portable; native signing/project validation still required | Build on macOS, simulator/device smoke test, signing documentation |

## Meaning of statuses

`Product target` means the architecture intentionally supports the platform. It does not mean a release artifact has been produced or tested.

`Repository status` describes what exists in source control. UnitFlow must not claim a platform is release-verified until the corresponding native build and smoke checks have actually passed.

## Shared acceptance criteria

Every release-supported platform should verify:

- launch without an account or network connection;
- exact common conversions and temperature conversions;
- locale-aware decimal entry;
- favorites, pinned pairs, recents, and settings persistence;
- custom-unit validation;
- backup export/import validation;
- batch table behavior;
- keyboard navigation where a hardware keyboard is expected;
- screen-reader labels and large-text behavior;
- no unexpected outbound network traffic in the offline-only feature set.

## Native project generation

The current repository intentionally keeps domain and Flutter feature code independent of generated platform scaffolding. Before platform packaging is declared complete, native project files should be generated with the pinned release Flutter SDK, reviewed, committed, and tested. Generated files must not be accepted blindly when they alter minimum OS versions, permissions, signing behavior, or network capabilities.

## Rust bridge

The final native bridge must preserve the Dart fallback as a deterministic compatibility path for web/tests and bridge-unavailable environments. Native release validation must include parity tests between bridge and fallback results for representative and boundary values.
