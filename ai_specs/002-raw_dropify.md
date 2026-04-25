# 002 — RawDropify on RawMenuAnchor (M1)

> Parent spec: [000-dropify_flutter.md](000-dropify_flutter.md)
>
> Depends on: [001-core_skeleton.md](001-core_skeleton.md) merged.
>
> Scope: Layer 1 primitive only. **Static data source only** in this milestone — async/paginated land in M3/M4. No default chrome.

## Goal

Implement `RawDropify<T>` and `RawDropify.multi` on top of `RawMenuAnchor`, exposing only `anchorBuilder` and `bodyBuilder` to the caller. The body is 100% user-controlled; the only thing the core does inside the overlay is wrap the body in a `TapRegion(groupId: state.overlayInfo.tapRegionGroupId)`.

A bespoke example page must prove that Layer 1 works alone — i.e. you can build a non-trivial dropdown (search box + list) using only `RawDropify` + the controller.

## Deliverables

### 1. `lib/src/internal/debouncer.dart`

Small `Debouncer` (timer-based) with `run(VoidCallback)` and `dispose()`. No package dep — use `dart:async`.

### 2. `lib/src/core/raw_dropify.dart`

Public API matches the parent spec:

```dart
class RawDropify<T> extends StatefulWidget {
  const RawDropify({
    super.key,
    this.controller,
    this.dataSource,                                // M1: only StaticDropifyDataSource is honored
    required this.anchorBuilder,
    required this.bodyBuilder,
    this.onSelectionChanged,
    this.onOpenChanged,
    this.onQueryChanged,
    this.useRootOverlay = false,
    this.consumeOutsideTaps = false,
    this.closeOnSelect,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.staticMatcher,
  });

  const RawDropify.multi({ /* same params, multi-select semantics */ });
}
```

Key implementation points:

- Built on `RawMenuAnchor.overlayBuilder` (from `package:flutter/widgets.dart`).
- Inherits focus, tap-outside, scroll-close, view-resize-close, escape-to-dismiss from `RawMenuAnchor` — **do not** reimplement.
- If `widget.controller` is null, instantiate an internal one in `initState` and dispose in `dispose` (mirrors `TextField`).
- Attach/detach the controller using the `_attach` plumbing landed in M0; assert single-bind.
- A `_RawDropifyBaseMixin<T>` shared by single + multi `State` classes for lifecycle code (controller bind/unbind, debouncer, query → matcher pipeline). Mirrors `_RawMenuAnchorBaseMixin` (refrences/flutter_raw_menu_anchor.dart:467).
- Wire a `MenuController` internally to drive `RawMenuAnchor`; reflect its open/close into `DropifyController.isOpen` and vice versa. The `DropifyController` is the source of truth from the user's perspective.
- `closeOnSelect` default: `true` for single, `false` for multi. Respect explicit override.
- `onSelectionChanged` fires after the controller's selection mutation completes (single value or multi list snapshot).
- `onOpenChanged(bool)` fires on every open/close transition.
- `onQueryChanged(String)` fires after the debounce window, not on every keystroke. Raw keystrokes still write to `DropifyController.query` immediately so the body rebuilds; the debounced callback is what consumers (M3 fetch, etc.) listen to.

### 3. Static filtering

`staticMatcher` signature:

```dart
typedef DropifyStaticMatcher<T> = bool Function(DropifyEntry<T> entry, String query);
```

Default: case-insensitive `entry.label.contains(query)` (after both are lowercased). Implemented in `lib/src/internal/default_matcher.dart` so M2 can reuse it.

When `dataSource` is `StaticDropifyDataSource`, `DropifyState.entries` is the filtered slice. When `dataSource` is null, treat as empty static. Async/Paginated sources throw `UnimplementedError("wired in M3/M4")` from `RawDropify` for now — the sealed switch must remain exhaustive at compile time.

### 4. Overlay wiring

- Use `RawMenuAnchor.overlayBuilder`. The builder receives `RawMenuOverlayInfo`; surface it into `DropifyState.overlayInfo` so body builders can position custom decoration relative to the anchor.
- Wrap the body in `TapRegion(groupId: overlayInfo.tapRegionGroupId, consumeOutsideTaps: widget.consumeOutsideTaps, ...)`. Nothing else — no padding, no `Material`, no `Card`.
- Default panel size: respect intrinsic body size. Width-follow-anchor logic is M2's problem (default chrome) — M1's body builder is fully user-controlled.

### 5. `DropifyController.maybeOf(context)`

Now that there's a real widget, ship a `_DropifyControllerScope` `InheritedWidget` so descendants of the body can call `DropifyController.maybeOf<T>(context)`. Mirrors `MenuController.maybeOf` (refrences/flutter_raw_menu_anchor.dart:1092).

### 6. Example page

`example/lib/pages/raw_page.dart` — a bespoke dropdown built directly on `RawDropify`. No default chrome. Demonstrates:

- A custom anchor (e.g. an `OutlinedButton` with chevron).
- A custom body (a `Column` with a `TextField` for search and a `ListView.builder` of items).
- Toggling selection via `state.toggle(value)` and reading `state.isSelected(value)`.
- Single + multi side by side.

Wire this page into `example/lib/main.dart`'s gallery. The other gallery entries (static/async/paginated/form/theming) can be stub `Scaffold(body: Center(child: Text('M2+')))` for now.

## Tests

`test/core/raw_dropify_test.dart` (widget tests):

- Anchor builder receives the controller and rebuilds when controller notifies.
- Tapping the anchor opens the overlay; tapping outside closes (inherited from `RawMenuAnchor`); pressing Escape closes.
- `bodyBuilder` receives the latest `DropifyState`, including filtered entries when `staticMatcher` runs.
- Default matcher is case-insensitive `contains`.
- Custom `staticMatcher` is honored.
- `closeOnSelect`: single closes after `state.toggle`; multi stays open; explicit override wins.
- `onSelectionChanged` / `onOpenChanged` fire with correct payloads.
- `onQueryChanged` is debounced (use `fakeAsync`); raw `controller.query` updates synchronously.
- Internal-controller path: omitting `controller` works and is disposed on widget unmount.
- Single-bind: attaching the same controller to two widgets simultaneously throws.
- `DropifyController.maybeOf` returns the controller from inside the body.

## Verification

1. `flutter analyze` + `dart format --set-exit-if-changed .` clean.
2. `flutter test` green (M0 tests still pass).
3. `cd example && flutter run` — `raw_page.dart` opens, search filters live, single-select closes on tap, multi-select stays open and toggles. Tap-outside / scroll-close / Escape all dismiss.
4. Capture a screenshot of the raw page in single + multi states (via `act-flutter-screenshot`) for the eventual README gallery.

## Out of scope

- Default anchor chrome (label, hint, chevron, chips). → M2.
- Default panel chrome (search field widget, decorated list). → M2.
- Async fetch / loading / error / empty states. → M3.
- Pagination. → M4.
- `FormField` integration. → M5.
- Theming polish, goldens. → M6.

## Done when

- `RawDropify` + `.multi` work with the static data source end-to-end.
- The bespoke example page proves Layer 1 is usable without any concrete widget.
- All M1 tests pass; no regression in M0 tests.
- The API surface from the parent spec for `RawDropify` is exported — but no internal helpers leak.
