## Overview

Material-like Dropify panel/body refactor; keep raw architecture and lazy data modes.
Thin static slice first, then theme, async, paginated, journeys.

**Spec**: `ai_specs/003-dropify-flutter-alike-refactor-spec.md` (read this file for full requirements)

## Context

- **Structure**: layer-first Flutter package; `core`, `internal`, `theme`, `widgets`; themed wrappers over raw widgets.
- **State management**: local `StatefulWidget`, `FormField`, `MenuController`; no Riverpod/Bloc/Provider.
- **Reference implementations**: `lib/src/core/raw_dropify.dart`, `lib/src/internal/_dropify_panel.dart`, `lib/src/widgets/raw_paginated_dropify.dart`.
- **Discovery Notes**: `PagedListView` 5.1.1 accepts `scrollController`, `primary`, `physics`, `shrinkWrap`, `padding`; use shell controller, `primary: false`, `shrinkWrap: false`, `padding: EdgeInsets.zero`.
- **Discovery Notes**: smallest scroll shell: private `StatefulWidget`; owns `ScrollController`; builder receives controller; wraps `ScrollConfiguration`, `PrimaryScrollController`, `Scrollbar`.
- **Discovery Notes**: theme gaps: current tokens lack explicit `shadowColor`, `surfaceTintColor`, `shape`, `side`, `clipBehavior`; `panelElevation` exists; `panelDecoration` fallback remains.
- **Discovery Notes**: decoration fallback: simple color/radius/border maps to `Material`; gradients/images/blend/circle/arbitrary shadows use legacy transparent `Material` unless explicit fields override.
- **Discovery Notes**: stable keys present: `dropify.anchor`, `dropify.panel`, `dropify.search.field`, `dropify.search.clear`, `dropify.multi.footer`, `dropify.multi.cancel`, `dropify.multi.apply`, async/paging state keys.
- **Discovery Notes**: current dismissal via `TapRegion` and Escape `Shortcuts`; focus scope node passed but not wrapped; preserve behavior, do not expand keyboard scope.
- **Discovery Notes**: overlay placement: reserved padding `EdgeInsets.zero`; clamp `left` to overlay; prefer below; choose above only when below max height overflows and above space is larger; above top = `anchor.top - alignmentOffset.dy - panelHeight`.
- **Assumptions/Gaps**: no intentional visual default changes; README/dartdoc touched only if public theme fields added.

## Plan

### Phase 1: Static Slice (Complete)

- **Goal**: one public static dropdown proves panel, placement, shell, selection.
- [x] `lib/src/internal/_dropify_menu_scroll_shell.dart` - add private shell; owned controller; menu-like scroll config; visible scrollbar.
- [x] `lib/src/internal/_dropify_panel.dart` - real `Material`; sticky search/body/footer; preserved `dropify.panel`; current token fallback.
- [x] `lib/src/core/raw_dropify.dart` - overlay clamp; below/above max height; `matchAnchorWidth`; existing dismiss paths.
- [x] `lib/src/widgets/raw_static_dropify.dart` - filter first; `<= 50` eager shell; `> 50` lazy shell; no-results direct.
- [x] `test/widgets/dropify_static_dropdown_test.dart` - static slice coverage; small/large/filtered thresholds; disabled/selected semantics.
- [x] TDD: open searchable static dropdown -> constrained Material panel, sticky search, eager rows, select item, close.
- [x] TDD: 50 filtered rows eager; 51 filtered rows lazy; large source filtered small eager.
- [x] Robot journey tests + selectors/seams for static single-select via `dropify.anchor`, `dropify.search.field`, visible row labels.
- [x] Verify: `dart format . && flutter analyze && flutter test`

### Phase 2: Theme Compatibility

- **Goal**: Material chrome tokens without `panelDecoration` breakage.
- [ ] `lib/src/theme/dropify_theme_data.dart` - add needed fields; constructor, `copyWith`, `merge`, `lerp`, `fromMaterial`, dartdoc.
- [ ] `lib/src/internal/_dropify_panel.dart` - explicit token precedence; simple decoration mapping; legacy decoration fallback.
- [ ] `test/internal/dropify_panel_test.dart` - panel Material/theme assertions; padding, clip, sticky header/footer.
- [ ] `test/public_api_test.dart` - additive public theme field expectations if applicable.
- [ ] `README.md` - theming snippet only if fields added.
- [ ] TDD: explicit panel fields override conflicting `panelDecoration`.
- [ ] TDD: representable `panelDecoration` maps without double painting.
- [ ] TDD: non-representable decoration stays legacy when no explicit fields.
- [ ] Verify: `dart format . && flutter analyze && flutter test`

### Phase 3: Async Bodies

- **Goal**: async loaded/refreshing rows lazy; state bodies direct.
- [ ] `lib/src/widgets/raw_async_dropify.dart` - wrap data/refreshing lists in shell; controller into `ListView.builder`; direct idle/loading/empty/error.
- [ ] `test/widgets/dropify_async_dropdown_test.dart` - deterministic fetchers; cache, debounce, retry, cancellation, stale-result tests.
- [ ] `test/helpers/dropify_fixtures.dart` - completer-backed async fixtures.
- [ ] TDD: loaded async data uses lazy list shell; single/multi selection unchanged.
- [ ] TDD: refreshing keeps stale rows plus progress; loading/empty/error show no fake scrollbar.
- [ ] TDD: cancelled or older generation results never render.
- [ ] Robot journey tests + async seam via controlled `Completer`; open, loading, resolve, select, retry.
- [ ] Verify: `dart format . && flutter analyze && flutter test`

### Phase 4: Paginated Bodies

- **Goal**: `PagedListView` shell participation; caller-owned paging intact.
- [ ] `lib/src/widgets/raw_paginated_dropify.dart` - shell around `PagedListView`; pass `scrollController`; `primary: false`; zero padding; no nested scrollable.
- [ ] `test/widgets/dropify_paginated_dropdown_test.dart` - fetch, first/new page states, errors, no items, no more, search callback.
- [ ] `test/helpers/dropify_test_app.dart` - paginated harness with caller-owned `PagingState` transitions.
- [ ] TDD: opening defers first fetch and never mutates paging state internally.
- [ ] TDD: `fetchNextPage` remains caller-owned; delegate state builders still resolve.
- [ ] TDD: search calls `onSearchChanged`; caller resets/refetches.
- [ ] Robot journey tests + paginated seam via local harness; open, first load, next page, search.
- [ ] Verify: `dart format . && flutter analyze && flutter test`

### Phase 5: Non-Regression Journeys

- **Goal**: overlay, forms, multi-select, accessibility preserved end-to-end.
- [ ] `test/robots/dropify_robot.dart` - key-first helpers: open, search, select, apply, cancel, assert panel state.
- [ ] `test/journeys/dropify_menu_body_journey_test.dart` - static, async, paginated, confirmable multi-select journeys.
- [ ] `test/widgets/dropify_static_dropdown_test.dart` - confirmable cancel/apply; disabled rows; identity via `keyOf`/`equals`.
- [ ] `test/widgets/dropify_paginated_dropdown_test.dart` - outside tap, Escape, validation/controller non-regression where paginated risk exists.
- [ ] `test/helpers/dropify_fixtures.dart` - stable data and test-only row key builders where raw widgets expose builders.
- [ ] TDD: outside tap and Escape close without committing staged values.
- [ ] TDD: confirmable Cancel discards; Apply commits and calls `onChangedMulti`.
- [ ] TDD: horizontal clamp, above placement, `alignmentOffset`, `panelMaxHeight`, `matchAnchorWidth` preserved.
- [ ] Robot journey tests + selectors/seams for confirmable multi-select; text rows only where public themed widgets lack row-key seam.
- [ ] Verify: `dart format . && flutter analyze && flutter test`

## Risks / Out of scope

- **Risks**: Material defaults vs current visuals; `panelDecoration` compatibility; paginated scroll controller regressions.
- **Out of scope**: replace `RawDropify` with `MenuAnchor`; own `PagingController`; async/paginated eager rendering; new keyboard navigation scope.
