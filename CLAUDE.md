# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

Run from the repository root (the Flutter package itself):

```bash
dart format --set-exit-if-changed .   # Check formatting (CI gate)
dart analyze                          # Static analysis
flutter test                          # Run all package tests
flutter test test/core/               # Run only core unit tests
flutter test test/widgets/            # Run only widget tests
flutter test --name "some test name"  # Run a single test by name
flutter pub publish --dry-run         # Pre-publish readiness check
```

Run from `example/` for the demo app:

```bash
flutter run                           # Launch demo app
flutter build web                     # Build demo for web
```

## Architecture

This is a **Flutter dropdown package** with a three-layer architecture:

### Layer 1 — Core Primitives (`lib/src/core/`)
- `DropifyController<T>` — `ChangeNotifier`-based state owner. Holds selected value(s), exposes `open()`/`close()`/`setValue()`/`setValues()`/`toggle()`/`clear()`/`isSelected()`. Supports optional `keyOf` and `equals` for identity-aware comparison.
- `DropifyEntry<T>` — selectable option model (label + value).
- `DropifyValue` — sealed union: `DropifySingleValue<T>` / `DropifyMultiValue<T>`.
- `DropifySelectionMode` — enum: `single` (closes on pick) / `multi` (toggles, stays open).
- `DropifyCancelToken` — prevents stale async results from overwriting newer fetches.
- `DropifyPagingState<T>` — wraps `infinite_scroll_pagination`'s `PagingState` for paginated use.

### Layer 2 — Raw / Unstyled (`lib/src/widgets/raw_*.dart` + `lib/src/core/raw_dropify.dart`)
- `RawDropify` — the engine. Manages overlay lifecycle, search debouncing (300 ms default), keyboard navigation, focus scope, and calls back into caller-supplied builders.
- `RawStaticDropify` / `RawAsyncDropify` / `RawPaginatedDropify` — thin wrappers over `RawDropify` that add data-fetching strategies on top.

### Layer 3 — Material 3 Widgets (`lib/src/widgets/dropify_*.dart`)
- `DropifyDropdown` / `DropifyAsyncDropdown` / `DropifyPaginatedDropdown` — opinionated Material 3 wrappers. Use `DropifyTheme` (an `InheritedWidget`) and `DropifyThemeData.fromMaterial(context)` to bridge Material tokens.

### Internal (`lib/src/internal/`)
Private implementation details: overlay panel, anchor button, search field, focus scope, debouncer, and default text matcher. Files are prefixed with `_`.

### Public API
Everything is exported from `lib/dropify_flutter.dart` (single import). The package also re-exports `PagingState`, `PagingStateBase`, `Defaulted`, and `Omit` from `infinite_scroll_pagination`.

## Key Design Decisions

- **No external state management library** — pure `ChangeNotifier`; callers wire their own `DropifyController`.
- **Dual selection modes** — `single` auto-closes; `multi` keeps panel open and supports optional confirm/cancel buttons.
- **Async cancellation** — `DropifyCancelToken` must be checked after every `await` in async fetchers to guard against races.
- **Pagination** — caller owns and mutates `PagingState`; `RawPaginatedDropify` only reads and renders it.
- **Theming** — `DropifyTheme` is optional; if absent, widgets fall back to `DropifyThemeData.fromMaterial(context)`.
- **Form integration** — all three themed widgets expose `validator`, `autovalidateMode`, and wrap a `FormField` internally.

## Specification & Contracts

Authoritative design documents live under `specs/002-flutter-dropify/`:
- `spec.md` — full feature specification
- `plan.md` — phased implementation plan with quality gates
- `contracts/` — public API, behavior, and semantic key contracts

Do not change public API or behavior without consulting these contracts.

## Dart Version Constraint

Requires Dart `^3.10.3` and Flutter `>=3.27.0`. Dot-shorthand syntax (`SomeEnum.value` without the type prefix) is available and preferred where applicable.
