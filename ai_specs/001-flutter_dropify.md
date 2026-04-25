<goal>
Build `dropify_flutter` v1 as a complete universal Flutter dropdown package.

The package must give Flutter developers one coherent dropdown API that supports static, async, paginated, single-select, multi-select, and form-field use cases without forcing each app to hand-roll overlay, search, selection, loading, retry, pagination, and validation behavior.

The final result must be publishable as a package: public API implemented, examples working, README and dartdoc ready, accessibility verified, automated coverage in place, and `flutter pub publish --dry-run` clean.
</goal>

<background>
Project state:
- Root package: `./pubspec.yaml` currently declares `sdk: ^3.10.3` and `flutter: >=1.17.0`.
- Public library stub: `./lib/dropify_flutter.dart` currently exports only a sample `Calculator` class; replace it with the real package barrel.
- Test stub: `./test/dropify_flutter_test.dart` tests the sample `Calculator`; replace it with real tests.
- Example app: `./example/lib/main.dart` is the default counter app; replace it with a Dropify gallery.
- Existing planning artifact: `./ai_specs/000-dropify_flutter.md` contains the original v1 plan.
- Existing milestone specs: `./ai_specs/001-core_skeleton.md` through `./ai_specs/007-polish_and_a11y.md` contain useful implementation detail, but this spec is the durable implementation contract when conflicts exist.

Reference files to examine before implementation:
- `./refrences/flutter_raw_menu_anchor.dart`
- `./refrences/flutter_menu_anchor.dart`
- `./refrences/flutter_dropdown_menu.dart`

Reference patterns to follow:
- Use `RawMenuAnchor` and `MenuController` behavior as the foundation for overlay lifecycle, focus handling, tap-outside behavior, scroll-close behavior, view-resize-close behavior, and escape-to-dismiss behavior.
- Follow the `MenuController._attach` and `_detach` single-bind pattern for `DropifyController`.
- Surface `RawMenuOverlayInfo` through `DropifyState.overlayInfo` so raw body builders can position custom UI relative to the anchor.
- Match Flutter framework dartdoc style for public API documentation, including `See also:` sections and `{@tool dartpad}` examples where practical.

Clarifications that override earlier planning text:
- Keep the existing `flutter: >=1.17.0` lower bound unless implementation proves it impossible. Because `RawMenuAnchor` may require a newer Flutter SDK, run the SDK compatibility discovery in M0 and stop for approval before raising the lower bound.
- Use `DropifyFormSource.entries(...)` for static form sources instead of `DropifyFormSource.static(...)`.
- Public Layer 2 and theme APIs may use Material styling types such as `InputDecoration`, `InputDecorationTheme`, and `ButtonStyle`; no widget may require a `MaterialApp` ancestor to function.
- Keep full v1 scope: static, async, paginated, form field, theming, example gallery, README, dartdoc, accessibility, and goldens.
- Require full CI-grade validation: TDD slices, unit tests, widget tests, robot-driven journey tests, example smoke tests, analyze, format, final goldens, and publish dry-run.
</background>

<discovery>
Complete these checks before implementing feature code:

1. Verify current Flutter SDK APIs used by the plan.
   - Confirm `RawMenuAnchor`, `RawMenuOverlayInfo`, `MenuController`, and relevant shortcut/focus behavior are available to the active toolchain.
   - Confirm whether the declared package lower bound `flutter: >=1.17.0` is compatible with the selected APIs.
   - If the lower bound is incompatible, do not silently change it. Document the exact compiler/analyzer failure and ask for approval to raise the bound.

2. Verify `infinite_scroll_pagination` v5 API.
   - Add `infinite_scroll_pagination: ^5.1.0` or the latest compatible v5 patch.
   - Inspect the v5 `PagingController` API before coding `./lib/src/internal/paging.dart` and `./lib/src/widgets/dropify_paginated_dropdown.dart`.
   - Keep all direct dependency usage isolated to the paging adapter and paginated widget.

3. Review the existing milestone specs.
   - Use `./ai_specs/001-core_skeleton.md` through `./ai_specs/007-polish_and_a11y.md` as implementation aids.
   - Reconcile any conflict against this spec before coding.
   - In particular, earlier text that says theme defaults must be pure widgets-only is superseded: Material styling types are allowed in public APIs, but runtime must not require `MaterialApp`.

4. Inspect Flutter reference style.
   - Use `./refrences/flutter_raw_menu_anchor.dart` around `RawMenuOverlayInfo`, `_RawMenuAnchorBaseMixin`, and `MenuController`.
   - Use `./refrences/flutter_dropdown_menu.dart` for `DropdownMenuEntry` shape, disabled-entry behavior, keyboard descriptions, and dartdoc style.
</discovery>

<user_flows>
Primary developer flow:
1. A developer adds `dropify_flutter` to a Flutter app.
2. The developer imports `package:dropify_flutter/dropify_flutter.dart`.
3. The developer chooses a concrete widget for the data source: `DropifyDropdown`, `DropifyAsyncDropdown`, or `DropifyPaginatedDropdown`.
4. The user taps or focuses the anchor.
5. The dropdown opens in an overlay anchored to the field.
6. The user optionally types in the search field.
7. The list filters locally for static data or refetches through debounced async/paginated data.
8. The user selects an enabled entry.
9. Single-select closes by default and calls `onChanged` with one value; multi-select stays open by default and calls `onChanged` with the selected values.

Raw customization flow:
1. A developer uses `RawDropify<T>` or `RawDropify.multi<T>`.
2. The developer provides an `anchorBuilder` and `bodyBuilder`.
3. `RawDropify` owns controller attachment, open/close state, query state, data-source state, selection helpers, and overlay wiring.
4. The developer controls all visual chrome inside `bodyBuilder`.
5. The custom body uses `DropifyState` to inspect entries, status, errors, selection, `hasMore`, and `overlayInfo`.

Async flow:
1. The user opens an async dropdown.
2. If `fetchOnOpen` is true, the widget enters `loading` and calls `fetch(query)`.
3. If the fetch succeeds with entries, the widget shows results.
4. If the fetch succeeds with an empty list, the widget shows the empty state.
5. If the fetch fails, the widget shows the error state and retry action.
6. If the user changes query while a request is pending, a request-token guard drops stale responses.

Paginated flow:
1. The user opens a paginated dropdown.
2. The first page loads from `fetchPage(firstPageKey, query)`.
3. Scrolling near the end requests the next page.
4. Duplicate values across pages are deduped by `DropifyEntry.value ==`.
5. Query changes reset paging to `firstPageKey` and clear stale page state.
6. First-page errors show the main error state; later-page errors show a retry affordance without discarding already loaded entries.

Form flow:
1. A developer uses `DropifyFormField<T>` or `DropifyFormField.multi<T>` inside a `Form`.
2. The developer selects the source through `DropifyFormSource.entries(...)`, `.async(...)`, or `.paginated(...)`.
3. The user selects values through the underlying concrete dropdown.
4. `FormFieldState.didChange` updates with the selected value or values.
5. `validator`, `onSaved`, and `autovalidateMode` behave like standard Flutter `FormField` contracts.
6. Validation errors appear in the anchor decoration and semantics.

Alternative flows:
- The developer supplies an external `DropifyController`; it must attach to only one `RawDropify` at a time.
- The developer omits the controller; the widget creates and disposes an internal controller.
- The developer disables search through `searchEnabled: false`; the panel renders no search field and existing selections still work.
- The developer supplies per-widget theme overrides; those override inherited `DropifyTheme` values.
- The developer wraps a subtree in `DropifyTheme`; all descendant Dropify widgets use it unless overridden.
- The developer uses `DropifyThemeData.fromMaterial(context)` to bridge a Material app theme.

Error and recovery flows:
- Async request fails: show error UI with retry; preserve query; retry reruns the latest query.
- Async stale response arrives after a newer query: ignore stale response and do not update visible entries/status.
- Paginated first page fails: show main error UI with retry.
- Paginated later page fails: keep loaded entries visible and show a new-page retry affordance.
- Empty result set: show empty state, not error state.
- Disabled entry selected by tap or keyboard: no value change, no callback, reduced-opacity/default disabled presentation, and disabled semantics.
- Multi-select would exceed `maxSelection` or go below `minSelection`: reject the toggle, set `lastRejectionReason`, leave selection unchanged, and expose enough state for UX feedback.
- User presses escape, taps outside, scrolls an ancestor, or view size changes: close the overlay according to inherited `RawMenuAnchor` behavior.
</user_flows>

<requirements>
**Functional:**
1. Replace the sample package with the full Dropify public API exported from `./lib/dropify_flutter.dart`.
2. Implement Layer 1 in `./lib/src/core/raw_dropify.dart` as the only layer that owns overlay positioning, controller attachment, open/close lifecycle, query state, data-source state, selection helpers, and `RawMenuAnchor` integration.
3. Implement Layer 2 widgets as thin wrappers over `RawDropify`: `DropifyDropdown`, `DropifyAsyncDropdown`, and `DropifyPaginatedDropdown`, each with `.multi` support.
4. Implement Layer 3 form integration as one `DropifyFormField<T>` and one `.multi` constructor that select concrete behavior through `DropifyFormSource.entries(...)`, `.async(...)`, and `.paginated(...)`.
5. Implement `DropifyEntry<T>` mirroring `DropdownMenuEntry<T>` with `value`, `label`, `labelWidget`, `leadingIcon`, `trailingIcon`, `enabled`, and `style`.
6. Use `==` on `DropifyEntry.value` as the selection identity contract and pagination dedupe key.
7. Implement `DropifyController<T>` as a `Listenable` with single and multi factories, `isMulti`, `isOpen`, `query`, `status`, `error`, `entries`, `singleValue`, `multiValues`, `open`, `close`, `setQuery`, `refresh`, `loadMore`, and `retry`.
8. Implement controller single-bind attach/detach behavior so one external controller cannot be attached to multiple widgets at once.
9. Implement `DropifyState<T>` with `controller`, filtered/fetched `entries`, `status`, `error`, `hasMore`, `overlayInfo`, `isSelected(T)`, and `toggle(T)`.
10. Implement sealed data sources: `StaticDropifyDataSource<T>`, `AsyncDropifyDataSource<T>`, and `PaginatedDropifyDataSource<T>`.
11. Static data must filter with a default case-insensitive `label.contains(query)` matcher and allow per-widget matcher override.
12. Async data must debounce query changes using `queryDebounce` with default 300 ms and drop out-of-order responses through request tokens.
13. Paginated data must use `infinite_scroll_pagination` v5 through an internal adapter and reset to `firstPageKey` on query changes.
14. Single-select must default `closeOnSelect` to true; multi-select must default `closeOnSelect` to false; both must allow explicit override.
15. Multi-select must support optional `minSelection` and `maxSelection` constraints with no-op rejection and `lastRejectionReason` reporting.
16. Layer 2 default anchor must support label, hint, selection summary, chevron, error state, disabled state, and multi chips.
17. Layer 2 default panel must support search, scrollable results, selected item presentation, disabled item presentation, loading state, error state, empty state, and pagination footer states.
18. The package must not require `MaterialApp` to function, even though public styling APIs may expose Material types.
19. `DropifyTheme` and `DropifyThemeData` must provide light, dark, copyWith, lerp, equality, inherited lookup, per-widget override precedence, and `fromMaterial(BuildContext)` bridge.
20. Implement stable selectors as static keys or documented constants for default anchor, search field, panel, items, chips, retry buttons, and example gallery navigation used by tests.
21. Build an example gallery under `./example/lib/` with pages for static, async, paginated, form, theming, and raw customization.
22. Replace default README content with package pitch, install instructions, static/async/paginated/form snippets, theming snippet, screenshots, and prior-art acknowledgment.
23. Add dartdoc to every public class, constructor, method, property, typedef, and enum value.

**Error Handling:**
24. Async failures must set `DropifyStatus.error`, expose `error`, render retry UI, and keep the current query available.
25. Async stale responses must not update `entries`, `status`, `error`, callbacks, or visible UI.
26. Paginated first-page failures must set main error state; later-page failures must keep loaded entries and show page-level retry.
27. `refresh()` must rerun the latest async/paginated request and preserve selection unless selected values are explicitly removed by the caller.
28. `loadMore()` on non-paginated controllers must fail with a clear `UnsupportedError` or documented equivalent.
29. `refresh()` and `retry()` on static-only controllers must fail with a clear `UnsupportedError` or be documented as no-ops; choose one behavior and test it consistently.
30. Invalid single/multi getter access must throw `StateError` with messages that identify the wrong mode.
31. Reusing one controller across multiple attached widgets must assert or throw according to Flutter debug/release conventions; document and test debug behavior.

**Edge Cases:**
32. Empty static entries render an empty panel state and never crash.
33. Empty query shows all static entries in original order.
34. Whitespace query handling must be deterministic; trim or do not trim, document the choice, and test it.
35. Duplicate entry values are allowed in input but selection identity uses value equality; rendering may show duplicates, but selecting one marks all equal values selected unless deduped by the widget. Document and test the chosen behavior.
36. Disabled entries are skipped by keyboard traversal and ignored by tap selection.
37. Query changes while the panel is closed must update controller query but must not fetch async data until the configured fetch trigger requires it.
38. Disposing a widget with a pending debounce or fetch must not call setState, notify listeners unexpectedly, or leak timers.
39. Closing an overlay during loading must leave controller state coherent and must not crash when the request completes.
40. Multi chips must handle long labels and overflow without layout exceptions.
41. Panel constraints must prevent viewport overflow and default panel width must follow anchor width unless overridden.
42. RTL must be functionally correct even if RTL-specific polish is out of scope.

**Validation:**
43. All public APIs must be covered by behavior-first tests written in vertical RED -> GREEN -> REFACTOR cycles.
44. Each milestone must pass `flutter analyze`, `dart format .`, and the relevant `flutter test` suites before the next milestone starts.
45. User-facing critical flows must have robot-driven widget journey coverage using key-first selectors.
46. Async and pagination tests must use deterministic fakes, `Completer`, and fake timers where appropriate; avoid real network and uncontrolled delays.
47. Final v1 must pass full test suite, docs generation, example smoke test, screenshots, accessibility verification, goldens, and publish dry-run.
</requirements>

<boundaries>
Edge cases:
- First-time user with no selection: anchor shows hint text and no chips.
- Returning/rebuilt widget with initial values: anchor and controller reflect initial values exactly once without duplicate callbacks.
- User opens and immediately closes while fetch is pending: no crash, no stale visible state, no setState after dispose.
- User types rapidly: debounce limits requests and only latest result applies.
- User taps retry multiple times: concurrent retries must not corrupt state; latest request wins.
- User scrolls paginated list while a page is loading: do not start duplicate page requests for the same page key.
- User selects while entries update: selected values remain value-based and callbacks reflect the final action.
- User disables search: no search field is rendered and keyboard selection still works.

Error scenarios:
- Static matcher throws: catch is not required if matcher is app code; document that matcher exceptions surface to the caller.
- Async fetch throws: show error builder and retry.
- Async fetch returns after dispose: ignore safely.
- Paginated page throws: show first-page or next-page error UI depending on page state.
- Theme builder/default state builder throws: treat as app code and allow Flutter error reporting.
- Missing overlay ancestor: follow Flutter `RawMenuAnchor` behavior; do not implement a custom fallback unless required by tests.

Limits:
- No server-side search highlight in v1; local label highlighting may be added only if it is already planned in a milestone and tested.
- No grouped/hierarchical entries in v1.
- No Cupertino-specific sibling widgets in v1.
- No persistent recent-selections or frecency sorting in v1.
- No companion package split for pagination in v1; `infinite_scroll_pagination` remains a hard dependency.
- No drag-to-reorder selected chips in v1.
- No per-entry payload widgets beyond `labelWidget`, `leadingIcon`, and `trailingIcon`.
</boundaries>

<api_contract>
Core files:
- `./lib/src/core/dropify_entry.dart`: `DropifyEntry<T>`.
- `./lib/src/core/dropify_controller.dart`: `DropifyController<T>` and private single/multi implementations.
- `./lib/src/core/dropify_state.dart`: `DropifyState<T>` and `DropifyStatus`.
- `./lib/src/core/dropify_data_source.dart`: sealed data source classes.
- `./lib/src/core/raw_dropify.dart`: `RawDropify<T>`, `RawDropify.multi<T>`, `DropifyAnchorBuilder<T>`, and `DropifyBodyBuilder<T>`.

Widget files:
- `./lib/src/widgets/dropify_dropdown.dart`: static single/multi concrete widgets.
- `./lib/src/widgets/dropify_async_dropdown.dart`: async single/multi concrete widgets.
- `./lib/src/widgets/dropify_paginated_dropdown.dart`: paginated single/multi concrete widgets.
- `./lib/src/widgets/dropify_form_field.dart`: form field and `DropifyFormSource` sealed source classes.
- `./lib/src/widgets/_dropify_anchor.dart`: default anchor implementation.
- `./lib/src/widgets/_dropify_panel.dart`: default panel implementation.
- `./lib/src/widgets/_dropify_search_field.dart`: default search implementation.

Theme and internal files:
- `./lib/src/theme/dropify_theme.dart`: inherited theme.
- `./lib/src/theme/dropify_theme_data.dart`: theme data and Material bridge.
- `./lib/src/internal/debouncer.dart`: deterministic debouncer.
- `./lib/src/internal/default_matcher.dart`: default static matcher.
- `./lib/src/internal/paging.dart`: adapter around `PagingController<int, DropifyEntry<T>>`.

Public barrel:
- Export only public API from `./lib/dropify_flutter.dart`.
- Do not export private widgets, private implementations, or internal helpers.
- Do not require package users to import from `src/`.

Form source naming:
- Use `DropifyFormSource.entries(entries: ...)` for static form field data.
- Use `DropifyFormSource.async(fetch: ..., fetchOnOpen: ...)` for async data.
- Use `DropifyFormSource.paginated(fetchPage: ..., firstPageKey: ..., pageSize: ...)` for paginated data.
</api_contract>

<implementation>
Use small, staged implementation. Do not duplicate overlay or positioning logic above Layer 1.

Required output paths:
- Package source under `./lib/`.
- Package tests under `./test/`.
- Example gallery under `./example/lib/`.
- README at `./README.md`.
- Changelog at `./CHANGELOG.md`.
- Optional screenshots under `./doc/screenshots/` or `./example/screenshots/`; choose one path and reference it from README.

Patterns to use:
- Prefer Flutter framework style: immutable public data classes, const constructors, clear dartdoc, `debugFillProperties` where useful, and private implementation details in `src/`.
- Use `ChangeNotifier` or equivalent for `DropifyController` as long as it satisfies `Listenable` and notifies predictably.
- Use constructor injection or explicit callback parameters for fetchers, matchers, builders, debounce durations, and paging config.
- Use fakes and `Completer` in tests instead of mocking internal classes.
- Use stable `Key` constants for robot-tested widgets; add only selectors needed by declared journeys.

What to avoid:
- Do not implement custom overlay infrastructure when `RawMenuAnchor` already provides the required lifecycle.
- Do not add backward-compatibility shims for APIs not yet shipped.
- Do not create separate form-field classes for static, async, and paginated sources; use one `DropifyFormField` with a sealed `DropifyFormSource`.
- Do not start M1 before M0 is green; do not start later milestones until the previous milestone is merged or explicitly accepted.
- Do not use real network calls in tests or example default flows.
- Do not silently raise Flutter SDK lower bound; stop and ask if compatibility fails.
</implementation>

<stages>
M0 - Core skeleton:
- Update `./pubspec.yaml` dependencies and verify SDK compatibility risk.
- Create the source layout.
- Implement `DropifyEntry`, `DropifyStatus`, `DropifyState`, `DropifyController`, data sources, `DropifyTheme`, and `DropifyThemeData`.
- Replace the public barrel with core exports only.
- Verify with unit tests, analyze, and format.

M1 - RawDropify:
- Implement `RawDropify<T>` and `.multi<T>` with static data source support.
- Wire `RawMenuAnchor.overlayBuilder`, controller scope lookup, query state, static filtering, close-on-select defaults, and overlay tap region wrapping.
- Add raw example page proving custom body rendering works without Layer 2 chrome.
- Verify with widget tests for open/close, tap outside, escape, query, selection, disabled entries, controller attach, and dispose.

M2 - Static concrete dropdown:
- Implement `DropifyDropdown<T>` and `.multi<T>`.
- Build default anchor, panel, search field, item rendering, selection styling, chips, empty state, and theme application.
- Add static example page.
- Verify with widget tests and a robot journey for static single and multi happy paths.

M3 - Async dropdown:
- Implement `AsyncDropifyDataSource<T>` behavior in RawDropify if not completed earlier.
- Implement `DropifyAsyncDropdown<T>` and `.multi<T>`.
- Add loading, error, empty, retry, debounced query, and stale-response protection.
- Add async example page with deterministic fake API controls for loading, error, empty, and success.
- Verify with fake timers/completers, widget tests, and robot journey for loading -> search -> select -> error retry.

M4 - Paginated dropdown:
- Implement `PaginatedDropifyDataSource<T>`, internal paging adapter, and `DropifyPaginatedDropdown<T>` with `.multi<T>`.
- Add first-page load, next-page load, no-more-items, page error retry, dedupe, and query reset.
- Add paginated example page with deterministic fake pages.
- Verify with unit tests for adapter behavior, widget tests for page states, and robot journey for scroll-load-select-retry.

M5 - Form field:
- Implement `DropifyFormField<T>`, `.multi<T>`, and `DropifyFormSource` sealed classes.
- Wire validator, onSaved, autovalidateMode, error display in anchor, and form state updates for all data sources.
- Add form example page.
- Verify with widget tests and robot journey for validation failure, correction, submit, and save.

M6 - Polish, docs, a11y, goldens:
- Complete keyboard verification, semantics pass, theming page, README, dartdoc, screenshots, CHANGELOG, pubspec polish, and golden tests.
- Run manual VoiceOver and TalkBack smoke checks where devices are available; document residual risk if unavailable.
- Verify `flutter pub publish --dry-run` has zero errors and no unresolved warnings.
</stages>

<validation>
TDD expectations:
- Use vertical RED -> GREEN -> REFACTOR cycles for testable logic, state, services, and widget behavior.
- Write one failing test for one behavior before implementing that behavior.
- Do not batch tests ahead of implementation.
- Implement the minimum production code required for the current failing test.
- Refactor only after all tests are green.
- Order tests by risk: happy path, critical edge cases, error handling, remaining edge cases.

Testability seams:
- Fetch functions are injected callbacks and must be replaceable with deterministic fakes.
- Debounce duration is configurable and tests can set it to zero or control it with fake timers.
- Async tests use `Completer<List<DropifyEntry<T>>>` or deterministic fake page sources.
- Paging behavior is isolated behind `./lib/src/internal/paging.dart` so unit tests can verify page keys, dedupe, reset, and errors without rendering the full widget tree.
- Example app data sources use fake repositories or local fixtures, not real network.

Test split:
- Unit tests cover `DropifyEntry`, controller mode behavior, selection equality, min/max rejection, data-source value objects, default matcher, debouncer, paging adapter, and theme data.
- Widget tests cover raw open/close/query/select behavior, default anchors/panels, loading/error/empty states, disabled entries, keyboard behavior, semantics, form validation, theme overrides, and disposal during pending work.
- Robot-driven widget journey tests cover critical cross-screen example flows: static single and multi selection, async loading/search/error-retry/select, paginated scroll-load-retry-select, form validation-submit, theme switching, and raw custom dropdown usage.
- Golden tests in M6 cover default static dropdown anchor and open panel in light and dark themes, including multi variants.
- Manual smoke tests cover example app navigation on at least one available device; run with Dart MCP launch tools when possible.

Stable selector requirements:
- Define key constants for example navigation entries, each dropdown anchor, search field, panel, item rows, retry buttons, chips, form submit button, theme toggle buttons, and raw demo controls.
- Robot tests must prefer `find.byKey`.
- Use `find.text` only when copy is the behavior under test.
- Use semantics labels as accessibility assertions, not primary robot selectors unless keys are not viable.

Commands and checks:
- Run `dart format .` and require no formatting diff.
- Run `flutter analyze` from the package root.
- Run `flutter test` from the package root.
- Run example tests from `./example` if example has separate tests.
- Run `dart doc` after public API documentation lands.
- Run `flutter pub publish --dry-run` before declaring v1 done.
- For screenshots, use the Flutter screenshot workflow after launching the example app.

Coverage outcomes required:
- Logic/business rules: controller, matcher, debouncer, data source, pagination, min/max, disabled entries, stale async response handling.
- UI behavior: anchor/panel rendering, search, selection, chips, state builders, keyboard, semantics, form errors, theme overrides.
- Critical journeys: example gallery paths for static, async, paginated, form, theming, and raw flows.

Known testing risks:
- Historical Flutter lower-bound compatibility may not be fully verifiable on the active toolchain; document residual risk if exact old-SDK validation is not feasible.
- Golden tests may vary by host rendering; pin text scale, locale, surface size, device pixel ratio, and CI runner OS.
- `runAsync` is a fallback only; if used, document why deterministic pump/fake-timer strategy was insufficient.
</validation>

<done_when>
The work is complete when:
1. `./lib/dropify_flutter.dart` exports the intended v1 public API and no sample `Calculator` code remains.
2. All files listed in `<api_contract>` exist and are implemented.
3. Static, async, paginated, form, theme, and raw example pages exist and are reachable from the example gallery.
4. All user flows in `<user_flows>` work in the example app.
5. All error and edge cases in `<requirements>` and `<boundaries>` are covered by automated tests or documented manual verification.
6. TDD expectations were followed per milestone and each milestone reached a green test/analyze/format state before the next one began.
7. `dart format .`, `flutter analyze`, `flutter test`, `dart doc`, and `flutter pub publish --dry-run` pass.
8. README includes install, static, async, paginated, form, theming, screenshots, and prior-art sections.
9. Public dartdoc is complete enough that a new developer can discover the right widget from any related API page.
10. Accessibility semantics and keyboard behavior are verified for default widgets.
11. Final M6 goldens are committed and stable.
12. Any unresolved Flutter SDK lower-bound issue is either approved and fixed or explicitly documented as a blocking risk before publish.
</done_when>
