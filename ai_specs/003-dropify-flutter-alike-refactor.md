# Dropify Flutter-Alike Menu Body Refactor

**Spec:** `003-dropify-flutter-alike-refactor`  
**Status:** Initial specification only  
**Package:** `dropify_flutter`  
**Intent:** Document what is needed to make Dropify follow Flutter's `MenuAnchor` implementation style as closely as appropriate, without applying this refactor yet.

---

## 1. Goal

Refactor Dropify's overlay panel/body architecture so it feels and behaves closer to Flutter's Material `MenuAnchor` internals while preserving Dropify's different data-loading modes.

The key constraint is that Flutter's `MenuAnchor` assumes a static, already-built `List<Widget>` menu body, but Dropify supports three different data shapes:

| Dropify mode       | Body renderer                                     | Reason                                                                                         |
| ------------------ | ------------------------------------------------- | ---------------------------------------------------------------------------------------------- |
| Static, small list | `SingleChildScrollView` + `Column`                | Matches Flutter `MenuAnchor`; list is known, small, and safe to build eagerly.                 |
| Static, large list | `ListView.builder`                                | Avoids eager layout/build cost for many options.                                               |
| Async              | `ListView.builder`                                | Items arrive after async fetches and may be large; do not eagerly build all rows.              |
| Paginated          | `PagedListView` from `infinite_scroll_pagination` | Pagination must keep using the package's lazy paging machinery and caller-owned `PagingState`. |

This spec should guide a future implementation plan. Do not change package behavior from this request alone.

---

## 2. Reference Files

Use these files as the primary references:

- `refrences/flutter_menu_anchor.dart`
- `refrences/flutter_raw_menu_anchor.dart`
- `refrences/flutter_dropdown_menu.dart`
- `lib/src/core/raw_dropify.dart`
- `lib/src/internal/_dropify_panel.dart`
- `lib/src/internal/_dropify_anchor.dart`
- `lib/src/widgets/raw_static_dropify.dart`
- `lib/src/widgets/raw_async_dropify.dart`
- `lib/src/widgets/raw_paginated_dropify.dart`
- `lib/src/theme/dropify_theme_data.dart`

Flutter's relevant `MenuAnchor` body chain appears in `refrences/flutter_menu_anchor.dart` around the `_MenuPanel` build method:

```dart
Material(
  child: Padding(
    child: ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        overscroll: false,
        physics: const ClampingScrollPhysics(),
      ),
      child: PrimaryScrollController(
        controller: scrollController,
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: scrollController,
            child: Flex(
              direction: widget.orientation,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
          ),
        ),
      ),
    ),
  ),
)
```

Flutter uses this because `MenuAnchor.menuChildren` is a static `List<Widget>`. Dropify should copy the panel chrome and scroll behavior where useful, but should not force all Dropify modes into `SingleChildScrollView + Column`.

---

## 3. Current Dropify Context

Dropify already has the correct layered split:

- `RawDropify` owns anchor, overlay, search, selection, validation, controller, and panel slot.
- `DropifyPanel` owns panel chrome: optional search header, body slot, and optional confirm/cancel footer.
- `RawStaticDropify` owns in-memory filtering and static rows.
- `RawAsyncDropify` owns async fetch state and async rows.
- `RawPaginatedDropify` owns paginated row rendering while the caller owns paging state.

The refactor should keep this architecture. The goal is not to replace Dropify with Flutter's `MenuAnchor`, but to make Dropify's internals use the same style of composition where it fits.

---

## 4. Required Direction

### 4.1 Panel Chrome Should Become More Flutter-Like

Align `DropifyPanel` more closely with Flutter's `_MenuPanel` structure:

1. Use a `Material` surface for the dropdown panel chrome.
2. Resolve panel shape, color, elevation, shadow, surface tint, padding, and clip behavior from `DropifyThemeData` and Material defaults.
3. Keep the search field as a sticky header above the body.
4. Keep the confirmable multi-select footer below the body.
5. Keep body height constrained by `panelConstraints` / `DropifyThemeData.panelMaxHeight`.
6. Keep `matchAnchorWidth` behavior, because Dropify is dropdown-oriented while Flutter `MenuAnchor` is menu-oriented.
7. Avoid introducing public API breaks unless a separate migration spec explicitly approves them.

### 4.2 Scroll Behavior Should Be Shared, But Body Renderers Must Differ

Create or refactor toward a shared internal scroll shell that applies Flutter-menu-like scroll behavior:

- `ScrollConfiguration.of(context).copyWith(scrollbars: false, overscroll: false, physics: const ClampingScrollPhysics())`
- `PrimaryScrollController`
- `Scrollbar(thumbVisibility: true)`
- zero body padding unless provided by theme or row builder
- no nested vertical scrollables

The shared shell should not force `SingleChildScrollView` for every mode. It should allow each mode to provide the correct scrollable child.

### 4.3 Static Mode Rendering

For static entries, stay closest to Flutter `MenuAnchor`:

1. Filter entries first using the configured matcher.
2. If the rendered static item count is small, use `SingleChildScrollView + Column` with eagerly built children.
3. Keep the existing threshold concept of `50` items unless implementation research finds a better named internal constant.
4. If the rendered item count is above the threshold, use `ListView.builder`.
5. Preserve disabled entry behavior, selected state, semantics, and single/multi selection behavior.
6. Empty filtered results must keep using the resolved no-results builder.

The small-list path is the closest match to Flutter's `SingleChildScrollView + Flex(children)` design.

### 4.4 Async Mode Rendering

Async mode must not use `SingleChildScrollView + Column` for data rows.

Requirements:

1. Continue using a lazy `ListView.builder` for loaded async items.
2. Preserve `DropifyAsyncState` transitions: idle, loading, refreshing with stale items, data, empty, and error.
3. Preserve cancellation and stale-result protection.
4. Preserve instance/theme/default resolution for loading, empty, and error builders.
5. When refreshing, stale items may remain in the `ListView.builder` with a lightweight progress indicator overlay.
6. Selecting an item must keep current single/multi behavior.

Rationale: async result sets are not guaranteed to be small or static, so eagerly building all items would copy the wrong part of Flutter's implementation.

### 4.5 Paginated Mode Rendering

Paginated mode must continue using `infinite_scroll_pagination`.

Requirements:

1. Use `PagedListView<PageKey, T>` for the panel body.
2. Keep accepting caller-owned `PagingState<PageKey, T>`.
3. Keep accepting caller-owned `fetchNextPage`.
4. Do not introduce internal `PagingController` ownership.
5. Keep `onSearchChanged` as the hook for callers to reset their paging state and refetch.
6. Preserve first-page loading, new-page loading, first-page error, new-page error, no-items, and no-more-items builders.
7. Apply the same menu-like scroll configuration as far as `PagedListView` supports without wrapping it in another vertical scrollable.

Rationale: pagination is already lazy and stateful through `infinite_scroll_pagination`; wrapping it in `SingleChildScrollView` would break the pagination model.

---

## 5. Behavioral Requirements

1. The overlay must remain anchored through the existing `RawMenuAnchor`-based architecture.
2. Outside tap, escape dismissal, focus handling, and scroll-aware overlay behavior must not regress.
3. Search remains sticky above the body for static, async, and paginated modes.
4. Confirm/cancel footer remains sticky below the body for confirmable multi-select.
5. The panel must stay constrained and overflow-free on narrow screens.
6. `matchAnchorWidth` remains the default behavior for dropdown use cases.
7. Static small lists should visually and structurally resemble Flutter `MenuAnchor` as closely as possible.
8. Async and paginated lists should share Flutter-like panel chrome but keep lazy list bodies.
9. Selection identity must continue honoring `keyOf` and `equals`.
10. Public imports must remain through `package:dropify_flutter/dropify_flutter.dart`.

---

## 6. Theming Requirements

The refactor should make `DropifyThemeData` better map to Flutter Material menu concepts without removing existing tokens.

Review whether these theme fields are sufficient or need additive fields:

- panel background/color
- panel elevation
- panel shadow color
- panel surface tint
- panel shape / border radius
- panel padding
- panel clip behavior
- scrollbar visibility or styling, if needed

Resolution order must remain:

```text
instance argument
?? DropifyTheme.of(context)
?? ThemeData.extension<DropifyThemeData>()
?? DropifyThemeData.fromMaterial(Theme.of(context))
```

Add fields only if required to represent Flutter-like `MenuStyle` behavior cleanly. Prefer internal defaults over public API expansion when possible.

---

## 7. Non-Goals

- Do not replace `RawDropify` with Flutter's public `MenuAnchor`.
- Do not make async results eagerly render with `Column`.
- Do not make paginated results use `SingleChildScrollView`.
- Do not make Dropify own pagination state.
- Do not introduce a public `PagingController` requirement.
- Do not remove static large-list `ListView.builder` behavior.
- Do not change value identity, controller, validation, or public selection contracts.
- Do not implement this spec as part of writing the spec file.

---

## 8. Implementation Notes For Future Work

Future implementation should inspect Flutter's references thoroughly before editing:

1. Study `flutter_menu_anchor.dart` for panel composition, padding, scroll configuration, scrollbar behavior, focus scope, shortcuts, and constraints.
2. Study `flutter_raw_menu_anchor.dart` for overlay anchoring and dismissal mechanics.
3. Study `flutter_dropdown_menu.dart` for dropdown-specific differences from general menus.
4. Compare those patterns with `RawDropify`, `DropifyPanel`, and the three raw specialized widgets.
5. Keep the smallest correct refactor. Avoid creating broad abstractions unless they remove real duplication between static, async, and paginated bodies.

Likely internal shape:

- `DropifyPanel` keeps header/body/footer layout.
- A private helper handles menu-like scroll configuration and scrollbar behavior.
- Static mode chooses between `SingleChildScrollView + Column` and `ListView.builder`.
- Async mode uses the helper with `ListView.builder` where possible.
- Paginated mode uses the helper with `PagedListView` where possible.

---

## 9. Validation Requirements

Future implementation should include tests proving behavior rather than only checking widget types.

Required coverage:

1. Static small list renders and scrolls successfully with `SingleChildScrollView + Column` behavior.
2. Static large list uses lazy rendering and does not eagerly build every row.
3. Async loaded data uses lazy rendering and preserves loading, refreshing, empty, error, and retry states.
4. Async cancellation still prevents stale results from rendering.
5. Paginated body uses `PagedListView` and triggers `fetchNextPage` through the existing paging contract.
6. Paginated search still calls `onSearchChanged` and leaves state reset/refetch ownership to the caller.
7. Search header and confirmable footer remain outside the scrollable body.
8. Keyboard navigation, escape close, outside tap close, semantics, selected state, and disabled rows do not regress.
9. Themed panel defaults remain Material 3-compatible.
10. `dart format`, `dart analyze`, and `flutter test` pass.

---

## 10. Done When

This future refactor is complete when:

- Dropify panel chrome follows Flutter `MenuAnchor`'s structure where appropriate.
- Static small lists are rendered in the Flutter-like eager menu style.
- Static large lists, async lists, and paginated lists remain lazy.
- Paginated dropdowns continue using `infinite_scroll_pagination` and caller-owned `PagingState`.
- No public API break is introduced without a separate migration decision.
- All validation requirements pass.
