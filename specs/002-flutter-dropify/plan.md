# Implementation Plan: Dropify Flutter Universal Dropdown Package

**Branch**: `002-flutter-dropify` | **Date**: 2026-04-26 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/002-flutter-dropify/spec.md`, refined by `/ai_specs/001-flutter_dropify.md`

## Summary

Build `dropify_flutter` v0.1.0 as a universal Flutter dropdown package with three layered abstractions: `RawDropify` as the unstyled core, specialized raw widgets for static, async, and paginated data, and themed Material 3 widgets backed by `DropifyThemeData`. The implementation will preserve one public import, value-based selection identity, built-in form validation, async cancellation and stale-result protection, caller-owned pagination, configurable visible copy, stable semantic keys, and an example app that demonstrates all six raw/themed variants.

## Technical Context

**Language/Version**: Dart 3.10.3 and Flutter 3.38.4 locally; package constraints remain `sdk: ^3.10.3` and `flutter: ">=3.27.0"` from `pubspec.yaml`.
**Primary Dependencies**: Flutter `widgets`/`material`, `infinite_scroll_pagination: ^5.1.1`, `flutter_test`, `fake_async`, and `flutter_lints`.
**Storage**: No persistence. Static data is in-memory; async search uses an instance-lifetime per-query cache by default; paginated data is caller-owned `PagingState`/`DropifyPagingState`.
**Testing**: `dart format`, `dart analyze`, `flutter test`, focused example tests, golden tests for visual regressions, and example app compilation before release.
**Target Platform**: Flutter package usable from Android, iOS, web, macOS, Windows, and Linux applications; example app demonstrates cross-platform behavior.
**Project Type**: Flutter package with an example Flutter app.
**Performance Goals**: Open/close and selection should feel immediate; static lists larger than 50 entries use builder-based visible row presentation; async search debounces at 300 ms by default; stale async and paging results never render as current data; overlays remain constrained and overflow-free on narrow screens.
**Constraints**: Public API is additive for v0.1.0, single import entry point, Material 3 themed defaults, keyboard and screen-reader support, configurable built-in visible copy, stable semantic keys, zero analyzer issues, and no breaking changes within a semver minor version after release.
**Scale/Scope**: Entire first package surface: core value/controller/theme primitives, six consumer-facing dropdown variants, internal anchor/panel/search/focus helpers, example pages, widget tests, async/paging tests, accessibility tests, and selected goldens.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **I. Public API Stability**: PASS. v0.1.0 is an additive initial public API. Public surface includes `RawDropify`, `DropifyController`, `DropifyEntry`, `DropifySelectionMode`, `DropifyValue`, `DropifyCancelToken`, `DropifyPagingState`, `RawStaticDropify`, `RawAsyncDropify`, `RawPaginatedDropify`, `DropifyDropdown`, `DropifyAsyncDropdown`, `DropifyPaginatedDropdown`, `DropifyTheme`, `DropifyThemeData`, exported paging support types, constructor parameters, and documented behaviors. No deprecating or breaking changes are planned.
- **II. Single Consistent API**: PASS. Static, async, and paginated variants share `RawDropify` selection, search, validation, identity, controller, theming, and overlay behavior. All consumer-facing types are exported through `package:dropify_flutter/dropify_flutter.dart`.
- **III. Test-First & Golden Tests**: PASS with required implementation discipline. Tasks must write failing tests before code for primitives, widgets, async transitions, pagination footer states, form reset, keyboard paths, semantics, theme resolution, and selected themed widget goldens.
- **IV. Async Safety**: PASS. Async fetchers receive `DropifyCancelToken`; prior tokens are cancelled before replacement fetches; late stale results are ignored. Pagination remains caller-owned with a recommended `DropifyPagingState` carrying `search` and `cancelToken`; search reset and disposal cancellation are documented and tested.
- **V. Theming & Accessibility**: PASS. Themed widgets resolve instance overrides, `DropifyTheme`, host `ThemeData.extensions`, then Material defaults via `DropifyThemeData.fromMaterial(context)`. Keyboard navigation, focus/hover states, semantics, live regions, disabled/selected states, and configurable labels/messages are explicit deliverables.
- **Package Quality Gates**: PASS. Required verification: `dart format --set-exit-if-changed .`, `dart analyze`, `flutter test`, golden tests, example app tests/compilation, README/dartdoc alignment, stable semantic key coverage, and pub.dev dry-run/health review before release.

## Project Structure

### Documentation (this feature)

```text
specs/002-flutter-dropify/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   ├── behavior-contracts.md
│   ├── public-api.md
│   └── semantic-keys.md
└── tasks.md
```

### Source Code (repository root)

```text
lib/
├── dropify_flutter.dart
└── src/
    ├── core/
    │   ├── dropify_cancel_token.dart
    │   ├── dropify_controller.dart
    │   ├── dropify_entry.dart
    │   ├── dropify_paging_state.dart
    │   ├── dropify_selection.dart
    │   ├── dropify_value.dart
    │   └── raw_dropify.dart
    ├── internal/
    │   ├── _debouncer.dart
    │   ├── _default_matcher.dart
    │   ├── _dropify_anchor.dart
    │   ├── _dropify_focus_scope.dart
    │   ├── _dropify_panel.dart
    │   └── _dropify_search_field.dart
    ├── theme/
    │   ├── dropify_theme.dart
    │   └── dropify_theme_data.dart
    └── widgets/
        ├── dropify_async_dropdown.dart
        ├── dropify_dropdown.dart
        ├── dropify_paginated_dropdown.dart
        ├── raw_async_dropify.dart
        ├── raw_paginated_dropify.dart
        └── raw_static_dropify.dart

test/
├── core/
├── internal/
├── theme/
├── widgets/
├── accessibility/
└── goldens/

example/
└── lib/
    ├── fake_api.dart
    ├── main.dart
    └── pages/
```

**Structure Decision**: Use the layered layout from `ai_specs/001-flutter_dropify.md`. Keep core public abstractions under `lib/src/core`, private reusable implementation under `lib/src/internal`, theme types under `lib/src/theme`, consumer widgets under `lib/src/widgets`, and only curated exports in `lib/dropify_flutter.dart`. The example app is the integration surface for all variants and states.

## Phase 0: Research

Research completed in [research.md](research.md). All clarification items are resolved.

## Phase 1: Design And Contracts

Design artifacts completed:

- [data-model.md](data-model.md)
- [quickstart.md](quickstart.md)
- [contracts/public-api.md](contracts/public-api.md)
- [contracts/behavior-contracts.md](contracts/behavior-contracts.md)
- [contracts/semantic-keys.md](contracts/semantic-keys.md)

The requested `.specify/scripts/bash/update-agent-context.sh codex` command cannot be run because this repository does not contain `.specify/scripts/bash/update-agent-context.sh`. The agent context marker in `/AGENTS.md` was updated directly to reference this implementation plan.

## Post-Design Constitution Check

- **I. Public API Stability**: PASS. Contracts enumerate the additive v0.1.0 public API and semantic behavior expected to remain stable after release.
- **II. Single Consistent API**: PASS. Data model and contracts route all variants through shared value, identity, selection, validation, and theme concepts.
- **III. Test-First & Golden Tests**: PASS. Quickstart and contracts define verification commands and behavior groups that must be implemented test-first in `tasks.md`.
- **IV. Async Safety**: PASS. Research and contracts define cancellation token, query generation/stale result protection, retry, cache lifetime, paging reset, and disposal behavior.
- **V. Theming & Accessibility**: PASS. Contracts require Material token inheritance, visible copy configurability, semantics, live regions, keyboard behavior, and stable semantic keys.
- **Package Quality Gates**: PASS. No gate exceptions or complexity violations are introduced by the Phase 1 design.

## Complexity Tracking

No constitutional violations or justified complexity exceptions.
