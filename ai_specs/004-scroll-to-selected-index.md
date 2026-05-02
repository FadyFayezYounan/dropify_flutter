# Scroll To Selected Index

**Spec:** `004-scroll-to-selected-index`  
**Status:** Initial specification only  
**Package:** `dropify_flutter`  
**Intent:** Add open-time scrolling to the selected item for static and async dropdowns, while adding explicit control over eager vs lazy menu body rendering. Do not implement this spec as part of writing it.

---

## 1. Goal

When a Dropify static or async dropdown opens with an existing selection, the panel should automatically bring the selected option into view.

This matters because a dropdown with many options should reopen near the current value instead of forcing users to manually scroll from the top. The behavior must work for both current body strategies:

- Eager bodies: `SingleChildScrollView + Column`, using keyed row contexts and `Scrollable.ensureVisible`.
- Lazy bodies: indexed lazy list rendering, using `super_sliver_list` so Dropify can scroll to an index that may not be built yet.

This feature is limited to static and async dropdowns for now. Paginated dropdowns are intentionally out of scope because the selected item may not exist in currently loaded pages and paging state is caller-owned.

---

## 2. Reference Files

Use these files as the primary local references:

- `specs/002-flutter-dropify/plan.md`
- `ai_specs/003-dropify-flutter-alike-refactor.md`
- `refrences/flutter_dropdown_menu.dart`
- `refrences/flutter_menu_anchor.dart`
- `refrences/flutter_raw_menu_anchor.dart`
- `lib/dropify_flutter.dart`
- `lib/src/core/raw_dropify.dart`
- `lib/src/core/dropify_controller.dart`
- `lib/src/widgets/raw_static_dropify.dart`
- `lib/src/widgets/raw_async_dropify.dart`
- `lib/src/widgets/dropify_dropdown.dart`
- `lib/src/widgets/dropify_async_dropdown.dart`
- `lib/src/internal/_dropify_menu_scroll_shell.dart`
- `test/widgets/dropify_static_dropdown_test.dart`
- `test/widgets/dropify_async_dropdown_test.dart`
- `example/lib/pages/static_dropdown_page.dart`

External references:

- `https://pub.dev/packages/super_sliver_list`
- `https://pub.dev/documentation/super_sliver_list/latest/`
- `https://github.com/superlistapp/super_sliver_list/tree/main/example/lib`

Flutter's `DropdownMenu` reference stores a `GlobalKey` per visible button, identifies the highlighted item, and calls `Scrollable.of(context).position.ensureVisible(...)` after the frame. Dropify should use the same idea only for eager `SingleChildScrollView + Column` bodies. see this file for reference: `refrences/flutter_dropdown_menu.dart`

`super_sliver_list` is required for lazy indexed scrolling because it supports jumping or animating to an item index even when the item is not currently visible or laid out.

---

## 3. Current Dropify Context

Dropify currently has the correct layered shape:

- `RawDropify` owns anchor, overlay, search, selection, validation, controller state, and panel composition.
- `RawStaticDropify` owns in-memory filtering and static row building.
- `RawAsyncDropify` owns fetch state, debounce, caching, cancellation, stale-result protection, and async row building.
- `DropifyDropdown` and `DropifyAsyncDropdown` expose the Material-styled public wrappers.
- `RawPaginatedDropify` and `DropifyPaginatedDropdown` are separate and must not be changed for this feature.

Current static body behavior:

- Filtered static count `<= 50` uses `SingleChildScrollView + Column`.
- Filtered static count `> 50` uses a lazy list.

Current async body behavior:

- Loaded and refreshing async rows use a lazy list.
- Idle, loading, empty, and error states are direct body states, not row lists.

This feature should preserve that architecture and add only the public controls and internal row-body behavior needed for selected-index scrolling.

---

## 4. Public API Direction

### 4.1 New Body Mode Enum

Add a public enum:

```dart
enum DropifyMenuBodyMode {
  automatic,
  eagerColumn,
  lazyIndexed,
}
```

Recommended location:

- `lib/src/core/dropify_menu_body_mode.dart`
- exported from `lib/dropify_flutter.dart`

Semantics:

| Value         | Meaning                                                                                                                                                                                                                                                        |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `automatic`   | Use Dropify's default per-mode choice. Static uses eager for filtered count `<= 50` and lazy indexed for filtered count `> 50`. Async uses lazy indexed for loaded/refreshing row lists.                                                                       |
| `eagerColumn` | Force loaded row lists to use `SingleChildScrollView + Column`. This enables the Flutter `DropdownMenu`-style `GlobalKey` + `ensureVisible` approach. Consumers should use this only when the visible result set is known to be small enough to build eagerly. |
| `lazyIndexed` | Force loaded row lists to use `super_sliver_list` indexed lazy rendering, even when static filtered results are small. This preserves lazy construction and enables scroll-to-index for items that are not yet built.                                          |

Do not expose the enum on paginated widgets in this feature.

### 4.2 New Scroll-To-Selected Flag

Add a public property:

```dart
final bool scrollToSelectedOnOpen;
```

Default:

```dart
scrollToSelectedOnOpen = true
```

Expose it on:

- `RawStaticDropify`
- `RawStaticDropify.multi`
- `DropifyDropdown`
- `DropifyDropdown.multi`
- `RawAsyncDropify`
- `RawAsyncDropify.multi`
- `DropifyAsyncDropdown`
- `DropifyAsyncDropdown.multi`

Do not expose it on:

- `RawPaginatedDropify`
- `DropifyPaginatedDropdown`

### 4.3 New Body Mode Property

Add a public property:

```dart
final DropifyMenuBodyMode menuBodyMode;
```

Default:

```dart
menuBodyMode = DropifyMenuBodyMode.automatic
```

Expose it on the same static and async raw/themed constructors listed above.

The themed widgets should pass both `menuBodyMode` and `scrollToSelectedOnOpen` through to their raw widgets. This keeps the raw widgets as the source of behavior while giving normal package consumers access through the Material-styled widgets.

---

## 5. Behavioral Requirements

### 5.1 Open-Time Scroll

1. When a static or async dropdown opens and `scrollToSelectedOnOpen` is true, Dropify must attempt to scroll the row body to the selected item.
2. When `scrollToSelectedOnOpen` is false, opening the panel must preserve the normal initial scroll offset.
3. The scroll attempt must happen after the row body has enough data and layout information to identify the target index.
4. The scroll attempt must not change the selected value.
5. The scroll attempt must not open the dropdown by itself. It only reacts to an existing open transition.
6. The scroll attempt must not run for direct body states: loading, empty, error, idle, or no-results.
7. The scroll attempt must not run after the panel has already closed.
8. The scroll attempt must not throw if the target item disappears before the post-frame callback runs.

### 5.2 Single Selection Target

For single-selection dropdowns, the target is the first visible row whose value matches the selected value using Dropify's resolved identity rules:

1. Prefer `keyOf` when provided.
2. Otherwise use `equals` when provided.
3. Otherwise use default Dart equality.

If no visible row matches, do nothing.

### 5.3 Multi Selection Target

For multi-selection dropdowns, the target is the first selected item in the visible row list.

"First" means the lowest visible row index after static filtering or async data loading, not the first value in the selected set.

If no visible row is selected, do nothing.

### 5.4 Search Interaction

If search is active and the selected item is filtered out, Dropify must do nothing.

Rationale: the user's current search query defines the visible list. Clearing or mutating search to reveal the selection would be surprising, especially when the search controller is caller-owned.

Consequences:

- Static dropdowns scroll only within the filtered static rows.
- Async dropdowns scroll only within the loaded result list for the current query.
- Dropify must not clear search automatically.
- Dropify must not refetch async data just to reveal a selected item.
- Dropify must not show a warning or fallback row for a selected item that is not in the visible results.

### 5.5 Async Timing

For async dropdowns:

1. Opening with `loadOnOpen` and a cache miss starts the normal fetch.
2. While loading, no scroll-to-selected attempt runs.
3. When the latest fetch resolves with data and the panel is still open, Dropify attempts to scroll to the selected visible item.
4. If stale items are visible during refreshing, Dropify may scroll within the stale visible list only if that list is the current rendered row body.
5. When the replacement latest fetch resolves, Dropify may attempt again against the latest data.
6. Cancelled, stale, failed, empty, and disposed fetches must not trigger scrolling.
7. Dropify must not perform an extra fetch to locate a selected value.

### 5.6 Body Mode Selection

Static mode:

| `menuBodyMode` | Static renderer                                                                                                                 |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `automatic`    | `SingleChildScrollView + Column` when filtered count `<= 50`; `super_sliver_list` lazy indexed body when filtered count `> 50`. |
| `eagerColumn`  | Always use `SingleChildScrollView + Column` for non-empty filtered rows.                                                        |
| `lazyIndexed`  | Always use `super_sliver_list` lazy indexed body for non-empty filtered rows.                                                   |

Async mode:

| `menuBodyMode` | Async loaded/refreshing renderer                                 |
| -------------- | ---------------------------------------------------------------- |
| `automatic`    | Use `super_sliver_list` lazy indexed body.                       |
| `eagerColumn`  | Use `SingleChildScrollView + Column` for loaded/refreshing rows. |
| `lazyIndexed`  | Use `super_sliver_list` lazy indexed body.                       |

Direct states remain direct:

- static no-results
- async idle
- async loading
- async empty
- async error

These states must not be wrapped in fake row scroll bodies.

---

## 6. Implementation Direction

### 6.1 Shared Scroll Shell

Preserve the current private scroll shell idea from the Flutter-like refactor:

- It should own a `ScrollController`.
- It should apply the menu-like `ScrollConfiguration`.
- It should keep the visible scrollbar behavior.
- It should pass the controller to the concrete body renderer.

Extend or split it only if needed to support both eager and lazy indexed bodies cleanly.

### 6.2 Eager Column Strategy

For `SingleChildScrollView + Column` row bodies:

1. Generate one `GlobalKey` per visible row.
2. Keep key count aligned with the current visible rows.
3. After open and layout, locate the target row key.
4. If the target row has a current context, call `Scrollable.ensureVisible` or the equivalent `Scrollable.of(context).position.ensureVisible(...)`.
5. Use a short, deterministic alignment policy that keeps the selected row visible without forcing unnecessary scroll when already visible.
6. Do not rely on labels or widget text to identify rows. Use the same value identity rules as selection.

This mirrors the relevant Flutter `DropdownMenu` approach without copying Flutter private classes.

### 6.3 Lazy Indexed Strategy

For lazy row bodies:

1. Replace `ListView.builder` row bodies with `super_sliver_list` indexed rendering.
2. Use `ListController` from `super_sliver_list` to jump or animate to the selected visible index.
3. Keep the shell-owned `ScrollController` wired to the lazy body so the scrollbar and row list share the same position.
4. Avoid nested vertical scrollables.
5. Keep `padding: EdgeInsets.zero`.
6. Keep lazy row construction for large static and default async lists.
7. Use the selected visible index, not source index before filtering.

The preferred widget is `SuperListView.builder` if it fits the existing panel shell. If implementation research finds that `SuperSliverList` inside a `CustomScrollView` produces cleaner controller wiring, that is acceptable as long as behavior remains the same and no nested vertical scrollable is introduced.

### 6.4 Scroll Animation Policy

Use one consistent internal policy for both eager and lazy bodies:

- Prefer a short animated scroll when the panel opens normally.
- Avoid noticeable delay before the user can interact.
- Do not animate when the target is already fully visible.
- Keep the behavior deterministic in widget tests.

The first implementation may use a private constant for duration and curve. Do not add public animation configuration in this feature unless implementation proves it necessary.

### 6.5 Open Event Tracking

The scroll-to-selected attempt should run once per open cycle for the current visible data generation.

Expected behavior:

- Opening static dropdown: attempt once after rows render.
- Static search while open: do not automatically keep chasing the selected item on every query change unless this is necessary to satisfy open-time behavior after the first frame.
- Opening async dropdown with cached data: attempt after cached rows render.
- Opening async dropdown with fetch: attempt after the latest data rows render.
- Async refresh while open: a second attempt is acceptable only when the visible row data generation changes and the panel is still open.

Avoid repeated scroll calls every build.

---

## 7. Functional Requirements

1. Add public enum `DropifyMenuBodyMode` with `automatic`, `eagerColumn`, and `lazyIndexed`.
2. Export `DropifyMenuBodyMode` through `package:dropify_flutter/dropify_flutter.dart`.
3. Add `menuBodyMode` to static and async raw widgets, defaulting to `DropifyMenuBodyMode.automatic`.
4. Add `menuBodyMode` to static and async themed widgets, defaulting to `DropifyMenuBodyMode.automatic`.
5. Add `scrollToSelectedOnOpen` to static and async raw widgets, defaulting to true.
6. Add `scrollToSelectedOnOpen` to static and async themed widgets, defaulting to true.
7. Themed widgets must pass `menuBodyMode` and `scrollToSelectedOnOpen` directly to their raw counterparts.
8. Do not add either property to paginated widgets in this feature.
9. Static `automatic` mode must keep the current threshold semantics: filtered count `<= 50` uses eager column and filtered count `> 50` uses lazy indexed rendering.
10. Static `eagerColumn` mode must force eager rendering for non-empty filtered rows.
11. Static `lazyIndexed` mode must force lazy indexed rendering for non-empty filtered rows.
12. Async `automatic` and `lazyIndexed` modes must use lazy indexed rendering for loaded and refreshing row lists.
13. Async `eagerColumn` mode must use eager rendering for loaded and refreshing row lists.
14. No-results, loading, empty, error, and idle states must remain direct body states and must not receive row-list scroll-to-selected behavior.
15. When opening with a selected single value that is visible, Dropify must bring that row into view.
16. When opening with multi selection, Dropify must bring the first selected visible row into view.
17. When the selected value is not visible because of search/filter/current async results, Dropify must do nothing.
18. Async dropdowns must attempt scrolling only after current data rows are rendered.
19. Async dropdowns must not perform extra fetches to locate selected items.
20. Cancelled, stale, or failed async requests must not trigger scroll attempts.
21. Scrolling must use Dropify's resolved identity rules and must match the visual selected-state logic.
22. Scroll-to-selected must not regress selection, validation, search, clear, disabled row, multi-select, confirmable multi-select, focus, outside tap, Escape, or controller open/close behavior.
23. The implementation must add `super_sliver_list` as a package dependency for lazy indexed body scrolling.
24. Lazy static and async row bodies must use `super_sliver_list` instead of plain `ListView.builder`.
25. Public API changes must be additive and documented with dartdoc.

---

## 8. Edge Cases

1. Static filtered count `0`: show no-results, no scroll.
2. Static filtered count `50` in `automatic`: eager column, scroll via row keys.
3. Static filtered count `51` in `automatic`: lazy indexed, scroll via `super_sliver_list`.
4. Static source count over 50 filtered down to 1 visible selected row: eager column in `automatic`, and scroll if needed.
5. Static selected item filtered out by search: do nothing.
6. Static selected item removed from entries before open: do nothing.
7. Static duplicate values with identical identity keys: treat them as the same logical option, consistent with current selection behavior.
8. Static visually duplicate entries with distinct `keyOf` values: scroll to the first visible row matching the selected identity.
9. Multi-select with selected values `{c, a}` and visible order `[a, b, c]`: scroll to `a`.
10. Confirmable multi-select with staged changes from a previous open discarded on close: next open scrolls to committed selection, not discarded staged selection.
11. Async open with cache hit: render cached data and scroll if selected item is present.
12. Async open with cache miss: wait for latest data, then scroll if selected item is present.
13. Async refreshing stale data contains the selected item: it is acceptable to scroll stale rows once if they are the rendered body.
14. Async replacement data does not contain the selected item: do nothing after replacement completes.
15. Async selected item exists only on the server but not in current returned results: do nothing.
16. User closes panel before post-frame scroll: do nothing.
17. User selects another item before post-frame scroll: avoid scrolling to an obsolete target if this can be detected cleanly.
18. Forced `eagerColumn` with many async results may build many rows. This is allowed because the consumer explicitly requested eager rendering.
19. Forced `lazyIndexed` with only a few static rows should still render correctly and scroll correctly.
20. Search header and confirmable footer remain sticky and outside the scrollable row body.

---

## 9. Non-Goals

- Do not implement paginated scroll-to-selected behavior in this feature.
- Do not make Dropify fetch pages to find a selected paginated item.
- Do not add `menuBodyMode` or `scrollToSelectedOnOpen` to paginated widgets.
- Do not replace `RawDropify` with Flutter's public `MenuAnchor`.
- Do not copy Flutter private classes into runtime code.
- Do not introduce public animation or alignment configuration in the first implementation.
- Do not clear or mutate search to reveal the selected item.
- Do not add new selection semantics.
- Do not change `keyOf`, `equals`, controller, validation, form reset, or clear-button contracts.
- Do not remove the static automatic threshold behavior.

---

## 10. Implementation Plan For Future Work

### Phase 1: Dependency And Public API

1. Add `super_sliver_list` to package dependencies.
2. Add `DropifyMenuBodyMode`.
3. Export it from `lib/dropify_flutter.dart`.
4. Add constructor fields to raw static/async widgets.
5. Add constructor fields to themed static/async widgets.
6. Add dartdoc for new enum values and properties.
7. Add public API tests for the enum and constructor defaults.

### Phase 2: Internal Body Renderer Abstraction

1. Identify the smallest private abstraction that can render either eager column or lazy indexed body without leaking public API.
2. Keep the existing scroll shell behavior.
3. Add a lazy indexed body powered by `super_sliver_list`.
4. Add an eager keyed column body powered by `SingleChildScrollView + Column`.
5. Ensure both receive the same item builder inputs and selection identity decisions.

### Phase 3: Static Dropdown Behavior

1. Update `RawStaticDropify` to choose renderer from `menuBodyMode`.
2. Preserve `automatic` threshold behavior.
3. Compute the selected visible index after filtering.
4. Scroll on open when enabled.
5. Add tests for threshold boundaries, forced modes, search-filtered behavior, single selection, multi selection, and confirmable multi selection.

### Phase 4: Async Dropdown Behavior

1. Update `RawAsyncDropify` loaded and refreshing row bodies to choose renderer from `menuBodyMode`.
2. Compute selected visible index from current rendered data.
3. Scroll after cached data or latest successful data render.
4. Avoid scroll attempts for idle/loading/empty/error states.
5. Add tests for cache hit, cache miss, successful load, empty result, error, cancellation, stale results, refreshing stale rows, and forced eager mode.

### Phase 5: Example And Documentation

1. Update the example app to demonstrate scroll-to-selected on a large static dropdown.
2. Add an example control or page section that shows `DropifyMenuBodyMode.eagerColumn` vs `lazyIndexed`.
3. Update README/API docs with the new properties.
4. Mention that paginated scroll-to-selected is intentionally not included yet.

---

## 11. Validation Requirements

Required tests:

1. `DropifyDropdown` with `initialValue` near the end of a 100-item list opens with the selected row visible.
2. `RawStaticDropify` in `automatic` uses eager behavior at 50 filtered rows and lazy indexed behavior at 51 filtered rows.
3. `RawStaticDropify` with `menuBodyMode: DropifyMenuBodyMode.eagerColumn` uses eager behavior even above 50 rows.
4. `RawStaticDropify` with `menuBodyMode: DropifyMenuBodyMode.lazyIndexed` uses lazy indexed behavior even below 50 rows.
5. Static search filtering that hides the selected item does not clear search and does not scroll.
6. Static search filtering that includes the selected item scrolls within filtered results.
7. Multi-select static dropdown scrolls to the first selected visible item by row order.
8. Confirmable multi-select scrolls to committed selected values on open.
9. `DropifyAsyncDropdown` with cached data scrolls to selected visible item on open.
10. `DropifyAsyncDropdown` with data loaded after open scrolls to selected visible item after successful latest fetch.
11. Async empty and error states do not create row scroll bodies or scroll attempts.
12. Async stale/cancelled fetch completion does not trigger scroll.
13. Forced async `eagerColumn` uses keyed eager scrolling.
14. Forced async `lazyIndexed` uses `super_sliver_list` indexed scrolling.
15. `scrollToSelectedOnOpen: false` preserves normal initial scroll offset.
16. Existing tests for selection, disabled rows, search, validation, controller open/close, outside tap, Escape, async cancellation, and stale-result protection continue to pass.

Verification commands:

```bash
dart format .
flutter analyze
flutter test
```

---

## 12. Done When

This feature is complete when:

- Static and async dropdowns expose `menuBodyMode` and `scrollToSelectedOnOpen`.
- `scrollToSelectedOnOpen` defaults to true.
- Static and async themed widgets pass the new controls through to raw widgets.
- Static and async eager bodies can scroll to selected rows using keyed row contexts.
- Static and async lazy bodies use `super_sliver_list` and can scroll to selected row indexes.
- Search-visible behavior is respected: if the selected item is not visible, Dropify does nothing.
- Async scroll-to-selected runs only after current data is available and never triggers extra fetches.
- Paginated dropdown behavior and public API remain unchanged.
- Tests and documentation cover the new behavior.
