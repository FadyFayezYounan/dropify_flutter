<goal>
Build open-time scrolling to the selected visible item for Dropify static and async dropdowns.

This benefits users who reopen long dropdowns with an existing selection. Instead of starting at the top of a large option list, the open panel should immediately show the currently selected item when that item is present in the current visible rows.

The feature also adds explicit public control over eager versus lazy row body rendering for static and async dropdowns. This lets package consumers choose predictable small-list eager rendering or indexed lazy rendering while keeping paginated dropdowns out of scope.

This specification is saved at `./ai_specs/004-scroll-to-selected-index-spec.md`. The source task description is `./ai_specs/004-scroll-to-selected-index.md`.
</goal>

<background>
Dropify is a Flutter package with a layered dropdown architecture.

Relevant project constraints:
- Dart SDK constraint is `^3.10.3` and Flutter constraint is `>=3.27.0` in `./pubspec.yaml`.
- Public APIs must remain additive and exported through `package:dropify_flutter/dropify_flutter.dart`.
- `RawDropify` owns anchoring, overlay lifecycle, search text, selection, validation, controller state, and panel composition.
- `RawStaticDropify` owns in-memory filtering and static row building.
- `RawAsyncDropify` owns async fetch state, debounce, cache, cancellation, stale-result protection, and async row building.
- `DropifyDropdown` and `DropifyAsyncDropdown` expose Material-styled public wrappers.
- `RawPaginatedDropify` and `DropifyPaginatedDropdown` are out of scope and must remain unchanged for this feature.

Current row body behavior:
- Static filtered count `<= 50` uses `SingleChildScrollView + Column`.
- Static filtered count `> 50` uses `ListView.builder`.
- Async loaded and refreshing rows use `ListView.builder`.
- Static no-results and async idle/loading/empty/error states are direct body states, not row-list bodies.

Clarified implementation decisions:
- Lazy indexed row bodies should prefer `SuperListView.builder` from `super_sliver_list`.
- `SuperSliverList` inside `CustomScrollView` is allowed only if implementation research proves `SuperListView.builder` cannot satisfy controller, scrollbar, or layout constraints.
- Open-time scroll motion should be an immediate jump, not an animation.
- The private scroll shell should own the row `ScrollController` and the lazy `ListController`.
- Scroll jumps should be scheduled with `SchedulerBinding.instance.addPostFrameCallback` so row layout and lazy controller attachment are available.
- Async refreshing may jump within stale rows if stale rows are the currently rendered body, then may jump again when the latest successful data replaces them.
- Tests should verify both user-visible behavior and selected eager/lazy body widget types.
- Dartdoc, README/doc guide updates, and example app updates are in scope.

Local references to examine before implementation:
- `./specs/002-flutter-dropify/plan.md`
- `./ai_specs/003-dropify-flutter-alike-refactor.md`
- `./ai_specs/004-scroll-to-selected-index.md`
- `./refrences/flutter_dropdown_menu.dart`
- `./refrences/flutter_menu_anchor.dart`
- `./refrences/flutter_raw_menu_anchor.dart`
- `./lib/dropify_flutter.dart`
- `./lib/src/core/raw_dropify.dart`
- `./lib/src/core/dropify_controller.dart`
- `./lib/src/core/dropify_selection.dart`
- `./lib/src/widgets/raw_static_dropify.dart`
- `./lib/src/widgets/raw_async_dropify.dart`
- `./lib/src/widgets/dropify_dropdown.dart`
- `./lib/src/widgets/dropify_async_dropdown.dart`
- `./lib/src/internal/_dropify_menu_scroll_shell.dart`
- `./test/public_api_test.dart`
- `./test/widgets/dropify_static_dropdown_test.dart`
- `./test/widgets/dropify_async_dropdown_test.dart`
- `./test/journeys/dropify_menu_body_journey_test.dart`
- `./test/robots/dropify_robot.dart`
- `./example/lib/pages/static_dropdown_page.dart`
- `./README.md`
- `./doc/static_dropdowns.md`
- `./doc/async_dropdowns.md`
- `./doc/accessibility_and_testing.md`

External references:
- `https://pub.dev/packages/super_sliver_list`
- `https://pub.dev/documentation/super_sliver_list/latest/`
- `https://pub.dev/documentation/super_sliver_list/latest/super_sliver_list/SuperListView-class.html`
- `https://pub.dev/documentation/super_sliver_list/latest/super_sliver_list/ListController-class.html`
</background>

<outputs>
Implementation should create or modify these paths:
- `./pubspec.yaml`
- `./pubspec.lock`
- `./lib/dropify_flutter.dart`
- `./lib/src/core/dropify_menu_body_mode.dart`
- `./lib/src/internal/_dropify_menu_scroll_shell.dart`
- `./lib/src/widgets/raw_static_dropify.dart`
- `./lib/src/widgets/raw_async_dropify.dart`
- `./lib/src/widgets/dropify_dropdown.dart`
- `./lib/src/widgets/dropify_async_dropdown.dart`
- `./test/public_api_test.dart`
- `./test/widgets/dropify_static_dropdown_test.dart`
- `./test/widgets/dropify_async_dropdown_test.dart`
- `./test/journeys/dropify_menu_body_journey_test.dart`
- `./test/robots/dropify_robot.dart`
- `./README.md`
- `./doc/static_dropdowns.md`
- `./doc/async_dropdowns.md`
- `./doc/accessibility_and_testing.md`
- `./example/lib/pages/static_dropdown_page.dart`

Implementation may create additional private files under `./lib/src/internal/` if doing so keeps static and async row-body logic simple and avoids duplicated scroll scheduling logic.

Do not modify paginated runtime files for this feature:
- `./lib/src/widgets/raw_paginated_dropify.dart`
- `./lib/src/widgets/dropify_paginated_dropdown.dart`
</outputs>

<user_flows>
Primary flow:
1. A user has a selected value in a static or async Dropify dropdown.
2. The user opens the dropdown from the anchor.
3. Dropify renders the current row body.
4. If the selected item is present in the currently visible row data, Dropify immediately jumps the row body so the selected row is visible.
5. The selection remains unchanged and the user can continue selecting, searching, clearing, applying, cancelling, or closing as before.

Static alternative flows:
- A user opens a static dropdown with `menuBodyMode: DropifyMenuBodyMode.automatic`; filtered counts `<= 50` use eager keyed rows and filtered counts `> 50` use lazy indexed rows.
- A user opens a static dropdown with `menuBodyMode: DropifyMenuBodyMode.eagerColumn`; all non-empty filtered row lists use eager keyed rows.
- A user opens a static dropdown with `menuBodyMode: DropifyMenuBodyMode.lazyIndexed`; all non-empty filtered row lists use `SuperListView.builder` lazy indexed rows.
- A user opens a searchable static dropdown where the current query hides the selected item; Dropify preserves the query and performs no jump.
- A user opens a multi-select static dropdown; Dropify jumps to the first selected visible row by current filtered row order.

Async alternative flows:
- A user opens an async dropdown with cached data for the current query; Dropify renders cached rows and jumps if the selected item is present.
- A user opens an async dropdown with no cached data and `loadOnOpen: true`; Dropify shows loading, waits for the latest successful data, renders rows, and jumps if the selected item is present.
- A user opens an async dropdown with `menuBodyMode: DropifyMenuBodyMode.eagerColumn`; loaded or refreshing rows use eager keyed rows and direct async states remain direct states.
- A user opens an async dropdown with `menuBodyMode: DropifyMenuBodyMode.automatic` or `DropifyMenuBodyMode.lazyIndexed`; loaded or refreshing rows use `SuperListView.builder` lazy indexed rows.
- A user searches while async stale rows are rendered during refresh; Dropify may jump within stale rows if they are currently rendered and may jump again after latest data renders.

Error and recovery flows:
- Async loading, idle, empty, and error states do not create row scroll bodies and do not run scroll-to-selected logic.
- Static no-results state does not create a row scroll body and does not run scroll-to-selected logic.
- Cancelled, stale, failed, or disposed async requests do not trigger scroll jumps.
- If the user closes the panel before a scheduled post-frame jump runs, the scheduled work does nothing.
- If the selected target disappears before a scheduled post-frame jump runs, the scheduled work does nothing.
- If `scrollToSelectedOnOpen` is false, opening preserves normal initial row body offset behavior and no selected-target jump runs.

Entry and exit points:
- Entry starts when `RawDropify` opens the panel through anchor tap, keyboard/controller open behavior, or any existing open path.
- Exit succeeds when the selected visible row is visible after open or when Dropify correctly no-ops because there is no visible selected row.
- Exit also includes normal close paths: single selection, outside tap, Escape, controller close, confirmable apply, and confirmable cancel.
</user_flows>

<requirements>
**Functional:**
1. Add public enum `DropifyMenuBodyMode` in `./lib/src/core/dropify_menu_body_mode.dart`.
2. `DropifyMenuBodyMode` must define `automatic`, `eagerColumn`, and `lazyIndexed` values.
3. Export `DropifyMenuBodyMode` from `./lib/dropify_flutter.dart`.
4. Add `menuBodyMode` to `RawStaticDropify` and `RawStaticDropify.multi`, defaulting to `DropifyMenuBodyMode.automatic`.
5. Add `menuBodyMode` to `DropifyDropdown` and `DropifyDropdown.multi`, defaulting to `DropifyMenuBodyMode.automatic`.
6. Add `menuBodyMode` to `RawAsyncDropify` and `RawAsyncDropify.multi`, defaulting to `DropifyMenuBodyMode.automatic`.
7. Add `menuBodyMode` to `DropifyAsyncDropdown` and `DropifyAsyncDropdown.multi`, defaulting to `DropifyMenuBodyMode.automatic`.
8. Add `scrollToSelectedOnOpen` to `RawStaticDropify` and `RawStaticDropify.multi`, defaulting to true.
9. Add `scrollToSelectedOnOpen` to `DropifyDropdown` and `DropifyDropdown.multi`, defaulting to true.
10. Add `scrollToSelectedOnOpen` to `RawAsyncDropify` and `RawAsyncDropify.multi`, defaulting to true.
11. Add `scrollToSelectedOnOpen` to `DropifyAsyncDropdown` and `DropifyAsyncDropdown.multi`, defaulting to true.
12. The themed widgets must pass `menuBodyMode` and `scrollToSelectedOnOpen` directly to their raw widgets.
13. Do not add `menuBodyMode` or `scrollToSelectedOnOpen` to paginated widgets.
14. Add `super_sliver_list` as a runtime dependency in `./pubspec.yaml` and refresh `./pubspec.lock`.
15. Static `automatic` mode must keep the current threshold: filtered count `<= 50` uses eager column and filtered count `> 50` uses lazy indexed rendering.
16. Static `eagerColumn` mode must use `SingleChildScrollView + Column` for every non-empty filtered row list.
17. Static `lazyIndexed` mode must use `SuperListView.builder` for every non-empty filtered row list.
18. Async `automatic` mode must use `SuperListView.builder` for loaded and refreshing row lists.
19. Async `eagerColumn` mode must use `SingleChildScrollView + Column` for loaded and refreshing row lists.
20. Async `lazyIndexed` mode must use `SuperListView.builder` for loaded and refreshing row lists.
21. Static no-results and async idle/loading/empty/error states must remain direct body states.
22. Lazy static and async row bodies must use `SuperListView.builder` unless implementation research proves `SuperSliverList` is required for correct controller or scrollbar wiring.
23. Lazy row bodies must share the shell-owned `ScrollController` with the visible `Scrollbar`.
24. Lazy row bodies must use the shell-owned `ListController` for indexed jumps.
25. Eager row bodies must maintain one `GlobalKey` or equivalent row context per visible row.
26. Eager row keys must stay aligned with the current visible rows and must not be used for value identity.
27. Open-time scroll must run only in response to an open row-body render or a current visible data generation while open.
28. Open-time scroll must not open the dropdown by itself.
29. Open-time scroll must not change selected values.
30. Open-time scroll must not clear, rewrite, or refetch search results.
31. Single-selection target is the first visible row whose value matches `DropifyPanelState.value` using Dropify selection identity.
32. Multi-selection target is the first visible row whose value is contained in `DropifyPanelState.values` using Dropify selection identity.
33. Multi-selection first means lowest current visible row index, not insertion order in the selected set.
34. Confirmable multi-select opening must target the committed selection present when the panel opens, not staged values discarded by a previous cancelled open cycle.
35. Disabled selected rows still count as selected visible rows and may be jumped to.
36. Static target indexes must be computed after filtering.
37. Async target indexes must be computed from the currently rendered data rows for the current query.
38. If no visible row matches the selected value or selected values, Dropify must do nothing.
39. If `scrollToSelectedOnOpen` is false, Dropify must not run target lookup or jump logic for that open cycle.
40. Public API changes must include dartdoc that explains defaults, renderer semantics, and paginated non-applicability.

**Error Handling:**
41. Scheduled jump work must check that the row body widget is still mounted before using contexts or controllers.
42. Scheduled jump work must check that the target index is still within the current visible row list before jumping.
43. Scheduled jump work must no-op if the panel closed before the post-frame callback runs.
44. Scheduled jump work must no-op if the lazy `ListController` is not attached after the allowed post-frame scheduling window.
45. Scheduled jump work must no-op if an eager row key has no current context.
46. Cancelled async fetches must not update visible state and must not trigger scroll-to-selected.
47. Stale async fetch completions must not update visible state and must not trigger scroll-to-selected.
48. Failed async fetches must show existing error behavior and must not trigger scroll-to-selected.
49. Empty async results must show existing empty behavior and must not trigger scroll-to-selected.
50. Exceptions from missing render objects, detached controllers, or disappearing row contexts must be avoided through guards rather than caught as normal control flow.

**Edge Cases:**
51. Static filtered count `0` must show no-results and perform no jump.
52. Static filtered count `50` in `automatic` must use eager column rendering.
53. Static filtered count `51` in `automatic` must use lazy indexed rendering.
54. Static source count above 50 filtered down to a small visible count must choose renderer from the filtered count in `automatic`.
55. Static selected item filtered out by search must preserve search and perform no jump.
56. Static selected item removed from `entries` before open must perform no jump.
57. Duplicate static values with the same identity must behave consistently with existing selection semantics and jump to the first visible matching row.
58. Visually duplicate static entries with distinct `keyOf` values must jump according to the selected identity key.
59. Multi-select selected values `{c, a}` with visible order `[a, b, c]` must jump to `a`.
60. Async cache hit must render cached rows and jump if the selected item is present.
61. Async cache miss with `loadOnOpen: true` must wait for the latest successful data rows before jumping.
62. Async selected item existing only outside the current returned results must perform no jump.
63. Async refreshing stale rows containing the selected item may jump while those stale rows are rendered.
64. Async replacement data not containing the selected item must perform no jump after replacement completes.
65. User selection changes before the scheduled jump runs should avoid jumping to an obsolete target when this can be detected from the current visible data and current selected state.
66. Forced `eagerColumn` with many async results may eagerly build many rows because the consumer explicitly requested it.
67. Forced `lazyIndexed` with few static rows must render correctly and jump correctly.
68. Search header and confirmable footer must remain sticky and outside the scrollable row body.
69. The row body must not introduce nested vertical scrollables.
70. Row body padding must remain `EdgeInsets.zero` unless an existing theme or row builder already controls row padding.

**Validation:**
71. `menuBodyMode` values must be usable from the public package import.
72. Constructor defaults must be verified for static and async raw/themed single and multi constructors.
73. Body renderer selection must be verified at static threshold boundaries and forced modes.
74. Open-time selected-row visibility must be verified for static eager and lazy row bodies.
75. Open-time selected-row visibility must be verified for async eager and lazy row bodies.
76. Search-hidden selected values must be verified to preserve search and perform no jump.
77. Async cancelled, stale, failed, empty, and loading paths must be verified to avoid scroll jumps.
78. Existing selection, disabled row, search, clear, validation, controller open/close, outside tap, Escape, async cancellation, and stale-result tests must continue to pass.
</requirements>

<boundaries>
Edge cases:
- Selected value is null in single-selection mode: no target lookup and no jump.
- Selected values are empty in multi-selection mode: no target lookup and no jump.
- Selected item is currently visible: do not perform an unnecessary jump.
- Selected item is below or above the current viewport: jump immediately so it becomes visible.
- Selected item is partially visible: implementation may no-op if the row is already in the visible range.
- Selected row is disabled: jump is allowed because disabled affects tap behavior, not visibility of the current selection.
- Search query filters out the selected item: no warning, no fallback row, no query mutation, no extra fetch.
- Query changes while the panel is open: do not repeatedly chase the selected item on every build; only run for the relevant open/data generation.

Error scenarios:
- Panel closes before post-frame work: no-op.
- Body widget disposes before post-frame work: no-op.
- Lazy controller not attached after the scheduled frame: no-op after one bounded reschedule.
- Eager row context unavailable after the scheduled frame: no-op after one bounded reschedule.
- Async request completes after cancellation: no state update and no jump.
- Async request completes as stale generation: no state update and no jump.
- Async request fails: existing error UI and retry behavior remain unchanged.
- Async retry succeeds: if rows render while the panel is still open, target jump may run for the successful row generation.

Limits:
- This feature must not support paginated scroll-to-selected behavior.
- This feature must not fetch extra async results or server-side pages to find selected values.
- This feature must not add public animation, alignment, or retry configuration.
- This feature must not alter `keyOf`, `equals`, `DropifySelectionIdentity`, `DropifyController`, form reset, validation, or clear-button contracts.
- This feature must not replace `RawDropify` with Flutter's public `MenuAnchor` or copy Flutter private classes into runtime code.
</boundaries>

<implementation>
Dependency and exports:
- Add `super_sliver_list: ^0.4.1` or the latest compatible `0.4.x` version to `./pubspec.yaml`.
- Run package resolution so `./pubspec.lock` records the dependency.
- Add `DropifyMenuBodyMode` under `./lib/src/core/dropify_menu_body_mode.dart` with dartdoc on the enum and each value.
- Export only the public enum from `./lib/dropify_flutter.dart`.

Public API plumbing:
- Add fields and constructor parameters to raw static, themed static, raw async, and themed async widgets.
- Keep defaults additive: `menuBodyMode = DropifyMenuBodyMode.automatic` and `scrollToSelectedOnOpen = true`.
- Pass new themed widget arguments directly to raw widgets without changing existing themed row builders.
- Do not expose these properties on paginated widgets.

Renderer selection:
- Implement a small private renderer selection path for static and async row bodies.
- Keep direct states direct and return no-results/loading/empty/error widgets without row scroll wrappers.
- For eager row lists, render `SingleChildScrollView` with `Column` and keyed children.
- For lazy row lists, render `SuperListView.builder` with `controller`, `primary: false`, `padding: EdgeInsets.zero`, `shrinkWrap: false`, `itemCount`, `itemBuilder`, and the shell-owned `ListController`.
- Use `SuperSliverList` only if `SuperListView.builder` cannot be wired without nested scrolling, broken scrollbar behavior, or controller attachment issues.

Scroll shell:
- Extend `DropifyMenuScrollShell` or create a minimal private sibling so the shell owns and disposes `ScrollController` and `ListController`.
- Keep the existing menu-like `ScrollConfiguration` with scrollbars disabled in behavior, overscroll disabled, and clamping physics.
- Keep the visible `Scrollbar` using the same `ScrollController` as the row body.
- Keep `PrimaryScrollController` behavior compatible with the current shell.
- Avoid exposing shell controllers publicly.

Target resolution:
- Use `DropifySelectionIdentity<T>(keyOf: keyOf, equals: equals)` or the same identity logic used by existing selection state.
- Resolve single-selection target from the current selected value and current visible row values.
- Resolve multi-selection target from current selected values and current visible row values in row order.
- Use visible row index after filtering or after async data state selection; never use unfiltered source indexes for static mode.
- Do not use labels, widget text, or semantics labels to identify selected rows.

Open-time scheduling:
- Schedule jump attempts with `SchedulerBinding.instance.addPostFrameCallback` after the row body for the current open/data generation is built.
- Keep a generation token or equivalent guard so builds do not schedule repeated jumps for the same open/data generation.
- If the first scheduled callback finds the eager context or lazy `ListController` not ready, schedule one additional post-frame callback for the same target generation.
- Do not retry indefinitely.
- Before jumping, verify `mounted`, current target generation, target index bounds, selected state, and panel/body liveness.
- For eager rows, use `Scrollable.ensureVisible` or `Scrollable.of(context).position.ensureVisible` with zero duration or an immediate equivalent.
- For lazy rows, use `ListController.jumpToItem` with the shell-owned `ScrollController`.
- Use a private alignment policy or constant; do not add public alignment or animation configuration.
- If the target row/index is already visible according to available visible-range information, no-op instead of forcing another jump.

Async behavior:
- Preserve current debounce, cache, cancellation, stale-result generation, and retry behavior.
- On cache hit, rendered cached data is a valid row generation for scroll-to-selected.
- On cache miss, loading is not a row generation and must not scroll.
- On successful latest fetch, rendered data is a valid row generation for scroll-to-selected.
- On refreshing with stale rows, stale rows are a valid row generation only while they are the currently rendered body.
- On cancelled, stale, failed, empty, or disposed fetch completion, do not schedule scroll-to-selected.

Documentation and examples:
- Update dartdoc for new enum and new properties.
- Update `./README.md` to mention `scrollToSelectedOnOpen`, `menuBodyMode`, and paginated non-applicability.
- Update `./doc/static_dropdowns.md` with static threshold, forced modes, and scroll-to-selected behavior.
- Update `./doc/async_dropdowns.md` with async loaded/refreshing behavior, no-extra-fetch behavior, and body mode semantics.
- Update `./doc/accessibility_and_testing.md` only if selector or testing guidance changes.
- Update `./example/lib/pages/static_dropdown_page.dart` to demonstrate a long static dropdown with an initial or retained selected value near the end and a visible body mode control or explanation.

What to avoid:
- Do not add backward-compatibility aliases because this is additive API before a released breaking migration.
- Do not create a large public body-renderer abstraction.
- Do not expose internal scroll controllers or list controllers.
- Do not use mocks for internal row-body widgets in tests.
- Do not add package-wide global scheduler hooks.
</implementation>

<discovery>
Before implementation, examine thoroughly:
- Whether `SuperListView.builder` can receive the shell-owned `ScrollController` and `ListController` while preserving current scrollbar behavior.
- Whether the existing `DropifyMenuScrollShell` should be extended or replaced by a private sibling to avoid overloading its builder signature.
- Whether eager and lazy row-body scheduling can be shared without adding shallow abstractions.
- Whether `DropifyPanelState` needs any private lifecycle support or whether row-body widget lifecycle and generation tokens are sufficient.
- Whether current tests already have helpers for controlled async fetches that should be reused for cache, stale, cancellation, and retry cases.
- Whether documentation should use a short API section or a full body-mode table in README to avoid duplication with `./doc/static_dropdowns.md` and `./doc/async_dropdowns.md`.
</discovery>

<stages>
Phase 1: Dependency and public API.
Verify by adding one failing public API/defaults test at a time, then implementing the enum, export, constructor fields, and pass-through plumbing until each test passes.

Phase 2: Private row-body rendering foundation.
Verify by proving static forced eager and forced lazy modes select the expected body widget types without changing selection behavior.

Phase 3: Static scroll-to-selected.
Verify by adding behavior-first widget tests for static eager and lazy open-time visibility, threshold boundaries, disabled selected rows, search-filtered behavior, multi-selection, and confirmable multi-selection.

Phase 4: Async scroll-to-selected.
Verify by adding behavior-first widget tests for cache hit, cache miss with successful latest data, refreshing stale rows, empty state, error state, cancelled requests, stale results, forced eager mode, and forced lazy mode.

Phase 5: Robot journeys and regression coverage.
Verify by extending `./test/robots/dropify_robot.dart` and `./test/journeys/dropify_menu_body_journey_test.dart` with critical journeys that open long static and async dropdowns and observe selected rows after open.

Phase 6: Documentation and example app.
Verify by updating README/docs/example paths and ensuring examples compile through normal analyzer/test commands.
</stages>

<validation>
TDD expectations:
- Use vertical-slice RED -> GREEN -> REFACTOR cycles.
- Write exactly one failing test for the next behavior before implementing that behavior.
- Run the focused test and confirm it fails for the expected reason before production code changes.
- Implement the minimum production change needed for the current test to pass.
- Refactor only while the full relevant test set is green.
- Do not batch all tests before implementation.

Recommended test order:
1. Public API export and constructor defaults for `DropifyMenuBodyMode`, `menuBodyMode`, and `scrollToSelectedOnOpen`.
2. Static `automatic` body type at 50 and 51 filtered rows.
3. Static forced `eagerColumn` and forced `lazyIndexed` body type behavior.
4. Static single-selection open-time visibility for a selected item near the end of a long list.
5. Static `scrollToSelectedOnOpen: false` preserves normal initial offset behavior.
6. Static search-hidden selected item preserves search and performs no jump.
7. Static multi-select jumps to the first selected visible row by row order.
8. Static confirmable multi-select opens using committed selection after cancelled staged changes.
9. Async cached data open-time visibility.
10. Async latest successful fetch open-time visibility after loading.
11. Async refreshing stale rows may jump when stale rows are rendered.
12. Async empty and error states remain direct and perform no jump.
13. Async cancelled and stale fetch completions perform no jump.
14. Async forced `eagerColumn` and forced `lazyIndexed` body type behavior.
15. Robot journey coverage for critical static and async user flows.
16. Documentation/example updates.

Baseline automated coverage outcomes:
- Logic coverage must verify target resolution by identity rules, including `keyOf`, `equals`, default equality, duplicate identities, and first-selected-visible row order.
- UI behavior coverage must verify eager and lazy body mode selection, selected-row visibility after open, no-op behavior when hidden by search/current results, and disabled selected row visibility.
- Async behavior coverage must verify cache hit, cache miss, loading, refreshing, empty, error, cancellation, stale generation, retry success, and no extra fetch for selected values.
- Critical journey coverage must verify at least one static long-list open and one async loaded-data open through robot-driven widget tests.
- Regression coverage must keep existing tests for selection, disabled rows, search, validation, clear, confirm/cancel, outside tap, Escape, controller open/close, cancellation, stale results, and paging behavior passing.

Testability seams:
- Use existing constructor injection and widget arguments rather than globals.
- Use controlled async fetchers with `Completer<List<T>>` for cache miss, loading, stale, cancellation, retry, and refreshing tests.
- Use `searchDebounce: Duration.zero` where debounce timing is not the behavior under test.
- Use stable `keyOf` values so item keys such as `dropify.item.item_90` are deterministic.
- Use bounded `pump` and `pumpAndSettle` strategies; avoid `runAsync` unless a specific limitation is documented.
- If target-index logic is extracted into an internal helper, cover it with focused unit tests; if it remains local, cover the same logic through widget behavior tests without adding public test-only API.

Robot testing requirements:
- Keep journey orchestration in `./test/journeys/dropify_menu_body_journey_test.dart` or another `./test/journeys/*_journey_test.dart` file.
- Keep interaction/assertion helpers in `./test/robots/dropify_robot.dart` unless the robot grows enough to justify a feature-specific robot file.
- Prefer `find.byKey` selectors for anchor, panel, search field, item keys, async state slots, and confirmable footer actions.
- Use `find.text` only when visible copy is the behavior being asserted.
- Add only selectors or robot helpers needed for declared journeys.
- Report residual journey risk in implementation handoff if robot journeys are skipped or cannot be made deterministic.

Required widget and public API tests:
- `DropifyMenuBodyMode` is exported from `package:dropify_flutter/dropify_flutter.dart`.
- Static and async raw/themed single and multi constructors expose `menuBodyMode` and `scrollToSelectedOnOpen` with correct defaults.
- Paginated widgets do not expose the new properties.
- Static automatic uses eager at filtered count 50 and lazy at filtered count 51.
- Static automatic uses filtered count, not source count, when search narrows a large source list.
- Static forced eager uses `SingleChildScrollView` above 50 rows.
- Static forced lazy uses `SuperListView` below or equal to 50 rows.
- Async automatic and forced lazy use `SuperListView` for loaded/refreshing rows.
- Async forced eager uses `SingleChildScrollView` for loaded/refreshing rows.
- Static single-select with initial value near the end of 100 rows opens with the selected row built and visible.
- Static lazy indexed list with initial value beyond the first viewport opens with the selected row built and visible.
- Multi-select opens with the first selected visible row built and visible by row order.
- Search filtering that hides the selected item preserves query text and does not build or reveal a fallback selected row.
- `scrollToSelectedOnOpen: false` does not jump to the selected item.
- Async cache hit opens with the selected row visible.
- Async fetch success after open makes the selected row visible after latest data renders.
- Async stale/cancelled fetch completion does not reveal stale selected rows or trigger jumps.
- Async empty/error direct states have no scrollbar row body and no jump.

Required robot journeys:
- Static long-list journey: pump a `DropifyDropdown` with at least 100 keyed entries and an initial selected value near the end, open through the robot, and assert the selected item key is visible while the panel stays open.
- Async loaded-data journey: pump a `DropifyAsyncDropdown` with a controlled fetcher returning at least 100 keyed items and an initial selected value near the end, open through the robot, complete the fetch, and assert the selected item key is visible.
- Existing journeys for static search/select, confirmable multi-select, async retry/select, and paginated search must continue to pass.

Verification commands:
- `flutter pub get`
- `dart format --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
</validation>

<illustrations>
Desired behavior examples:
- `DropifyDropdown(initialValue: 'item_90', entries: 100 items)` opens with `dropify.item.item_90` visible instead of starting at `item_0`.
- `DropifyDropdown.multi(initialValues: {'item_70', 'item_20'})` opens with `item_20` visible because it is the first selected item in row order.
- `RawStaticDropify(menuBodyMode: DropifyMenuBodyMode.lazyIndexed, entries: 10 items)` still uses lazy indexed rendering and can jump to the selected item.
- `DropifyAsyncDropdown(initialValue: 'Remote 90')` with cached current-query results opens and jumps after cached rows render.
- `DropifyAsyncDropdown(initialValue: 'Remote 90')` with a cache miss shows loading first, then jumps after the latest successful result containing `Remote 90` renders.

Counter-examples to avoid:
- Do not clear search text to reveal a selected item.
- Do not fetch async data solely to locate a selected item.
- Do not wrap loading, empty, error, idle, or no-results states in fake scroll row bodies.
- Do not keep calling jump logic every build.
- Do not add `scrollToSelectedOnOpen` or `menuBodyMode` to paginated widgets.
- Do not animate the open-time scroll in this implementation.
</illustrations>

<done_when>
The feature is complete when:
- Static and async dropdown public APIs expose `menuBodyMode` and `scrollToSelectedOnOpen` with documented defaults.
- `DropifyMenuBodyMode` is exported from the package entrypoint.
- Static and async themed widgets pass the new properties to raw widgets.
- Static automatic mode preserves the 50-row filtered threshold.
- Lazy static and async row bodies use `super_sliver_list` indexed rendering through `SuperListView.builder` unless a documented implementation constraint requires `SuperSliverList`.
- The private scroll shell owns and disposes the row `ScrollController` and lazy `ListController`.
- Eager row bodies can immediately bring selected row contexts into view after open.
- Lazy row bodies can immediately jump to selected row indexes after open, including indexes not initially built.
- Search-visible behavior is respected; hidden selected values cause no jump and no search mutation.
- Async scroll-to-selected runs only for rendered current row data and never triggers extra fetches.
- Paginated runtime behavior and public API are unchanged.
- README, relevant docs, dartdoc, and example app describe the new behavior and controls.
- Behavior-plus-type widget tests, public API tests, async edge tests, and robot journeys pass.
- `flutter pub get`, `dart format --set-exit-if-changed .`, `flutter analyze`, and `flutter test` pass.
</done_when>
