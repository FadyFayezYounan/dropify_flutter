<goal>
Refactor Dropify's dropdown panel and menu body internals so they follow Flutter Material `MenuAnchor` composition where appropriate, while preserving Dropify's static, async, and paginated data-loading models.

This matters for maintainers and package consumers because Dropify should feel native to Flutter Material menus without losing the dropdown-specific behavior that makes it useful for static lists, async search, paginated data, forms, and multi-select flows.

The outcome is an implementation-ready internal refactor. It must not introduce behavior regressions, public API breaks, pagination ownership changes, or eager rendering for async and paginated data.
</goal>

<background>
Project: `dropify_flutter`, a Flutter package with Dart 3.10.3 constraints and Flutter `>=3.27.0`.

Primary dependency relevant to this work: `infinite_scroll_pagination: ^5.1.1`.

Current architecture to preserve:
- `RawDropify` owns anchor, overlay placement, available-height constraints, search text, selection, validation, controller integration, and the panel slot.
- `DropifyPanel` owns dropdown panel chrome, optional search header, body slot, and optional confirm/cancel footer.
- `RawStaticDropify` owns in-memory filtering and static row rendering.
- `RawAsyncDropify` owns async fetch state, debounce, cache, cancellation, stale-result protection, and async row rendering.
- `RawPaginatedDropify` owns paginated row rendering while callers own `PagingState<PageKey, T>` and `fetchNextPage`.

Flutter reference behavior:
- `refrences/flutter_menu_anchor.dart` `_MenuPanel` resolves `MenuStyle` values, builds a `Material` surface, applies padding, wraps menu content in `ScrollConfiguration`, `PrimaryScrollController`, `Scrollbar(thumbVisibility: true)`, and `SingleChildScrollView + Flex`.
- Flutter uses `SingleChildScrollView + Flex` because `MenuAnchor.menuChildren` is a static `List<Widget>`.
- Dropify must copy the panel chrome and scroll configuration where useful, but must not force async, paginated, or large static result sets into eager `Column` rendering.

Files to examine before implementation:
- `./ai_specs/003-dropify-flutter-alike-refactor.md`
- `./specs/002-flutter-dropify/plan.md`
- `./refrences/flutter_menu_anchor.dart`
- `./refrences/flutter_raw_menu_anchor.dart`
- `./refrences/flutter_dropdown_menu.dart`
- `./lib/src/core/raw_dropify.dart`
- `./lib/src/internal/_dropify_panel.dart`
- `./lib/src/internal/_dropify_anchor.dart`
- `./lib/src/internal/_dropify_search_field.dart`
- `./lib/src/widgets/raw_static_dropify.dart`
- `./lib/src/widgets/raw_async_dropify.dart`
- `./lib/src/widgets/raw_paginated_dropify.dart`
- `./lib/src/theme/dropify_theme.dart`
- `./lib/src/theme/dropify_theme_data.dart`
- `./lib/dropify_flutter.dart`
- `./test/widgets/dropify_paginated_dropdown_test.dart`
- `./test/internal/dropify_internal_test.dart`
- `./test/helpers/dropify_test_app.dart`
- `./test/helpers/dropify_fixtures.dart`
</background>

<discovery>
Before editing, examine thoroughly and document implementation decisions in a named `Discovery Notes` section in the implementation plan.

Questions to answer through code inspection:
1. Confirm which `PagedListView<PageKey, T>` constructor parameters are available in `infinite_scroll_pagination: ^5.1.1`, especially whether it accepts a `ScrollController` or can participate in `PrimaryScrollController` without a nested scrollable.
2. Identify the smallest private widget shape for the shared scroll shell. Prefer one private StatefulWidget that owns a `ScrollController` and accepts a builder receiving that controller.
3. Identify which Material-like panel fields cannot be represented cleanly by current `DropifyThemeData` tokens.
4. Confirm whether current `panelDecoration` usages can remain a fallback without double-painting background, border, radius, or shadow.
5. Confirm all existing stable keys and semantics used by tests and examples before adding selectors.
6. Confirm current behavior for outside tap, Escape dismissal, focus, validation, staged multi-select cancel/apply, and search debounce before refactoring.
7. Define exact overlay placement behavior before implementation: horizontal clamping, below/above placement, available panel height, reserved viewport padding, and how `alignmentOffset` applies when the panel is placed above the anchor.
8. Record discovery decisions in a named `Discovery Notes` section in the implementation plan before Phase 2 starts.

Discovery constraints:
1. Do not depend on Flutter private APIs or copied private default classes at runtime.
2. Use Flutter reference files as design guidance only.
3. Keep the smallest correct refactor. Do not add broad abstractions unless they remove real duplication across static, async, and paginated bodies.
</discovery>

<user_flows>
Primary flow:
1. A user opens a Dropify dropdown from the anchor.
2. The overlay appears anchored from the existing `RawMenuAnchor` anchor position and respects `matchAnchorWidth`, `alignmentOffset`, `useRootOverlay`, and panel constraints where the widget API exposes those controls.
3. If search is enabled, the search field stays visible above the scrollable row body.
4. The user scrolls rows using platform-appropriate clamping behavior with a visible scrollbar thumb.
5. In single-select mode, tapping an enabled item selects it, updates form state, calls `onChanged`, and closes the panel.
6. In non-confirmable multi-select mode, tapping enabled items toggles selection immediately and keeps the panel open.
7. In confirmable multi-select mode, tapping enabled items stages selection changes, Apply commits them and closes, and Cancel closes without committing staged changes.

Alternative flows:
- Static small filtered set: after search filtering, `filtered.length <= 50` renders rows eagerly with `SingleChildScrollView + Column` through the shared scroll shell.
- Static large filtered set: after search filtering, `filtered.length > 50` renders rows lazily with `ListView.builder` through the shared scroll shell.
- Static large source with small search result: use the filtered count, not source count, so a 100-item source filtered to 2 rows uses the eager Flutter-like path.
- Async loading: opening or searching can show the resolved loading builder as a direct constrained panel body state.
- Async loaded data: loaded rows render lazily with `ListView.builder` through the shared scroll shell.
- Async refreshing: stale rows remain visible in a lazy list while the lightweight progress indicator remains over the row body.
- Async empty: the resolved empty builder renders directly as a constrained panel body state with no fake scrollbar.
- Async error: the resolved error builder renders directly and retry triggers the existing fetch path.
- Paginated first page: `PagedListView<PageKey, T>` owns paging presentation and triggers caller-owned `fetchNextPage` through the existing contract.
- Paginated search: `onSearchChanged` remains the hook for callers to reset paging state and refetch.
- Themed widgets: `DropifyDropdown`, `DropifyAsyncDropdown`, and `DropifyPaginatedDropdown` keep routing through raw widgets and the shared panel behavior.
- Raw widgets: callers using raw variants keep their public constructor behavior and anchor/body contracts.

Error flows:
- Async fetch failure: show the resolved error builder, expose retry, and do not commit stale failed data into current results.
- Async stale result: late results from cancelled or older generations are ignored.
- Paginated first-page error: show the resolved first-page error builder from `PagedChildBuilderDelegate` and retry through caller-owned `fetchNextPage`.
- Paginated new-page error: keep already loaded rows visible and show the resolved new-page error builder.
- No static matches: show the resolved no-results builder as a direct constrained body state.
- Outside tap: close the panel using the existing `TapRegion` and `RawMenuAnchor` behavior.
- Escape key: close the panel through the existing `Shortcuts`/`Actions` dismissal path.
- Narrow viewport or tight constraints: keep the panel constrained within the overlay; do not let sticky header/footer force body overflow.
</user_flows>

<requirements>
**Functional:**
1. Preserve the layered architecture: `RawDropify` remains the anchor/overlay/selection/search/form owner, `DropifyPanel` remains the panel chrome owner, and each specialized raw widget remains responsible for its data mode.
2. Keep the overlay anchored through the existing `RawMenuAnchor`-based architecture. Do not replace `RawDropify` with Flutter's public `MenuAnchor`.
3. Keep `matchAnchorWidth` default behavior because Dropify is dropdown-oriented, not general menu-oriented.
4. Keep `panelConstraints` and `DropifyThemeData.panelMaxHeight` as the outer panel height constraint mechanism for compatibility. The scrollable body receives the remaining height after panel padding, the sticky search header, and the sticky footer are laid out.
5. Refactor `DropifyPanel` to use a real `Material` surface for the dropdown panel chrome instead of `Material(type: MaterialType.transparency)` plus `DecoratedBox` as the only surface.
6. Resolve panel background/color, elevation, shadow color, surface tint color, shape, side/border, padding, and clip behavior from `DropifyThemeData` and Material defaults while preserving current Dropify visual defaults unless an intentional default change is explicitly documented and covered by focused tests or goldens.
7. Add public `DropifyThemeData` fields only when current fields cannot represent Material-like menu chrome cleanly.
8. When new Material-like panel fields and `panelDecoration` are both provided, new explicit fields win. `panelDecoration` remains supported as a compatibility fallback with this mapping: `panelDecoration.color` maps to Material color; rectangular border radius plus border maps to a rounded shape plus side; simple border-only decoration maps to side; gradients, images, background blend modes, arbitrary box shadows, and non-rectangular `BoxShape.circle` decorations must not be silently double-painted with Material color, border, or shadow. If a caller relies on non-representable `panelDecoration` fields and no explicit Material-like panel fields are provided, preserve legacy decoration rendering with a transparent/no-elevation Material wrapper. If explicit Material-like panel fields are provided, ignore conflicting non-representable `panelDecoration` paint fields and document that explicit fields supersede them.
9. Preserve current theme resolution order. Instance arguments win where a widget exposes an instance-level override, then `DropifyTheme.of(context)`, then `ThemeData.extension<DropifyThemeData>()`, then `DropifyThemeData.fromMaterial(Theme.of(context))`.
10. Do not remove existing `DropifyThemeData` tokens, even if new explicit panel tokens are added. Every new `DropifyThemeData` field must be wired through the constructor, `copyWith`, `merge`, `lerp`, `fromMaterial`, README/dartdoc coverage, and focused tests.
11. Keep search as a sticky header above the row body for static, async, and paginated modes.
12. Keep confirm/cancel as a sticky footer below the row body for confirmable multi-select.
13. Create a shared private scroll shell that applies Flutter-menu-like row-list behavior: `ScrollConfiguration.of(context).copyWith(scrollbars: false, overscroll: false, physics: const ClampingScrollPhysics())`, `PrimaryScrollController`, and `Scrollbar(thumbVisibility: true)`.
14. The shared scroll shell must own and dispose its `ScrollController` and pass it to a body builder so each supported scrollable uses the same controller as the `Scrollbar` and `PrimaryScrollController`.
15. The shared scroll shell applies to row-list bodies only. Do not wrap loading, empty, error, or no-results direct body states in a fake scrollable.
16. Do not introduce nested vertical scrollables. The shell may wrap `ScrollConfiguration`, `PrimaryScrollController`, and `Scrollbar`, but it must not wrap lazy bodies in `SingleChildScrollView`.
17. Static mode must filter entries before choosing a renderer.
18. Static mode must use `filtered.length <= 50` for the eager Flutter-like path.
19. Static mode must use `SingleChildScrollView + Column` for filtered static results of 50 rows or fewer.
20. Static mode must use `ListView.builder` for filtered static results above 50 rows.
21. Static mode must preserve disabled entry behavior, selected state, semantics, single-select behavior, immediate multi-select behavior, confirmable multi-select staging, and resolved no-results builder behavior.
22. Lazy `ListView.builder` row bodies must receive the shell-owned controller, use `padding: EdgeInsets.zero`, avoid primary-controller conflicts when an explicit controller is provided, and use `shrinkWrap: false` inside the bounded panel body unless implementation research documents a necessary exception.
23. Async mode must continue using lazy `ListView.builder` for loaded rows and refreshing stale rows.
24. Async mode must preserve `DropifyAsyncState` transitions: idle, loading, refreshing with stale items, data, empty, and error.
25. Async mode must preserve debounce, cache, cancellation token disposal, generation-based stale-result protection, and retry behavior.
26. Async mode must preserve instance/theme/default resolution for loading, empty, and error builders.
27. Paginated mode must continue using `PagedListView<PageKey, T>` from `infinite_scroll_pagination` for the panel body.
28. Paginated mode must keep accepting caller-owned `PagingState<PageKey, T>` and caller-owned `fetchNextPage`.
29. Paginated mode must not introduce internal `PagingController` ownership.
30. Paginated mode must keep `onSearchChanged` as the hook for callers to reset paging state and refetch.
31. Paginated mode must preserve first-page loading, new-page loading, first-page error, new-page error, no-items, and no-more-items builder resolution through the package delegate.
32. Paginated mode must use the shared scroll configuration as far as `PagedListView` supports without nesting another vertical scrollable. In `infinite_scroll_pagination: ^5.1.1`, prefer passing the shell-owned controller through `scrollController`, set zero padding, avoid primary-controller conflicts, and keep `shrinkWrap: false` unless implementation research documents a necessary exception.
33. Preserve public imports through `package:dropify_flutter/dropify_flutter.dart`.
34. Preserve selection identity semantics through `keyOf` and `equals`.
35. Preserve validation behavior, `FormField` reset behavior, clear behavior, controller open/close state, `onOpen`, and `onClose` behavior.
36. Preserve outside tap dismissal, Escape dismissal, focus handling, and scroll-aware overlay behavior.
37. `RawDropify` overlay placement must use `RawMenuOverlayInfo.overlaySize` to keep the panel within the overlay bounds. Horizontally clamp the panel within the overlay. Vertically prefer below-anchor placement, but reduce available panel height or place above the anchor when below-anchor space would overflow and above-anchor space is better. Apply `alignmentOffset` consistently for the chosen placement direction.
38. Do not expand keyboard navigation scope beyond existing Dropify contracts in this refactor, but do not regress any existing keyboard or focus behavior.

**Error Handling:**
39. If async fetch throws, render the resolved error builder directly in the constrained body and keep retry wired to the current query.
40. If async fetch completes after cancellation, disposal, or generation mismatch, ignore the result and do not call `setState` with stale data.
41. If paginated first-page or new-page loading fails, keep using the current `PagedChildBuilderDelegate` error builders and caller-owned retry path.
42. If a caller provides a custom state builder that is larger than panel constraints, the panel must remain constrained and clip or layout safely according to resolved panel clip behavior.
43. If theme fields conflict, explicit Material-like fields win over `panelDecoration`; unresolved fields fall back to `panelDecoration` where possible, then Material defaults.
44. If implementation research finds a `PagedListView` controller limitation, preserve paging correctness and avoid nested scrollables rather than forcing identical controller wiring.

**Edge Cases:**
45. `filtered.length == 0` renders no-results directly, not inside the row-list scroll shell.
46. `filtered.length == 50` uses `SingleChildScrollView + Column`.
47. `filtered.length == 51` uses `ListView.builder`.
48. A source list over 50 items filtered to 50 or fewer rows uses the eager path.
49. A source list under or equal to 50 items filtered to more than 50 rows is impossible from in-memory filtering, but renderer selection must still use `filtered.length` for clarity.
50. Switching between eager and lazy static renderers during search must not crash, leak controllers, or leave stale selected state.
51. Empty async results with an empty query and empty async results with a non-empty query must preserve the existing `hasQuery` distinction.
52. Async refreshing must keep stale rows visible until the new request succeeds, fails, or is superseded.
53. Confirmable multi-select Cancel must discard staged values and close the panel.
54. Confirmable multi-select Apply must commit staged values, update form state, call `onChangedMulti`, and close the panel.
55. Static disabled rows must remain non-interactive and visually/semantically disabled across both static body renderers. Async and paginated disabled-item modeling remains caller-owned through custom item builders and is not expanded by this refactor.
56. Scrollbars must not appear for direct loading, empty, error, or no-results states.
57. Search header and footer must not scroll with rows.
58. The refactor must remain safe on Android, iOS, web, macOS, Windows, and Linux Flutter targets.

**Validation:**
59. Implementation must follow behavior-first vertical-slice TDD: write one failing test, make the minimal implementation pass, refactor only after green, then repeat.
60. Tests must exercise public or package-level widget behavior, not private implementation details, except where internal widgets already have package-internal tests.
61. Widget robot journeys must use stable key-first selectors for controls and exposed seams; themed public row journeys may use visible text when no row-key seam exists and the visible label is part of the asserted behavior.
62. Add only selectors needed by declared tests. Do not over-instrument every widget.
</requirements>

<boundaries>
Edge cases:
- Static threshold boundary: 50 filtered rows is eager; 51 filtered rows is lazy.
- Dynamic filtering: renderer choice may change as the query changes; selection state and staged multi-select state must remain correct.
- Direct state bodies: loading, empty, error, and no-results states are constrained by the panel but are not wrapped in the row-list scroll shell.
- Paginated delegate states: first-page/new-page progress, error, no-items, and no-more-items remain inside `PagedListView` because the pagination package owns that presentation model.
- Theme compatibility: existing `panelDecoration` remains honored as fallback, but new explicit Material-like fields override it.
- Custom builders: custom row/state builders may be taller than expected; panel constraints and clip behavior must prevent overflow outside the overlay bounds.

Error scenarios:
- Async cancellation: cancelled requests never render stale rows or errors.
- Async retry: retry uses the current query and current cancellation generation.
- Paging error: retry remains caller-owned through `fetchNextPage`; Dropify must not mutate paging state internally.
- Unsupported controller wiring in `PagedListView`: do not add nested scrollables to force parity; keep paging behavior correct and document the limitation.
- Overlay dismissal: outside tap and Escape must close without applying staged confirmable multi-select changes.

Limits:
- Static eager rendering limit: 50 filtered rows.
- Async data size: unbounded from Dropify's perspective, so loaded rows remain lazy.
- Paginated data size: unbounded from Dropify's perspective, so `PagedListView` remains mandatory.
- Public API expansion: additive `DropifyThemeData` fields are allowed only when needed for Material-like panel chrome. No removals or breaking constructor changes are allowed.
- Disabled async/paginated row API: out of scope for this refactor unless a separate API spec explicitly adds enabled-state modeling for those modes.
- Test infrastructure: use `flutter_test` widget robot journeys, not `integration_test`, unless a future separate spec expands validation scope.
</boundaries>

<implementation>
Expected source outputs:
- Modify `./lib/src/core/raw_dropify.dart` to keep RawMenuAnchor ownership while deriving panel placement and available-height constraints from `RawMenuOverlayInfo.overlaySize`.
- Modify `./lib/src/internal/_dropify_panel.dart` to build Material-like panel chrome, sticky header/body/footer layout, panel constraints, and resolved panel surface values.
- Create `./lib/src/internal/_dropify_menu_scroll_shell.dart` for the private row-list scroll shell that owns a `ScrollController` and exposes it to a body builder.
- Modify `./lib/src/widgets/raw_static_dropify.dart` so filtering happens before renderer selection and `filtered.length` controls the eager/lazy threshold.
- Modify `./lib/src/widgets/raw_async_dropify.dart` so loaded and refreshing rows use the shared scroll shell with `ListView.builder`, while idle/loading/empty/error direct states stay outside the shell.
- Modify `./lib/src/widgets/raw_paginated_dropify.dart` so `PagedListView` participates in the shared scroll configuration without nested vertical scrollables and without Dropify-owned paging state.
- Modify `./lib/src/theme/dropify_theme_data.dart` only if explicit Material-like panel fields are needed. Candidate fields include panel color/background, shadow color, surface tint color, shape, side/border, clip behavior, and scrollbar visibility/styling if implementation research proves it necessary. Any new fields must be wired through constructor, `copyWith`, `merge`, `lerp`, and `fromMaterial`.
- Modify `./lib/src/theme/dropify_theme.dart` only if theme resolution needs to support new fields while preserving existing merge behavior.
- Modify `./lib/dropify_flutter.dart` only if new public types are introduced. New fields on `DropifyThemeData` do not need export changes.
- Update `./README.md` and dartdoc only if public theme fields are added.

Expected test outputs:
- Add or extend `./test/widgets/dropify_static_dropdown_test.dart` for static small/large/filtered-threshold behavior.
- Add or extend `./test/widgets/dropify_async_dropdown_test.dart` for async row lists and direct state bodies.
- Extend `./test/widgets/dropify_paginated_dropdown_test.dart` for paginated scroll configuration, fetch, search, and delegate states.
- Add or extend `./test/internal/dropify_panel_test.dart` for panel Material/theme/chrome behavior if package-internal assertions are needed.
- Add `./test/robots/dropify_robot.dart` for key-first widget robot helpers.
- Add `./test/journeys/dropify_menu_body_journey_test.dart` for critical dropdown journeys through public widgets.
- Add or extend `./test/helpers/dropify_test_app.dart` and `./test/helpers/dropify_fixtures.dart` only for deterministic harness data, fake async fetchers, fake paginated state, and stable row keys used by tests.

Patterns to use:
- Prefer small private widget classes over large build helper functions when introducing reusable UI structure.
- Keep the scroll shell private and internal; do not expose it publicly.
- Use constructor-provided builders and fake data in tests rather than mocking internals.
- Prefer deterministic `Completer`, `fake_async`, explicit `pump`, and bounded `pumpAndSettle` strategies over `runAsync`.
- Use stable `ValueKey<String>` selectors already present where possible: `dropify.panel`, `dropify.anchor`, `dropify.search.field`, `dropify.search.clear`, `dropify.multi.footer`, `dropify.multi.cancel`, `dropify.multi.apply`, async/paging state keys.
- For row-specific journeys through raw widgets, prefer test-only custom item builders that assign stable keys rather than adding production keys to every row.
- For themed public-widget journeys that do not expose row builders, use visible text finders only when the visible label is part of the asserted behavior. Do not rely on production `hashCode`-based row keys as stable selectors.

What to avoid:
- Do not replace `RawDropify` or its overlay with Flutter's public `MenuAnchor`.
- Do not copy Flutter private classes into runtime code.
- Do not wrap `ListView.builder` or `PagedListView` in `SingleChildScrollView`.
- Do not make async results eager with `Column`.
- Do not make paginated results use `SingleChildScrollView`.
- Do not make Dropify own `PagingController` or mutate caller-owned paging state.
- Do not remove static large-list lazy behavior.
- Do not introduce public API breaks.
- Do not add broad abstractions for hypothetical future modes.
</implementation>

<stages>
Phase 1: Discovery and test scaffolding.
Verify by documenting `PagedListView` controller support, current theme fallback behavior, current stable keys, overlay placement decisions, panel height semantics, and the minimal scroll-shell shape in a named `Discovery Notes` plan section before implementation starts.

Phase 2: Panel Material chrome and theme resolution.
Verify with one failing widget/internal test at a time for Material surface behavior, explicit-token precedence over `panelDecoration`, fallback compatibility, padding, constraints, clip behavior, and sticky header/footer layout.

Phase 3: Shared row-list scroll shell.
Verify with tests that row lists get menu-like `ScrollConfiguration`, `PrimaryScrollController`, and `Scrollbar(thumbVisibility: true)`, and that direct state bodies do not get fake scrollbars.

Phase 4: Static body renderer selection.
Verify with tests for no-results direct state, 50-row eager path, 51-row lazy path, large source filtered to small eager path, disabled rows, selected state, and confirmable multi-select behavior.

Phase 5: Async body renderer preservation.
Verify with tests for loading, data, refreshing stale rows with overlay progress, empty, error/retry, cache, cancellation, stale-result protection, and single/multi selection.

Phase 6: Paginated body preservation.
Verify with tests for `PagedListView`, caller-owned `PagingState`, `fetchNextPage`, first/new page delegate builders, `onSearchChanged`, and no nested scrollable wrapping.

Phase 7: Widget robot journeys and quality gates.
Verify public-widget journeys for static, async, paginated, and confirmable multi-select flows. Run formatting, analysis, and the full test suite.
</stages>

<illustrations>
Desired static renderer behavior:
```text
entries.length = 100
search query = "abc"
filtered.length = 2
renderer = SingleChildScrollView + Column
```

Counter-example to avoid:
```text
entries.length = 100
search query = "abc"
filtered.length = 2
renderer = ListView.builder only because source list is large
```

Desired async renderer behavior:
```text
state = DropifyAsyncData(items: 500 items)
renderer = shared scroll shell + ListView.builder
```

Counter-example to avoid:
```text
state = DropifyAsyncData(items: 500 items)
renderer = SingleChildScrollView + Column
```

Desired paginated renderer behavior:
```text
state = caller-owned PagingState<PageKey, T>
renderer = shared scroll configuration + PagedListView<PageKey, T>
fetch = caller-owned fetchNextPage
```

Counter-example to avoid:
```text
Dropify creates PagingController internally or wraps PagedListView in SingleChildScrollView
```

Desired theme precedence when both explicit tokens and `panelDecoration` are provided:
```text
explicit panel color/shape/elevation/clip fields win
panelDecoration fills only unresolved fallback values
Material defaults fill remaining values
```
</illustrations>

<validation>
Use vertical-slice TDD for implementation. For each behavior increment, write exactly one failing test first, run it and confirm RED, implement the minimum code to pass, run the relevant tests to confirm GREEN, refactor only while green, then continue.

Behavior-first test ordering:
1. Panel chrome happy path: opening a dropdown renders a constrained Material panel with sticky search/body/footer layout.
2. Theme precedence edge: explicit Material-like theme fields override `panelDecoration`; `panelDecoration` remains fallback when explicit fields are absent.
3. Scroll shell happy path: a row list uses the shell-owned controller with `PrimaryScrollController`, visible `Scrollbar`, clamping physics, and disabled automatic scrollbars/overscroll.
4. Static happy path: filtered small list renders and scrolls with the eager Flutter-like path.
5. Static threshold edges: 50 filtered rows eager, 51 filtered rows lazy, large source filtered to small eager.
6. Static error/edge states: no-results direct body, disabled row semantics, selected row state, confirmable cancel/apply.
7. Async happy path: loaded data renders lazily and selection behavior is preserved.
8. Async edge states: loading, refreshing stale rows, empty with/without query, error/retry, cache hit.
9. Async error safety: cancellation and generation mismatch prevent stale results from rendering.
10. Paginated happy path: `PagedListView` renders loaded rows and triggers caller-owned `fetchNextPage`.
11. Paginated edge states: first-page loading, new-page loading, first-page error, new-page error, no-items, no-more-items, search callback ownership.
12. Overlay non-regression: outside tap, Escape close, focus handling, validation, controller open/close, and `matchAnchorWidth` still work.

Required unit/widget coverage outcomes:
- Logic/state coverage proves selection identity through `keyOf` and `equals` still works after renderer changes.
- Widget coverage proves panel chrome, theme precedence, constraints, sticky header/footer, row-list scroll shell, and direct state bodies.
- Async coverage proves debounce/cancellation/stale-result behavior with deterministic fakes or `Completer` control.
- Paginated coverage proves caller-owned state remains the only paging source of truth.
- Accessibility coverage proves static disabled semantics and selected semantics do not regress.

Required widget robot journeys:
- Static single-select journey: pump public `DropifyDropdown`, open via anchor, search, see filtered rows, select one enabled row, verify value text and panel close.
- Static confirmable multi-select journey: open `DropifyDropdown.multi`, select multiple rows by visible label or stable raw-widget test keys, Cancel discards staged values, reopen, select rows, Apply commits values and closes.
- Async journey: pump public `DropifyAsyncDropdown` with deterministic fake fetcher, open, observe loading, complete data, select row, then exercise error and retry in a separate focused journey or test.
- Paginated journey: pump public `DropifyPaginatedDropdown` with deterministic caller-owned `PagingState`, open, verify deferred first load, scroll or trigger near-end fetch, verify new page rows, type search, and verify `onSearchChanged` is called without Dropify mutating state.

Robot test structure:
- Put high-level journeys in `./test/journeys/dropify_menu_body_journey_test.dart`.
- Put interaction helpers in `./test/robots/dropify_robot.dart`.
- Keep harness and deterministic data in `./test/helpers/dropify_test_app.dart` and `./test/helpers/dropify_fixtures.dart`, or add `./test/harness/` only if helpers become too large.
- Journey tests should call robot methods such as `openDropdown`, `enterSearch`, `selectItem`, `applyMultiSelect`, `cancelMultiSelect`, `expectPanelOpen`, and `expectPanelClosed`.
- Prefer `find.byKey` selectors for stable controls. Use text finders for themed row labels when the themed widget does not expose a row-key seam and visible copy is part of the behavior under test.

Required deterministic seams:
- Async fetchers must be fake functions controlled by `Completer` or deterministic immediate futures.
- Async cancellation tests must control completion order explicitly.
- Paginated tests must use a local harness that exposes caller-owned `PagingState` transitions.
- Debounce tests should use `fake_async` where practical.
- Use bounded `pump` and `pumpAndSettle`; use `runAsync` only with an explicit comment explaining why deterministic seams were not possible.

Quality gates:
- Run `dart format .`.
- Run `dart analyze`.
- Run `flutter test`.
- If public `DropifyThemeData` fields are added, verify constructor, `copyWith`, `merge`, `lerp`, `fromMaterial`, dartdoc/README coverage, and public API export expectations.
- If Material-like defaults intentionally change current Dropify visual defaults, cover the accepted changes with focused tests or goldens.
- If golden tests already exist for relevant themed panel visuals at implementation time, update or add focused goldens for Material 3-compatible defaults. Do not introduce a broad golden suite solely for this refactor unless the plan explicitly calls for it.
</validation>

<done_when>
1. `DropifyPanel` uses Material-like panel chrome with resolved theme/default values and sticky header/body/footer layout.
2. Explicit Material-like panel theme fields, if added, override `panelDecoration`; `panelDecoration` remains a compatibility fallback.
3. A shared private row-list scroll shell applies Flutter-menu-like scroll configuration, controller wiring, and visible scrollbar behavior without nested vertical scrollables.
4. Static mode chooses eager vs lazy rendering from `filtered.length`, with `<= 50` eager and `> 50` lazy.
5. Async loaded and refreshing rows remain lazy, and async loading/empty/error states remain direct constrained body states.
6. Paginated mode continues to use `PagedListView<PageKey, T>` with caller-owned `PagingState` and `fetchNextPage`.
7. Search header and confirmable multi-select footer remain outside the scrollable row body.
8. Outside tap, Escape dismissal, focus, validation, selection identity, controller behavior, disabled state, selected state, and semantics do not regress.
9. Public imports remain through `package:dropify_flutter/dropify_flutter.dart`.
10. No public API break is introduced.
11. Required TDD-driven unit/widget tests and widget robot journeys are present and passing.
12. `dart format .`, `dart analyze`, and `flutter test` pass.
</done_when>
