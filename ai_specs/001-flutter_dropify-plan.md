## Overview

Universal Dropify v1 package. Layered API: core RawDropify, concrete widgets, form, examples, docs.

**Spec**: `ai_specs/001-flutter_dropify.md` (read this file for full requirements)

## Context

- **Structure**: Fresh package; create layered `lib/src/{core,widgets,theme,internal}` plus `example/lib/` gallery.
- **State management**: No external state package; `DropifyController<T>` as `Listenable`/`ChangeNotifier`.
- **Reference implementations**: `refrences/flutter_raw_menu_anchor.dart`, `refrences/flutter_dropdown_menu.dart`, `ai_specs/001-core_skeleton.md` through `ai_specs/007-polish_and_a11y.md`.
- **Assumptions/Gaps**: SDK lower-bound discovery before feature code; if `flutter: >=1.17.0` fails, stop for approval. Static `refresh()`/`retry()` => `UnsupportedError`. Query whitespace => no trim; document/test. Screenshots => `doc/screenshots/`.

## Plan

### Phase 1: Core + Raw Static Slice (Complete)

- **Goal**: Importable package; RawDropify static open/search/select path.
- [x] `pubspec.yaml` - add `infinite_scroll_pagination` v5; verify `RawMenuAnchor`, `RawMenuOverlayInfo`, `MenuController` availability.
- [x] `lib/src/core/dropify_entry.dart` - public immutable entry API.
- [x] `lib/src/core/dropify_data_source.dart` - sealed static/async/paginated sources.
- [x] `lib/src/core/dropify_controller.dart` - single/multi factories, attach/detach, selection, query, status, errors.
- [x] `lib/src/core/dropify_state.dart` - `DropifyState<T>`, `DropifyStatus`, selection helpers, overlay info.
- [x] `lib/src/theme/dropify_theme.dart` - inherited lookup shell.
- [x] `lib/src/theme/dropify_theme_data.dart` - light/dark/copyWith/lerp/equality/fromMaterial shell.
- [x] `lib/src/internal/default_matcher.dart` - default case-insensitive matcher; no query trim.
- [x] `lib/src/core/raw_dropify.dart` - static-only `RawMenuAnchor` integration; controller scope; close defaults; tap region.
- [x] `lib/dropify_flutter.dart` - replace calculator with core/raw/theme barrel exports.
- [x] `example/lib/main.dart` - minimal gallery shell plus raw static demo.
- [x] `test/dropify_flutter_test.dart` - remove calculator stub.
- [x] `test/core/*_test.dart` - controller, entry, matcher, theme smoke coverage.
- [x] `test/widgets/raw_dropify_test.dart` - raw static widget coverage.
- [x] TDD: public import exposes core APIs, no `Calculator`.
- [x] TDD: controller single/multi modes, wrong getter `StateError`, attach conflict debug behavior.
- [x] TDD: static matcher empty query, case-insensitive contains, duplicate value selection identity.
- [x] TDD: raw open/close, query filtering, disabled ignored, single closes, multi stays open.
- [x] Robot journey tests + keys for raw demo open/search/select; fake-only data.
- [x] Verify: `dart format . && flutter analyze && flutter test`.

### Phase 2: Static Concrete Dropdown (Complete)

- **Goal**: Default static single/multi widgets over RawDropify.
- [x] `lib/src/widgets/dropify_keys.dart` - stable key constants for anchor, panel, search, rows, chips.
- [x] `lib/src/widgets/_dropify_anchor.dart` - label, hint, summary, chevron, errors, disabled, chips.
- [x] `lib/src/widgets/_dropify_search_field.dart` - keyed search field; disabled when `searchEnabled == false`.
- [x] `lib/src/widgets/_dropify_panel.dart` - results, selected/disabled states, empty state, constraints, RTL-safe layout.
- [x] `lib/src/widgets/dropify_dropdown.dart` - `DropifyDropdown<T>` and `.multi`; thin RawDropify wrappers.
- [x] `lib/src/theme/dropify_theme_data.dart` - default anchor/panel/item styling tokens.
- [x] `lib/dropify_flutter.dart` - export static dropdown and keys.
- [x] `example/lib/static_page.dart` - static single/multi examples.
- [x] `example/lib/main.dart` - gallery navigation to static page.
- [x] `test/widgets/dropify_dropdown_test.dart` - default widget behavior.
- [x] `test/journeys/static_dropdown_journey_test.dart` - robot journeys.
- [x] `test/robots/dropify_robot.dart` - key-first dropdown actions.
- [x] TDD: static single selection updates value/callback and closes by default.
- [x] TDD: static multi chips update, min/max rejection sets `lastRejectionReason`, stays open by default.
- [x] TDD: search disabled hides search while selection and keyboard still work.
- [x] TDD: long chips and panel constraints avoid layout exceptions.
- [x] Robot journey tests + selectors/seams for static single and multi happy paths.
- [x] Verify: `dart format . && flutter analyze && flutter test`.

### Phase 3: Async Dropdown (Complete)

- **Goal**: Debounced async data, stale-response guard, retry states.
- [x] `lib/src/internal/debouncer.dart` - cancellable deterministic debounce.
- [x] `lib/src/core/raw_dropify.dart` - async fetch-on-open, debounced query, request tokens, dispose safety.
- [x] `lib/src/widgets/dropify_async_dropdown.dart` - async single/multi wrappers and state builders.
- [x] `lib/src/widgets/_dropify_panel.dart` - loading/error/empty/retry states.
- [x] `lib/dropify_flutter.dart` - export async dropdown.
- [x] `example/lib/async_page.dart` - deterministic fake async controls.
- [x] `example/lib/main.dart` - gallery navigation to async page.
- [x] `test/internal/debouncer_test.dart` - debounce behavior.
- [x] `test/widgets/dropify_async_dropdown_test.dart` - async states.
- [x] `test/journeys/async_dropdown_journey_test.dart` - robot journey.
- [x] TDD: fetch-on-open loading -> data -> empty.
- [x] TDD: rapid query drops stale response; latest request wins.
- [x] TDD: failure sets error, preserves query, retry reruns latest query.
- [x] TDD: close/dispose during pending debounce/fetch does not crash or leak notifications.
- [x] Robot journey tests + selectors/seams for loading -> search -> select -> error retry.
- [x] Verify: `dart format . && flutter analyze && flutter test`.

### Phase 4: Paginated Dropdown (Complete)

- **Goal**: Isolated paging adapter and paginated widget states.
- [x] `lib/src/internal/paging.dart` - `PagingController` v5 adapter; page keys, dedupe, reset, page errors.
- [x] `lib/src/core/raw_dropify.dart` - paginated loadMore, refresh, retry, query reset, first/later error split.
- [x] `lib/src/widgets/dropify_paginated_dropdown.dart` - paginated single/multi wrappers.
- [x] `lib/src/widgets/_dropify_panel.dart` - loading-more, no-more-items, page retry footer.
- [x] `lib/dropify_flutter.dart` - export paginated dropdown.
- [x] `example/lib/paginated_page.dart` - deterministic fake pages and errors.
- [x] `example/lib/main.dart` - gallery navigation to paginated page.
- [x] `test/internal/paging_test.dart` - adapter behavior.
- [x] `test/widgets/dropify_paginated_dropdown_test.dart` - page states.
- [x] `test/journeys/paginated_dropdown_journey_test.dart` - robot journey.
- [x] TDD: first page load, next page load, no duplicate request for same page key.
- [x] TDD: duplicate values deduped by value equality across pages.
- [x] TDD: query reset clears stale page state and reloads first page.
- [x] TDD: first-page error shows main retry; later-page error keeps loaded entries.
- [x] Robot journey tests + selectors/seams for scroll-load-select-retry.
- [x] Verify: `dart format . && flutter analyze && flutter test`.

### Phase 5: Form Field

- **Goal**: One form API over static, async, paginated sources.
- [ ] `lib/src/widgets/dropify_form_field.dart` - `DropifyFormField<T>`, `.multi`, `DropifyFormSource.entries/async/paginated`.
- [ ] `lib/src/widgets/_dropify_anchor.dart` - validation error display and semantics.
- [ ] `lib/dropify_flutter.dart` - export form field/source.
- [ ] `example/lib/form_page.dart` - validation, save, static/async/paginated forms.
- [ ] `example/lib/main.dart` - gallery navigation to form page.
- [ ] `test/widgets/dropify_form_field_test.dart` - form contracts.
- [ ] `test/journeys/form_dropdown_journey_test.dart` - robot journey.
- [ ] TDD: `didChange`, `validator`, `onSaved`, `autovalidateMode` match `FormField` contracts.
- [ ] TDD: `DropifyFormSource.entries(...)` selects static widget; async/paginated route correctly.
- [ ] TDD: validation errors appear in anchor and semantics.
- [ ] Robot journey tests + selectors/seams for validation failure -> correction -> submit/save.
- [ ] Verify: `dart format . && flutter analyze && flutter test`.

### Phase 6: Polish, Docs, A11y, Publish

- **Goal**: Publishable v1 package; docs, example gallery, accessibility, goldens.
- [ ] `lib/src/theme/dropify_theme.dart` - inherited precedence finalization.
- [ ] `lib/src/theme/dropify_theme_data.dart` - complete Material bridge, lerp, equality, defaults.
- [ ] `lib/src/**/*.dart` - complete dartdoc for all public API; `debugFillProperties` where useful.
- [ ] `example/lib/theming_page.dart` - theme switching gallery page.
- [ ] `example/lib/raw_page.dart` - final raw customization page.
- [ ] `example/lib/main.dart` - full gallery navigation keys.
- [ ] `README.md` - pitch, install, snippets, theming, screenshots, prior art.
- [ ] `CHANGELOG.md` - v1 entry.
- [ ] `pubspec.yaml` - publish metadata and final constraints.
- [ ] `doc/screenshots/` - committed screenshots referenced by README.
- [ ] `test/goldens/*` - light/dark anchor and open panel goldens; pinned locale/size/text scale/DPR.
- [ ] `test/journeys/theme_dropdown_journey_test.dart` - theme journey.
- [ ] `test/journeys/raw_dropdown_journey_test.dart` - raw journey.
- [ ] TDD: theme lookup, override precedence, `fromMaterial`, `copyWith`, `lerp`, equality.
- [ ] TDD: keyboard traversal skips disabled; escape/tap-outside/scroll/view-resize close behavior verified.
- [ ] TDD: semantics labels/states for anchors, errors, disabled rows, selected rows.
- [ ] Robot journey tests + selectors/seams for theme switching and raw custom dropdown usage.
- [ ] Verify: `dart format . && flutter analyze && flutter test`.
- [ ] Verify: `dart doc && flutter pub publish --dry-run`.
- [ ] Verify: example smoke on available device; document VoiceOver/TalkBack residual risk if unavailable.

## Risks / Out of scope

- **Risks**: Flutter lower-bound may conflict with `RawMenuAnchor`; exact old-SDK validation may be unavailable locally; goldens may need CI host pinning.
- **Out of scope**: Grouped entries, Cupertino sibling widgets, persisted recent selections, companion pagination package, drag-reorder chips, server-side highlight.
