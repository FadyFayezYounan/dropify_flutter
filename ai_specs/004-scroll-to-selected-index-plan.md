## Overview

Open-time jump to selected visible row for static and async dropdowns.
Add body-mode API, shell-owned indexed lazy scrolling, docs/tests.

**Spec**: `ai_specs/004-scroll-to-selected-index-spec.md` (read this file for full requirements)

## Context

- **Structure**: Layered package; `core`, `internal`, `widgets`, `theme`; curated `lib/dropify_flutter.dart` exports.
- **State management**: Widget-owned `State`, `DropifyController`, `DropifyPanelState`; no Riverpod/Bloc/Provider.
- **Reference implementations**: `lib/src/widgets/raw_static_dropify.dart`, `lib/src/widgets/raw_async_dropify.dart`, `lib/src/internal/_dropify_menu_scroll_shell.dart`.
- **Reference tests**: `test/widgets/dropify_static_dropdown_test.dart`, `test/widgets/dropify_async_dropdown_test.dart`, `test/journeys/dropify_menu_body_journey_test.dart`.
- **Assumptions/Gaps**: `SuperListView.builder` supports shell `ScrollController` + `ListController`; prefer existing shell extension; no `RawDropify` API change unless lifecycle guard requires it.

## Plan

### Phase 1: Static Vertical Slice

- **Goal**: Public API + static lazy selected-row jump.
- [x] `pubspec.yaml` - add `super_sliver_list`.
- [x] `pubspec.lock` - refresh resolution.
- [x] `lib/src/core/dropify_menu_body_mode.dart` - enum + dartdoc.
- [x] `lib/dropify_flutter.dart` - export enum.
- [x] `lib/src/internal/_dropify_menu_scroll_shell.dart` - own `ScrollController` + `ListController`; expose private builder args.
- [x] `lib/src/widgets/raw_static_dropify.dart` - add `menuBodyMode`, `scrollToSelectedOnOpen`; static single lazy path.
- [x] `lib/src/widgets/dropify_dropdown.dart` - pass static public properties through.
- [x] TDD: enum export + static raw/themed single defaults -> public API compiles.
- [x] TDD: 100 static rows, initial value near end, lazy body opens with selected key visible -> indexed jump.
- [x] Verify: `flutter pub get && dart format --set-exit-if-changed . && flutter analyze && flutter test`

### Phase 2: Static Matrix

- **Goal**: Static modes, target rules, guarded no-ops.
- [x] `lib/src/widgets/raw_static_dropify.dart` - automatic/eager/lazy selection from filtered rows.
- [x] `lib/src/widgets/raw_static_dropify.dart` - eager row keys aligned to visible rows.
- [x] `lib/src/widgets/raw_static_dropify.dart` - selected target by `DropifySelectionIdentity`; single + multi row order.
- [x] `lib/src/widgets/raw_static_dropify.dart` - post-frame scheduling; one bounded retry; mounted/open/index/current-selection guards.
- [x] `lib/src/widgets/dropify_dropdown.dart` - static multi pass-through + dartdoc.
- [x] `test/widgets/dropify_static_dropdown_test.dart` - extend focused widget coverage.
- [x] TDD: automatic uses eager at 50 and lazy at 51 -> filtered count threshold.
- [x] TDD: forced eager above 50 and forced lazy below 50 -> body widget type.
- [x] TDD: static raw/themed multi defaults -> public API compiles.
- [x] TDD: `scrollToSelectedOnOpen: false` -> normal initial offset.
- [x] TDD: search hides selected item -> query preserved, no jump.
- [x] TDD: disabled selected row + duplicate identity + `keyOf`/`equals` -> first visible match.
- [x] TDD: multi + confirmable cancel/reopen -> committed first visible selected row.
- [x] Verify: `dart format --set-exit-if-changed . && flutter analyze && flutter test`

### Phase 3: Async Vertical Slice

- **Goal**: Async body modes + loaded-data selected jump.
- [ ] `lib/src/widgets/raw_async_dropify.dart` - add `menuBodyMode`, `scrollToSelectedOnOpen`.
- [ ] `lib/src/widgets/dropify_async_dropdown.dart` - pass async public properties through + dartdoc.
- [ ] `lib/src/widgets/raw_async_dropify.dart` - loaded/refreshing eager or `SuperListView.builder`; direct states unchanged.
- [ ] `lib/src/widgets/raw_async_dropify.dart` - target resolution from currently rendered items only.
- [ ] `lib/src/widgets/raw_async_dropify.dart` - cache-hit and latest-success row generation scheduling.
- [ ] `test/public_api_test.dart` - async raw/themed single+multi defaults.
- [ ] `test/widgets/dropify_async_dropdown_test.dart` - async focused widget coverage.
- [ ] TDD: async automatic/lazy loaded rows use `SuperListView` -> selected row visible after fetch.
- [ ] TDD: async forced eager loaded rows use `SingleChildScrollView` -> selected row visible.
- [ ] TDD: cache hit opens with selected row visible -> no extra fetch.
- [ ] TDD: paginated constructors unchanged -> analyzer guards exclusion.
- [ ] Verify: `dart format --set-exit-if-changed . && flutter analyze && flutter test`

### Phase 4: Async Edges

- **Goal**: Cancellation, stale data, direct states safe.
- [ ] `lib/src/widgets/raw_async_dropify.dart` - refreshing stale rows valid generation while rendered.
- [ ] `lib/src/widgets/raw_async_dropify.dart` - cancelled/stale/failed/empty/loading skip scheduling.
- [ ] `lib/src/widgets/raw_async_dropify.dart` - retry success may schedule only latest rendered data.
- [ ] `test/widgets/dropify_async_dropdown_test.dart` - controlled `Completer` fetch paths.
- [ ] TDD: cache miss loads then jumps after latest success -> selected row visible.
- [ ] TDD: refreshing stale rows may jump; replacement without selected item does not.
- [ ] TDD: stale/cancelled completions -> no stale selected row revealed.
- [ ] TDD: empty/error/loading/idle states -> no scrollbar row body, no jump.
- [ ] Verify: `dart format --set-exit-if-changed . && flutter analyze && flutter test`

### Phase 5: Journeys And Docs

- **Goal**: Critical flows, docs, example.
- [ ] `test/robots/dropify_robot.dart` - key-first helpers for item visibility, async completion-safe opens.
- [ ] `test/journeys/dropify_menu_body_journey_test.dart` - static long-list selected-row journey.
- [ ] `test/journeys/dropify_menu_body_journey_test.dart` - async loaded-data selected-row journey.
- [ ] `README.md` - scroll-to-selected + body modes + paginated exclusion.
- [ ] `doc/static_dropdowns.md` - threshold, forced modes, search-hidden no-op.
- [ ] `doc/async_dropdowns.md` - loaded/refreshing modes, no extra fetch, direct states.
- [ ] `doc/accessibility_and_testing.md` - selectors/testing note only if changed.
- [ ] `example/lib/pages/static_dropdown_page.dart` - long-list selected-near-end/body-mode demo.
- [ ] Robot journey tests + selectors/seams: use `dropify.anchor`, `dropify.item.*`, controlled async fetcher, no `runAsync` unless documented.
- [ ] TDD: static robot opens long list -> selected item key visible, panel open.
- [ ] TDD: async robot completes fetch -> selected item key visible, panel open.
- [ ] Verify: `dart format --set-exit-if-changed . && flutter analyze && flutter test`

## Risks / Out of scope

- **Risks**: `ListController.isAttached` timing; variable-height item jump precision; eager mode with large async rows intentionally heavy.
- **Out of scope**: Paginated API/runtime changes; extra async fetches/pages to locate selected values; public animation/alignment/retry knobs.
