# 007 — Polish, A11y, Theming Page, Docs, Goldens (M6)

> Parent spec: [000-dropify_flutter.md](000-dropify_flutter.md)
>
> Depends on: [006-form_field.md](006-form_field.md) merged.
>
> Scope: the v1 finishing pass. Keyboard-nav verification, screen-reader audit, theming demo page, README + dartdoc, golden tests for default chrome (light + dark).

## Goal

Take the package from "all features land" to "ready to publish". This sub-plan is a polish pass — most of the deliverables are tests, docs, and visual verification. Code changes should be minimal; if a feature gap shows up, fix the smallest thing possible and flag larger work for v1.1.

## Deliverables

### 1. Keyboard navigation verification

Audit and manually verify (then automate) the full key map across single + multi for all three data sources:

- `↑` / `↓` move focus inside the panel; wraps at boundaries.
- `Enter` / `Space` selects the focused entry.
- `Esc` closes the panel; focus returns to the anchor.
- `Tab` from the anchor moves focus through the panel (when open) or to the next field (when closed).
- Search field consumes typing; arrow keys still navigate the list (search field does not consume them).
- Disabled entries are skipped during arrow nav.
- Multi: `Enter` / `Space` toggles without closing (since `closeOnSelect: false` is the multi default).

Most of this is inherited from `RawMenuAnchor`'s default shortcuts (parent spec) — verify, don't reimplement. Add a widget test per assertion using `tester.sendKeyEvent` / `WidgetController.sendKeyDownEvent` so regressions surface in CI.

### 2. Screen-reader pass

Audit Semantics nodes. Each item must already have `Semantics(button: true, selected: ...)` (M2). Add or verify:

- The anchor has `Semantics(button: true, label: <effective label>, value: <selection summary>, expanded: isOpen)`.
- The search field has its own label (`searchHint` or theme default).
- The panel announces result count on update via `SemanticsService.announce` — debounce announcements (e.g. once per 250 ms) so rapid typing doesn't spam.
- Loading / error / empty states have `Semantics(liveRegion: true, label: ...)`.
- Disabled entries set `Semantics(enabled: false)`.

Run on iOS VoiceOver and Android TalkBack manually; capture findings inline in the PR description. Add a `test/widgets/a11y_test.dart` that uses `SemanticsTester` (or `expectLater` against `findsSemantics`) for the assertions above.

### 3. Theming example page

`example/lib/pages/theming_page.dart`:

- Three buttons: Light, Dark, Custom.
- "Light" wraps the gallery in `DropifyTheme(data: DropifyThemeData.light(), ...)`.
- "Dark" → `.dark()`.
- "Custom" → a hand-built theme with non-default panel shape, accent color for selected items, custom chip styling, custom search decoration. Demonstrates that **every** themable surface is reachable via the theme.
- The page contains one of each: static, async, paginated, plus a multi.
- Toggling the theme rebuilds in place (no app restart).

Wire into the gallery.

### 4. README

`README.md` at the package root:

- 1-paragraph pitch (universal dropdown, three data sources, one form field, themable).
- Install snippet.
- "Hello world" code blocks for: static, async, paginated, form. Each ≤ 15 lines.
- Screenshots from earlier milestones (gallery: static / async loading + error / paginated / form / theming light + dark / raw bespoke).
- Theming snippet showing `DropifyTheme(data: ...)` and the `fromMaterial` bridge.
- Link to dartdoc on pub.dev.
- Acknowledge the prior art: Material's `DropdownMenu` + `RawMenuAnchor`; the four data sources are inspired by `infinite_scroll_pagination` + common async patterns.

Use `act-flutter-screenshot` to refresh all screenshots from the current example app — don't reuse stale ones.

### 5. Dartdoc

Match the doc style and `{@tool dartpad}` blocks from the references (refrences/flutter_dropdown_menu.dart). Specifically:

- Every public class has a class-level dartdoc with: 1-paragraph summary, "See also:" list pointing to siblings, and a `{@tool dartpad}` runnable example for the most common use case.
- Every public method/property has a one-line dartdoc.
- Cross-link `DropifyDropdown` ↔ `DropifyAsyncDropdown` ↔ `DropifyPaginatedDropdown` ↔ `DropifyFormField` so a reader landing on one finds the others.
- `RawDropify` doc explains it's the primitive, when to reach for it, and points to a dartpad example mirroring `raw_page.dart`.
- Run `dart doc` and inspect the generated HTML; fix any orphans or broken links.

### 6. Golden tests

`test/golden/`:

- `dropify_dropdown_anchor_light.png` — collapsed anchor, default theme, light.
- `dropify_dropdown_anchor_dark.png` — same, dark.
- `dropify_dropdown_panel_light.png` — open panel with 5 entries, default theme, light.
- `dropify_dropdown_panel_dark.png` — same, dark.
- Multi variants of both.

Use `flutter_test`'s `matchesGoldenFile`. Pin a single device-pixel-ratio + locale + text scale in the test to keep goldens stable. Goldens cover only the **default chrome of the static dropdown** (per parent spec) — async/paginated/form variants are covered by widget tests, not goldens, since their intermediate states make goldens flaky.

Document in the PR how to regenerate goldens (`flutter test --update-goldens test/golden/`) and pin a CI runner OS in `flutter_test_config.dart` if needed to stabilize fonts/AA.

### 7. CHANGELOG.md

First entry — `## 0.1.0 - <date>` — summarizing the v1 surface (entry, controller, raw, three concretes, form field, theme). Use the `act-update-changelog` skill if helpful.

### 8. Final pubspec polish

- `description:` — 60–180 chars, pub.dev favors this band for scoring.
- `repository:`, `homepage:`, `issue_tracker:` — fill in if available; otherwise leave commented out with a TODO.
- `topics:` — `dropdown`, `select`, `picker`, `form`, `pagination` (max 5).
- Verify `environment:` constraints match what we actually use (Dart SDK, Flutter SDK).

## Tests

- All keyboard-nav assertions automated as widget tests.
- Semantics assertions automated.
- Goldens land green on the chosen CI runner OS.
- Existing M0–M5 tests continue to pass.

## Verification

1. `flutter analyze` + `dart format` clean.
2. `flutter test` green, including goldens.
3. `dart doc` produces clean HTML with no warnings about unresolved references.
4. `cd example && flutter run`:
   - Walk every gallery page; exercise open/search/select/multi/retry/scroll/submit/theme-switch.
   - VoiceOver pass on iOS simulator; TalkBack pass on Android emulator.
5. `flutter pub publish --dry-run` → 0 warnings, 0 errors. Score check via `dart pub deps` and any pana run if available.
6. Screenshots captured for README via `act-flutter-screenshot`.

## Out of scope (still deferred for v1)

- Cupertino siblings.
- Hierarchical / grouped entries.
- Drag-to-reorder chips.
- Server-side highlight.
- Splitting paginated mode into a companion package.
- Per-entry custom payload widgets beyond `labelWidget` / `leadingIcon` / `trailingIcon`.
- RTL polish.
- Persistent recent-selections / "frecency" sort.

## Done when

- v1 is publishable: `flutter pub publish --dry-run` green, README polished, dartdoc clean, goldens green, a11y verified.
- The `0.1.0` CHANGELOG entry lists the full v1 surface.
- A new user can land on the README, copy-paste any of the four "hello world" snippets, and have a working dropdown in their app.
