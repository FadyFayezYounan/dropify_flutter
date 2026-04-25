# 003 — DropifyDropdown (Static Concrete) (M2)

> Parent spec: [000-dropify_flutter.md](000-dropify_flutter.md)
>
> Depends on: [002-raw_dropify.md](002-raw_dropify.md) merged.
>
> Scope: Layer 2 concrete widget for the **static** data source — single + multi. Default anchor chrome, default panel chrome, default search field, default item rendering, chip strip for multi.

## Goal

Ship `DropifyDropdown<T>` and `DropifyDropdown.multi` as thin wrappers over `RawDropify` that render the opinionated default chrome. Developers using the static case should write zero boilerplate beyond `entries:` and `onChanged:` (or a controller).

**Layering rule**: this widget produces a `RawDropify(bodyBuilder: ...)` — it does not duplicate any overlay/positioning/state logic from Layer 1.

## Deliverables

### 1. `lib/src/widgets/_dropify_anchor.dart`

Internal default anchor. Renders:

- A bordered container styled by `DropifyThemeData.anchorDecoration` (`InputDecorationTheme`).
- A `label` (above or floating, via `InputDecoration`).
- The current selection text (single) or chip strip (multi). Empty selection shows `hintText`.
- A trailing chevron icon (`DropifyThemeData.chevronIcon`) that rotates when open.
- Tap area = the whole container; calls `controller.open()`.
- Disabled state: reduced opacity, no tap.
- Error state hook (no-op in M2; M5 form field uses it).

For multi, the chip strip uses `chipBuilder` if provided, else a default `Chip`-shaped widget styled from `DropifyThemeData.chipBackground` / `chipTextStyle`. Use `widgets.dart`-only constructions — no `material.Chip`.

### 2. `lib/src/widgets/_dropify_search_field.dart`

Internal default search field. Wraps a `TextField` (or `EditableText` if going pure-widgets is feasible — `TextField` is fine since it's in `material.dart` but its constructor params don't require a `MaterialApp`; if this trips you up, fall back to a custom `EditableText` wrapper). Behavior:

- Bound to `DropifyController.query` via a local `TextEditingController`; pushes user input into `controller.setQuery`.
- Decorated by `DropifyThemeData.searchDecoration`.
- Autofocus when the panel opens.
- Arrow keys do NOT consume — they propagate so list focus traversal still works (handled by `RawMenuAnchor`'s shortcuts).

### 3. `lib/src/widgets/_dropify_panel.dart`

Internal default panel. Composes:

- Outer `DecoratedBox` styled by `DropifyThemeData.panelShape`, `panelBackground`, `panelPadding`.
- Constraints from `DropifyThemeData.panelConstraints` / `panelMaxHeight`.
- Width follows the anchor by default — read `state.overlayInfo.anchorRect.width` and apply via `BoxConstraints.tight`. Override via `panelConstraints`.
- Optional search field at top (suppressed when `searchEnabled: false`).
- Scrollable list of entries (`ListView.builder`).
- Each item rendered via `itemBuilder` if provided, else default rendering: leading icon, label (bold-substring highlight on the matched query), trailing icon, selection check (single shows checkmark on selected; multi shows checkbox).
- Disabled entries rendered with reduced opacity, non-tappable, keyboard-skipped.
- Empty state: `emptyBuilder` if provided, else `DropifyThemeData.defaultEmptyBuilder`, else a built-in "No results" fallback.
- Each item wrapped in `Semantics(button: true, selected: ...)`.
- The panel announces result count on update via `SemanticsService.announce` (or equivalent).

Bold-substring highlight: a small helper that splits `label` around the first case-insensitive match of `query` and bolds the match. Skip when `query.isEmpty`. Out-of-scope for v1: server-side highlight (parent spec, "out of scope").

### 4. `lib/src/widgets/dropify_dropdown.dart`

```dart
class DropifyDropdown<T> extends StatelessWidget {
  const DropifyDropdown({
    super.key,
    this.controller,
    required this.entries,
    this.initialValue,
    this.onChanged,
    this.label,
    this.hintText,
    this.searchEnabled = true,
    this.searchHint,
    this.itemBuilder,
    this.anchorBuilder,
    this.panelDecoration,
    this.emptyBuilder,
    this.staticMatcher,
    this.theme,
    this.enabled = true,
    this.focusNode,
  });

  const DropifyDropdown.multi({
    super.key,
    this.controller,
    required this.entries,
    this.initialValues = const [],
    this.onChanged,
    this.minSelection,
    this.maxSelection,
    this.chipBuilder,
    this.closeOnSelect = false,
    /* shared props */
  });
}
```

Implementation:

- Wraps a `RawDropify<T>` (or `.multi`).
- Resolves the effective theme: explicit `theme` prop > `DropifyTheme.maybeOf(context)` > `DropifyThemeData.light()` fallback.
- If `controller == null`, instantiate internally (single or multi based on which constructor was called); honor `initialValue`/`initialValues`.
- `onChanged` is called on selection change with the new value (single: `T?`) or list snapshot (multi: `List<T>`).
- Default anchor builder = `_DropifyAnchor(...)`. If user provides `anchorBuilder`, that overrides entirely.
- Default body builder composes `_DropifyPanel` from the resolved theme + props.
- `panelDecoration`: a `Decoration` (or a `ShapeBorder` + color combo) that overrides theme panel chrome for one-off customization.

Per-widget props always win over the inherited theme. This is the rule for the whole package — keep it consistent with M0's `DropifyTheme.of` precedence.

### 5. Public exports

Update `lib/dropify_flutter.dart` to re-export `DropifyDropdown`. Internal widgets (`_DropifyAnchor`, `_DropifyPanel`, `_DropifySearchField`) stay private — they live under `src/widgets/_*` with leading underscores in their filenames as a convention, and are not re-exported.

### 6. Example page

`example/lib/pages/static_page.dart` — replace the M1 stub. Demonstrates:

- `DropifyDropdown<String>` with a list of entries, `label`, `hintText`, `searchEnabled: true`.
- `DropifyDropdown<String>.multi` with `minSelection: 1`, `maxSelection: 3`, custom `chipBuilder` for one of the dropdowns to show the override path.
- One example with disabled entries.
- One example with a custom `itemBuilder`.

Wire into the gallery in `main.dart`.

## Tests

`test/widgets/dropify_dropdown_test.dart`:

- Construction with required params (`entries`); `onChanged` fires with the right value.
- Internal-controller path (no `controller` arg) honors `initialValue` and is disposed.
- External-controller path: external state changes drive the anchor display; selection round-trips.
- Search filters the list using the default matcher; passing a custom `staticMatcher` overrides.
- `searchEnabled: false` removes the search field from the panel.
- Multi: chips render selected entries; tapping a chip removes it; `minSelection` / `maxSelection` rejection paths set `lastRejectionReason`.
- Disabled entries are not tappable and render with reduced opacity.
- `itemBuilder` override is honored.
- `panelDecoration` override is honored.
- Theme precedence: explicit `theme` prop > `DropifyTheme.maybeOf` > `light()` fallback.
- A11y: each item has `Semantics(button: true, selected: ...)`; the search field is labelled.

## Verification

1. `flutter analyze` + `dart format` clean.
2. `flutter test` green (M0/M1 tests still pass).
3. `cd example && flutter run` and exercise `static_page.dart`:
   - Open / search / select / multi-toggle / chip-remove / disabled item / outside-tap close / escape close / scroll-close.
4. `act-flutter-screenshot` for single + multi default chrome (light theme).

## Out of scope

- Async loading / error / empty fetch states. → M3.
- Pagination. → M4.
- `FormField`. → M5.
- Goldens. → M6.
- Cupertino sibling. → out of scope for v1.

## Done when

- A user can write `DropifyDropdown(entries: ..., onChanged: ...)` and get a fully functional, themed, searchable dropdown without any other configuration.
- `.multi` works with chips, min/max, `closeOnSelect: false` by default.
- All M2 tests pass; no regression in earlier milestones.
- Public surface adds only `DropifyDropdown`; nothing from `_dropify_*.dart` leaks.
