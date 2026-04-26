# Dropify — Universal Flutter Dropdown Package

**Spec:** `001-flutter_dropify`
**Status:** Ready to implement
**Target Flutter:** `>=3.27.0` · **Target Dart:** `^3.10.3`
**Package:** `dropify_flutter` v0.1.0

---

## 1. Overview

Dropify is a universal dropdown package for Flutter built as **three layered abstractions**:

1. **Layer 1 — `RawDropify`**: the unstyled core. Owns the anchor, overlay, search field, selection state, controller, theming hooks, and validation. Knows nothing about *how* the panel's list is rendered — that's a `panelBuilder` slot.
2. **Layer 2 — Specialized raw widgets**: `RawStaticDropify`, `RawAsyncDropify`, `RawPaginatedDropify`. Each fills `panelBuilder` for one data model (in-memory, async fetch, paginated fetch). Still unstyled.
3. **Layer 3 — Themed widgets**: `DropifyDropdown`, `DropifyAsyncDropdown`, `DropifyPaginatedDropdown`. Wrap Layer 2 with a Material 3-friendly default look that consumes `DropifyThemeData`.

Built atop Flutter's `RawMenuAnchor` so we inherit its dismiss-on-outside-tap, scroll-aware close, focus traversal, and shortcuts. Code style follows the framework's `raw_menu_anchor.dart` / `menu_anchor.dart` / `dropdown_menu.dart` references.

### Non-goals (v1)

- Bottom-sheet / modal presentation modes (overlay only).
- Cupertino-flavored theme variant.
- Section headers / dividers / grouped items.
- Standalone `DropifyFormField` widget — `validator` is built directly into Layer 1 via an internal `FormField` wrapper.

---

## 2. Glossary

| Term | Meaning |
|------|---------|
| **Anchor** | The trigger widget shown when the dropdown is closed (e.g. a button or text-field-like surface). |
| **Panel** | The floating overlay shown when open: header (search) + body (list) + optional footer. |
| **Entry** | A `DropifyEntry<T>` value representing one selectable option (value + optional label/leading/trailing/enabled/searchable text). |
| **Single / Multi** | Selection mode. Single emits `T?`, multi emits `Set<T>`. |
| **Confirmable** | Multi-select option that buffers selection until "Apply" is tapped (vs. the default live commit). |

---

## 3. Public API surface

Re-exported from `lib/dropify_flutter.dart`:

```dart
// Core (Layer 1)
export 'src/core/raw_dropify.dart' show RawDropify;
export 'src/core/dropify_controller.dart' show DropifyController;
export 'src/core/dropify_entry.dart' show DropifyEntry;
export 'src/core/dropify_selection.dart' show DropifySelectionMode;

// Specialized (Layer 2)
export 'src/widgets/raw_static_dropify.dart' show RawStaticDropify;
export 'src/widgets/raw_async_dropify.dart'
    show RawAsyncDropify, DropifyAsyncState, DropifyAsyncFetcher;
export 'src/widgets/raw_paginated_dropify.dart'
    show RawPaginatedDropify;

// Themed (Layer 3)
export 'src/widgets/dropify_dropdown.dart' show DropifyDropdown;
export 'src/widgets/dropify_async_dropdown.dart' show DropifyAsyncDropdown;
export 'src/widgets/dropify_paginated_dropdown.dart' show DropifyPaginatedDropdown;

// Theme
export 'src/theme/dropify_theme.dart' show DropifyTheme;
export 'src/theme/dropify_theme_data.dart' show DropifyThemeData;

// Re-export so consumers don't need to import infinite_scroll_pagination directly
// for type signatures (they still need it to build PagingController instances).
export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingController, PagingState, PagingListener;
```

---

## 4. File layout

```
lib/
  dropify_flutter.dart                       # public exports (above)
  src/
    core/
      raw_dropify.dart                       # Layer 1 — RawDropify (single + multi ctors)
      dropify_controller.dart                # DropifyController<T> (single & multi)
      dropify_entry.dart                     # DropifyEntry<T>
      dropify_selection.dart                 # DropifySelectionMode enum
      dropify_intents.dart                   # ActivateItemIntent, etc. (keyboard)
    internal/
      _dropify_anchor.dart                   # anchor surface (uses RawMenuAnchor)
      _dropify_panel.dart                    # panel chrome: header (search) + body slot + footer
      _dropify_search_field.dart             # internal search TextField
      _dropify_focus_scope.dart              # arrow-key list focus traversal helpers
      _debouncer.dart                        # tiny Timer-based debouncer for async search
      _default_matcher.dart                  # default contains/case-insensitive matcher
    widgets/
      raw_static_dropify.dart                # Layer 2a
      raw_async_dropify.dart                 # Layer 2b — defines DropifyAsyncState + fetcher typedef
      raw_paginated_dropify.dart             # Layer 2c — uses infinite_scroll_pagination v5.1.1
      dropify_dropdown.dart                  # Layer 3a — themed wrapper around RawStaticDropify
      dropify_async_dropdown.dart            # Layer 3b — themed wrapper around RawAsyncDropify
      dropify_paginated_dropdown.dart        # Layer 3c — themed wrapper around RawPaginatedDropify
    theme/
      dropify_theme.dart                     # InheritedTheme + ThemeExtension<DropifyThemeData>
      dropify_theme_data.dart                # tokens
example/
  lib/
    main.dart                                # MaterialApp + nav to demo pages
    pages/
      static_page.dart
      async_page.dart
      paginated_page.dart
      multi_select_page.dart
      themed_page.dart
      validation_page.dart
    fake_api.dart                            # mock async/paginated data source
test/
  core/
    raw_dropify_single_test.dart
    raw_dropify_multi_test.dart
    dropify_controller_test.dart
    dropify_entry_test.dart
  widgets/
    raw_static_dropify_test.dart
    raw_async_dropify_test.dart
    raw_paginated_dropify_test.dart
    dropify_dropdown_test.dart
    dropify_async_dropdown_test.dart
    dropify_paginated_dropdown_test.dart
  theme/
    dropify_theme_test.dart
  internal/
    default_matcher_test.dart
    debouncer_test.dart
```

---

## 5. Architecture

```
┌──────────────────────────────────────────────────────────────┐
│ Layer 3 (themed):  DropifyDropdown · DropifyAsyncDropdown    │
│                    DropifyPaginatedDropdown                  │
│                    └─ apply DropifyThemeData defaults        │
├──────────────────────────────────────────────────────────────┤
│ Layer 2 (raw, specialized): RawStaticDropify ·               │
│                             RawAsyncDropify ·                │
│                             RawPaginatedDropify              │
│                    └─ each provides a panelBuilder           │
├──────────────────────────────────────────────────────────────┤
│ Layer 1 (raw core):  RawDropify                              │
│   ├─ anchor (via RawMenuAnchor)                              │
│   ├─ DropifyController<T> (single/multi)                     │
│   ├─ search field + searchController                         │
│   ├─ panelBuilder slot (Layer 2 fills this)                  │
│   ├─ FormField<T or Set<T>> wrapper for validation           │
│   └─ DropifyTheme lookup                                     │
└──────────────────────────────────────────────────────────────┘
```

`RawDropify` knows: open/close, anchor rendering, selection state, search query, focus, validation, theming.
`RawDropify` does **not** know: how items are loaded, how the list is rendered, where the data lives.

---

## 6. Layer 1 — `RawDropify` contract

### 6.1 Constructors

```dart
class RawDropify<T> extends StatefulWidget {
  /// Single-selection dropdown.
  const RawDropify({
    super.key,
    required this.panelBuilder,
    required this.anchorBuilder,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.searchController,
    this.searchable = false,
    this.searchHintText,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.showClearButton = false,
    this.matchAnchorWidth = true,
    this.panelConstraints,
    this.alignmentOffset = const Offset(0, 4),
    this.useRootOverlay = false,
    this.consumeOutsideTaps = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.onOpen,
    this.onClose,
    this.validator,
    this.autovalidateMode,
    this.errorTextBuilder,
    this.keyOf,
    this.equals,
  })  : selectionMode = DropifySelectionMode.single,
        confirmable = false;

  /// Multi-selection dropdown.
  const RawDropify.multi({
    super.key,
    required PanelBuilder<T> panelBuilder,
    required AnchorBuilder<T> anchorBuilder,
    DropifyController<T>? controller,
    Set<T>? initialValues,
    ValueChanged<Set<T>>? onChanged,
    // ... mirrors single, plus:
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
  }) : selectionMode = DropifySelectionMode.multi,
       /* assigning fields */ ...;

  // === fields ===
  final DropifySelectionMode selectionMode;
  final DropifyController<T>? controller;
  final T? initialValue;                     // single only
  final Set<T>? initialValues;               // multi only
  final ValueChanged<T?>? onChanged;         // single only
  final ValueChanged<Set<T>>? onChangedMulti; // multi only

  /// Builds the panel body. Receives selection + search state and a builder
  /// context tied to the anchor's MenuController. Layer 2 fills this.
  final PanelBuilder<T> panelBuilder;

  /// Builds the anchor (closed-state) widget. Receives current selection,
  /// open state, and callbacks.
  final AnchorBuilder<T> anchorBuilder;

  // search
  final TextEditingController? searchController;
  final bool searchable;
  final String? searchHintText;
  final Duration searchDebounce;

  // anchor controls
  final bool showClearButton;
  final bool matchAnchorWidth;
  final BoxConstraints? panelConstraints;
  final Offset alignmentOffset;
  final bool useRootOverlay;
  final bool consumeOutsideTaps;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;

  // lifecycle hooks
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  // validation (no separate FormField widget — wired internally)
  final FormFieldValidator<DropifyValue<T>>? validator;
  final AutovalidateMode? autovalidateMode;
  final Widget Function(BuildContext, String error)? errorTextBuilder;

  // identity
  final Object Function(T item)? keyOf;       // optional stable id
  final bool Function(T a, T b)? equals;      // optional custom equality

  // multi-select footer
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;
}
```

### 6.2 Builder typedefs

```dart
typedef AnchorBuilder<T> = Widget Function(
  BuildContext context,
  DropifyAnchorState<T> state,
);

class DropifyAnchorState<T> {
  final DropifySelectionMode mode;
  final T? value;             // single
  final Set<T> values;        // multi
  final bool isOpen;
  final bool enabled;
  final String? errorText;    // from validator
  final VoidCallback open;
  final VoidCallback close;
  final VoidCallback? clear;  // null when nothing to clear
}

typedef PanelBuilder<T> = Widget Function(
  BuildContext context,
  DropifyPanelState<T> state,
);

class DropifyPanelState<T> {
  final DropifySelectionMode mode;
  final T? value;
  final Set<T> values;
  final String searchQuery;
  final bool isSelected(T item);
  final void Function(T item) toggle;   // for multi
  final void Function(T item) select;   // for single (auto-closes)
  final VoidCallback close;
  final FocusNode focusScope;           // for arrow-key traversal
}
```

### 6.3 Lifecycle behavior

| Event | Behavior |
|-------|----------|
| `controller.open()` | Calls `RawMenuAnchor.controller.open(...)`. Triggers `onOpen` once shown. |
| `controller.close()` | Closes panel. Triggers `onClose`. If `confirmable` multi and pending changes exist, **discards** them (cancel semantics) — Apply must be tapped to commit. |
| Outside tap | Closes panel via `RawMenuAnchor` default. Same cancel semantics for confirmable. |
| Escape key | Same as close. |
| Select item (single) | Updates value, calls `onChanged`, closes panel. |
| Toggle item (multi, live) | Updates set, calls `onChangedMulti` immediately. |
| Toggle item (multi, confirmable) | Updates *staged* set; commit only on Apply tap. |
| Search query change | Updates internal `searchQuery`, debounced; rebuilds panel. |
| Anchor disabled | Tap is no-op; clear button hidden. |
| Validator | Internal `FormField` wraps the anchor; `errorText` flows to `DropifyAnchorState.errorText`. |

### 6.4 Key internals

- Anchor uses `RawMenuAnchor` (not `MenuAnchor`) so it's unstyled.
- The panel widget passed to `RawMenuAnchor.overlayBuilder` is wrapped by an internal `_DropifyPanel` that:
  1. Optionally renders a sticky `_DropifySearchField` at the top (when `searchable: true`).
  2. Uses `ConstrainedBox` to apply `panelConstraints` (default: `maxHeight: 320`, `minWidth = anchor width if matchAnchorWidth`).
  3. Renders the user's `panelBuilder` body inside an `Expanded` `Material` surface.
  4. Optionally renders the confirmable footer (Apply / Cancel) for multi-select.
- The matched anchor width is computed from `RawMenuOverlayInfo.anchorRect.width` and applied to the panel via a `ConstrainedBox(minWidth: ..., maxWidth: ...)`.

---

## 7. `DropifyController<T>` (single & multi)

```dart
class DropifyController<T> extends ChangeNotifier {
  DropifyController.single({T? initialValue});
  DropifyController.multi({Set<T>? initialValues});

  DropifySelectionMode get mode;
  T? get value;                 // single
  Set<T> get values;            // multi (unmodifiable view)
  bool get isOpen;

  // mutations
  void setValue(T? value);          // single
  void setValues(Set<T> values);    // multi
  void toggle(T item);              // multi
  void clear();
  void open();
  void close();

  // lookups
  bool isSelected(T item);
}
```

- `DropifyController` is the user-facing handle; internally `RawDropify` attaches/detaches in `initState` / `dispose`.
- Identity used by `isSelected` / `toggle` honors the widget's `keyOf` and `equals` overrides (controllers receive these from the widget on attach).
- If `controller` is null, `RawDropify` builds a private one and disposes it.

---

## 8. `DropifyEntry<T>`

A convenience value type for static lists. Layer 2 widgets accept either `List<T>` + `itemBuilder` (powerful) or `List<DropifyEntry<T>>` (ergonomic).

```dart
@immutable
class DropifyEntry<T> {
  const DropifyEntry({
    required this.value,
    this.label,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.searchableText,        // overrides default contains-match source
  });

  final T value;
  final String? label;
  final Widget? leading;
  final Widget? trailing;
  final bool enabled;
  final String? searchableText;
}
```

---

## 9. Layer 2a — `RawStaticDropify`

In-memory list, optional client-side search.

### 9.1 API

```dart
class RawStaticDropify<T> extends StatelessWidget {
  // single
  const RawStaticDropify({
    required List<DropifyEntry<T>> entries,
    required AnchorBuilder<T> anchorBuilder,
    Widget Function(BuildContext, DropifyEntry<T>, bool selected)? entryBuilder,
    bool Function(DropifyEntry<T> entry, String query)? matcher,
    // …passes through every RawDropify single-mode argument…
  });

  // multi
  const RawStaticDropify.multi({
    required List<DropifyEntry<T>> entries,
    // …same idea for multi…
  });
}
```

### 9.2 Behavior

- Builds `panelBuilder` internally:
  1. Filters `entries` by `matcher(entry, query)` (defaults to `_defaultMatcher` — case-insensitive contains over `entry.searchableText ?? entry.label ?? entry.value.toString()`).
  2. Wraps the filtered list in a `SingleChildScrollView` + `Column` for short lists, **or** `ListView.builder` if `entries.length > 50` (perf threshold).
  3. Each row uses `entryBuilder` (default: an unstyled `InkWell` + `Row` with `leading` / `label` / `trailing` / selected check icon).
  4. If filtered list is empty, calls the panel's `noResultsBuilder` (theme-defaulted; can be overridden via the Layer 3 widget's slot).
- **Disabled** entries: rendered with `IgnorePointer` + reduced opacity; not focusable.

---

## 10. Layer 2b — `RawAsyncDropify`

Async one-shot fetch keyed by search query. No pagination.

### 10.1 State

```dart
sealed class DropifyAsyncState<T> {
  const DropifyAsyncState();
}
class DropifyAsyncIdle<T>      extends DropifyAsyncState<T> { const DropifyAsyncIdle(); }
class DropifyAsyncLoading<T>   extends DropifyAsyncState<T> { const DropifyAsyncLoading(); }
class DropifyAsyncRefreshing<T> extends DropifyAsyncState<T> {
  const DropifyAsyncRefreshing(this.staleItems);
  final List<T> staleItems;
}
class DropifyAsyncData<T>      extends DropifyAsyncState<T> {
  const DropifyAsyncData(this.items);
  final List<T> items;
}
class DropifyAsyncEmpty<T>     extends DropifyAsyncState<T> {
  const DropifyAsyncEmpty({required this.hasQuery});
  final bool hasQuery;        // true => "no results", false => "no data"
}
class DropifyAsyncError<T>     extends DropifyAsyncState<T> {
  const DropifyAsyncError(this.error, this.stackTrace);
  final Object error;
  final StackTrace? stackTrace;
}
```

### 10.2 API

```dart
typedef DropifyAsyncFetcher<T> =
    Future<List<T>> Function(String query, {required CancelToken cancel});

class RawAsyncDropify<T> extends StatefulWidget {
  const RawAsyncDropify({
    required this.fetcher,
    required this.anchorBuilder,
    required this.itemBuilder,           // (ctx, item, selected, onTap) => Widget
    this.loadingBuilder,
    this.errorBuilder,                   // (ctx, error, retry) => Widget
    this.emptyBuilder,                   // (ctx, hasQuery) => Widget
    this.loadOnOpen = true,
    this.cacheItems = true,              // remember last result per query
    this.keyOf,
    // …passes through RawDropify args…
  });

  // .multi constructor analogous
}
```

### 10.3 Behavior

- On open: if `loadOnOpen && (cache miss for current query)`, dispatch `fetcher(query)`. Otherwise emit cached data.
- On search change: debounce per `RawDropify.searchDebounce`, then fetch. **Always cancels** the in-flight request (via `CancelToken` passed to fetcher).
- Cache keyed by `query` string; cleared on widget dispose. `cacheItems: false` disables.
- When data is present and a refetch starts, transitions to `DropifyAsyncRefreshing(staleItems)` so the panel can show the old list with a small spinner.
- `loadingBuilder` / `errorBuilder` / `emptyBuilder` resolve in this order: instance arg → `DropifyThemeData` → built-in default.
- Selecting an item in single mode closes the panel as usual; in multi mode toggles.

### 10.4 Cancel token

A small internal type:

```dart
class CancelToken {
  bool get isCancelled;
  void throwIfCancelled();
}
```

If users prefer `package:dio`'s `CancelToken`, they can ignore this and just check `isCancelled` at await boundaries — the contract is identical at the call site.

---

## 11. Layer 2c — `RawPaginatedDropify`

Paginated fetch using `infinite_scroll_pagination: ^5.1.1`. **Reuses `PagingState` directly** — no new state type.

### 11.1 API

```dart
class RawPaginatedDropify<PageKey, T> extends StatefulWidget {
  const RawPaginatedDropify({
    required this.pagingController,        // user-owned PagingController<PageKey, T>
    required this.anchorBuilder,
    required this.itemBuilder,             // (ctx, item, index, selected, onTap) => Widget
    this.firstPageProgressBuilder,
    this.newPageProgressBuilder,
    this.firstPageErrorBuilder,            // receives retry callback
    this.newPageErrorBuilder,
    this.noItemsFoundBuilder,
    this.noMoreItemsBuilder,
    this.invisibleItemsThreshold = 3,
    this.refreshOnSearch = true,           // calls pagingController.refresh() when query changes
    this.keyOf,
    // …passes through RawDropify args; searchable defaults to true here too…
  });

  // .multi constructor analogous
}
```

### 11.2 Behavior

- Panel body is essentially:

  ```dart
  PagingListener<PageKey, T>(
    controller: pagingController,
    builder: (context, state, fetchNextPage) => PagedListView<PageKey, T>(
      state: state,
      fetchNextPage: fetchNextPage,
      builderDelegate: PagedChildBuilderDelegate<T>(
        itemBuilder: (ctx, item, i) => itemBuilder(ctx, item, i, isSelected(item), () => onTap(item)),
        firstPageProgressIndicatorBuilder: firstPageProgressBuilder ?? _themeFallback,
        newPageProgressIndicatorBuilder:   newPageProgressBuilder   ?? _themeFallback,
        firstPageErrorIndicatorBuilder:    firstPageErrorBuilder    ?? _themeFallback,
        newPageErrorIndicatorBuilder:      newPageErrorBuilder      ?? _themeFallback,
        noItemsFoundIndicatorBuilder:      noItemsFoundBuilder      ?? _themeFallback,
        noMoreItemsIndicatorBuilder:       noMoreItemsBuilder       ?? _themeFallback,
      ),
    ),
  )
  ```

- The user **owns** `pagingController` (constructs and disposes it). The widget does not auto-dispose.
- The user's `fetchPage` closure receives the page key; if they need to honor the search query, they read it from a captured `searchController` or pass it via their own `ValueListenable` and call `pagingController.refresh()` on change.
- When `refreshOnSearch: true`, `RawPaginatedDropify` listens to its own search query and calls `pagingController.refresh()` after debounce.
- When `loadOnOpen: true` (inherited via `RawDropify`'s anchor lifecycle), the widget calls `pagingController.refresh()` once on first open if the current `PagingState.pages` is null.

### 11.3 Why expose `PagingController`?

The user retains full power over their pagination logic (custom keys, cursor pagination, cache layering, request deduplication). Hiding it would force re-implementing the package internally.

---

## 12. Layer 3 — Themed widgets

Each themed widget is a thin `StatelessWidget` that:

1. Reads `DropifyTheme.of(context)` (with `ThemeData.extensions` fallback, then built-in defaults).
2. Composes an opinionated default `anchorBuilder` (a Material surface that looks like an `InputDecorator`: label, hint, value text, dropdown chevron, optional clear button, validation error text below).
3. Composes default `entryBuilder` / `itemBuilder` (a Material `InkWell` row).
4. Forwards everything else to the underlying Layer 2 widget.

### 12.1 `DropifyDropdown<T>` (themed wrapper around `RawStaticDropify`)

Public surface:

```dart
class DropifyDropdown<T> extends StatelessWidget {
  const DropifyDropdown({
    required this.entries,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.searchable = false,
    this.searchHintText,
    this.showClearButton = false,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.itemLabelBuilder,        // (T) => String, for default entry rendering
    // … plus .multi ctor with confirmable, confirmLabel, cancelLabel …
  });
}
```

### 12.2 `DropifyAsyncDropdown<T>`

Same shape as `DropifyDropdown<T>` but with:
- `required DropifyAsyncFetcher<T> fetcher`
- `required String Function(T) itemLabelBuilder`
- Optional `loadingBuilder` / `errorBuilder` / `emptyBuilder` instance overrides.
- `searchable` defaults to **`true`** (an async dropdown without search is rare).

### 12.3 `DropifyPaginatedDropdown<PageKey, T>`

Same shape but with:
- `required PagingController<PageKey, T> pagingController`
- `required String Function(T) itemLabelBuilder`
- All paginated slot builders optional.
- `searchable` defaults to **`true`**.

---

## 13. Theme system

### 13.1 `DropifyThemeData`

Token groups (all nullable; `DropifyThemeData.merge(parent, child)` overlays non-null fields).

```dart
@immutable
class DropifyThemeData with Diagnosticable {
  // anchor
  final InputDecorationTheme? anchorDecorationTheme;
  final IconData? trailingIcon;            // chevron
  final IconData? clearIcon;               // ×
  final TextStyle? anchorValueTextStyle;
  final TextStyle? anchorHintTextStyle;
  final TextStyle? anchorErrorTextStyle;
  final EdgeInsetsGeometry? anchorPadding;

  // panel
  final BoxDecoration? panelDecoration;    // background, border, radius, shadow
  final EdgeInsetsGeometry? panelPadding;
  final double? panelMaxHeight;            // default 320
  final double? panelElevation;
  final Duration? animationDuration;
  final Curve? animationCurve;

  // search field
  final InputDecoration? searchInputDecoration;
  final EdgeInsetsGeometry? searchFieldPadding;
  final TextStyle? searchTextStyle;
  final IconData? searchIcon;
  final IconData? searchClearIcon;

  // entries
  final TextStyle? entryTextStyle;
  final TextStyle? entryDisabledTextStyle;
  final BoxDecoration? entrySelectedDecoration;
  final BoxDecoration? entryHoverDecoration;
  final BoxDecoration? entryFocusDecoration;
  final EdgeInsetsGeometry? entryPadding;
  final IconData? entrySelectedIcon;       // checkmark
  final double? entrySpacing;
  final Divider? entryDivider;             // null => no divider; v2 sections will reuse this

  // state slot defaults
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, Object error, VoidCallback retry)? errorBuilder;
  final Widget Function(BuildContext, bool hasQuery)? emptyBuilder;
  final WidgetBuilder? noResultsBuilder;
  final WidgetBuilder? firstPageProgressBuilder;
  final WidgetBuilder? newPageProgressBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)? firstPageErrorBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)? newPageErrorBuilder;
  final WidgetBuilder? noMoreItemsBuilder;

  // multi-select footer
  final ButtonStyle? confirmButtonStyle;
  final ButtonStyle? cancelButtonStyle;
  final EdgeInsetsGeometry? footerPadding;

  // factories
  factory DropifyThemeData.fromMaterial(ThemeData theme); // M3 defaults
  DropifyThemeData copyWith({...});
  static DropifyThemeData lerp(DropifyThemeData? a, DropifyThemeData? b, double t);
}
```

### 13.2 Resolution order

Inside the package:

```
slot value = instance arg
          ?? DropifyTheme.of(context).<slot>
          ?? Theme.of(context).extension<DropifyThemeData>()?.<slot>
          ?? DropifyThemeData.fromMaterial(Theme.of(context)).<slot>
```

### 13.3 `DropifyTheme` (`InheritedTheme`)

```dart
class DropifyTheme extends InheritedTheme {
  const DropifyTheme({super.key, required this.data, required super.child});
  final DropifyThemeData data;
  static DropifyThemeData of(BuildContext context);  // never returns null — always falls back
}
```

Also expose registration as a `ThemeExtension<DropifyThemeData>` so apps can put it in `ThemeData.extensions`.

---

## 14. Validation

`RawDropify` wraps its anchor in a `FormField<DropifyValue<T>>` where `DropifyValue<T>` is:

```dart
sealed class DropifyValue<T> {
  const DropifyValue();
}
class DropifySingleValue<T> extends DropifyValue<T> {
  const DropifySingleValue(this.value);
  final T? value;
}
class DropifyMultiValue<T> extends DropifyValue<T> {
  const DropifyMultiValue(this.values);
  final Set<T> values;
}
```

Wiring:

- `validator: FormFieldValidator<DropifyValue<T>>?` is optional.
- `autovalidateMode` defaults to `AutovalidateMode.disabled`.
- The internal `FormField` rebuilds the anchor with the current `errorText` (if any), exposed via `DropifyAnchorState.errorText`.
- Layer 3 themed anchors render the error using `errorTextBuilder` (theme default: `Text(error, style: theme.anchorErrorTextStyle)` below the surface).
- Works inside any `Form`. `Form.reset()` resets the controller's value to `initialValue` / `initialValues`.

Why this approach: avoids a parallel `DropifyFormField` widget and keeps validation a first-class arg on every dropdown.

---

## 15. Search behavior

| Aspect | Static | Async | Paginated |
|--------|--------|-------|-----------|
| Default `searchable` | `false` | `true` | `true` |
| Sticky | yes | yes | yes |
| Source | client `matcher` | server fetch | server fetch via `PagingController.refresh()` |
| Debounce | none (instant) | `searchDebounce` (default 300 ms) | `searchDebounce` (default 300 ms) |
| Empty behavior | `noResultsBuilder` when filtered list is empty | `DropifyAsyncEmpty(hasQuery: true)` | `noItemsFoundBuilder` |
| Reset | clearing query restores full list | clearing query refetches with `''` | clearing query refreshes |
| `searchController` | optional — exposed at `RawDropify` level | same | same |

Default matcher (`_defaultMatcher`):

```dart
bool _defaultMatcher<T>(DropifyEntry<T> entry, String query) {
  if (query.isEmpty) return true;
  final hay = (entry.searchableText
              ?? entry.label
              ?? entry.value.toString()).toLowerCase();
  return hay.contains(query.toLowerCase().trim());
}
```

---

## 16. Accessibility & keyboard

Reuses `RawMenuAnchor`'s shortcut map plus our own list-traversal handling:

| Key | Behavior |
|-----|----------|
| `↓` / `↑` (when search is empty or unfocused) | Move focus through panel items; first press from anchor opens panel and focuses item 0. |
| `Enter` / `Space` on focused item | Select (single) / toggle (multi). |
| `Esc` | Close panel without selection. Cancels staged changes in confirmable multi. |
| `Tab` from anchor | Standard focus traversal — does **not** open. |
| Type any printable char while panel open & search visible | Routes to search field. |
| `Backspace` in empty search | No-op (does not close — close is `Esc`). |
| Confirmable multi `Enter` while footer focused | Apply. `Esc` cancels. |

Semantics:

- Anchor: `Semantics(button: true, label: <effective label>, value: <selected text>, hint: 'Double tap to open dropdown')`.
- Each item: `Semantics(button: true, selected: isSelected, label: <effective label>)`.
- Multi-select footer Apply/Cancel: standard button semantics.
- Loading / error / empty states announce via `Semantics(liveRegion: true)`.

---

## 17. Example app

Single-screen-per-variant under `example/lib/pages/`. Each demo page shows: a mini description, the dropdown, and a `Text` showing the current value.

| Page | Demonstrates |
|------|--------------|
| `static_page.dart` | `DropifyDropdown` with country list (50 entries), single, with search. |
| `async_page.dart` | `DropifyAsyncDropdown` with simulated 500 ms fake API + search; shows loading / error retry / empty / no-results states (toggle to inject errors). |
| `paginated_page.dart` | `DropifyPaginatedDropdown` with fake paginated API (page size 20, 200 total items); user-owned `PagingController`; demonstrates retry, refresh-on-search. |
| `multi_select_page.dart` | Multi (live) + multi (confirmable). Shows `clear` button, `showClearButton`, footer style. |
| `themed_page.dart` | One screen with `DropifyTheme` overrides — custom panel decoration, rounded entries, custom selected icon, dark vs light. Shows applying via `DropifyTheme` widget *and* via `ThemeData.extensions`. |
| `validation_page.dart` | Inside a `Form`: required-single, "must select at least 2" multi, custom `errorTextBuilder`, `Form.validate()` from a button. |

`fake_api.dart` exposes `Future<List<Country>> searchCountries(String q, {int page, int pageSize})` with optional fake latency / failure injection.

---

## 18. Testing plan

### 18.1 Unit (`test/core/`, `test/internal/`)

- `default_matcher_test.dart` — case-insensitive contains, trims whitespace, empty query matches all, uses override priority `searchableText > label > value.toString()`.
- `debouncer_test.dart` — `fake_async` based; verifies coalescing, cancel, and disposed state.
- `dropify_controller_test.dart` — single/multi state changes, `isSelected` honors `keyOf` / `equals`, attach/detach lifecycle, `clear`, `notifyListeners`.
- `dropify_entry_test.dart` — equality, `searchableText` fallback chain.

### 18.2 Widget (`test/widgets/`)

For each widget: anchor renders, opens on tap, closes on outside tap, closes on `Esc`, single selects + closes, multi toggles + stays open, `clear` resets, `searchable: true` shows field and filters, validation error displays.

Specifics:

- `raw_async_dropify_test.dart` — uses `Completer<List<T>>` to drive state transitions; asserts loading→data→empty→error→retry; cache hit on re-open same query; cache miss on changed query; cancellation when query changes mid-flight.
- `raw_paginated_dropify_test.dart` — wires a fake `PagingController` with `getNextPageKey` / `fetchPage`; asserts `firstPageProgress`, `newPageProgress`, `firstPageError` + retry, `newPageError`, `noItemsFound`, `noMoreItems`. Asserts `refresh()` is called when search changes if `refreshOnSearch: true`.
- Confirmable multi: stage→cancel discards, stage→apply commits.

### 18.3 Theme (`test/theme/`)

- Resolution order: instance → `DropifyTheme` → `ThemeExtension` → Material default.
- `lerp` produces interpolated values for animatable fields (color, padding).
- `fromMaterial` derives reasonable M3 defaults.

### 18.4 Goldens (deferred to a follow-up if scope allows)

Goldens for the three themed widgets in default + custom theme. Marked optional in v0.1.0.

---

## 19. Implementation phases

Each phase is a self-contained branch / PR. Tests added with code (TDD on the public surface).

| # | Phase | Deliverables | Definition of done |
|---|-------|--------------|--------------------|
| 1 | **Skeleton & theme** | `DropifyThemeData`, `DropifyTheme`, `ThemeExtension`, `_defaultMatcher`, `_Debouncer`, `DropifyEntry`, `DropifyController`, `DropifySelectionMode`, `DropifyValue`. | Unit tests in §18.1 pass. No widgets yet. |
| 2 | **Layer 1 — `RawDropify`** | `RawDropify` (single + multi ctors), `_DropifyAnchor`, `_DropifyPanel`, `_DropifySearchField`, `_DropifyFocusScope`. Uses `RawMenuAnchor`. Validation via internal `FormField`. Confirmable footer. Clear button. | Widget tests cover open/close, single/multi select, search, validation, confirmable, clear, keyboard. |
| 3 | **Layer 2a — `RawStaticDropify`** | The widget + tests. Default `entryBuilder`. | Static page in example app works end-to-end. |
| 4 | **Layer 2b — `RawAsyncDropify`** | The widget + `DropifyAsyncState` + `CancelToken` + tests with `Completer`-driven fakes. | Async page in example app works (loading / data / empty / error / retry / refreshing). |
| 5 | **Layer 2c — `RawPaginatedDropify`** | The widget + tests with fake `PagingController`. Honors `refreshOnSearch`. | Paginated page in example app works (first page progress, next page progress, error retry, no more items, refresh-on-search). |
| 6 | **Layer 3 — themed widgets** | `DropifyDropdown`, `DropifyAsyncDropdown`, `DropifyPaginatedDropdown`. Default themed anchor (Material surface, label, hint, error, chevron, clear). | Themed page in example app shows all three; theme overrides round-trip. |
| 7 | **Polish & a11y** | Semantics audit, type-ahead-into-search, focus restoration on close, README + dartdoc + topics, `flutter analyze` & `dart format` green, `pub publish --dry-run` clean. | Ready for `v0.1.0`. |

---

## 20. v2 backlog (out of scope for this spec)

- Section headers / dividers / sticky group headers.
- Bottom-sheet presentation mode (`DropifyPresentation.bottomSheet`).
- Cupertino theme variant.
- Drag-to-reorder selected chips for multi-select anchor.
- Custom positioning strategies (popup-above, side-anchored).
- Server-side multi-select with chunked load.
- Golden tests baseline.

---

## 21. Open conventions

- All public APIs documented with dartdoc; reference Flutter framework style (see `flutter_raw_menu_anchor.dart`).
- No `print` / `debugPrint` outside `assert(_debug…())` helpers.
- Follow `flutter_lints: ^6.0.0`; zero analyzer warnings.
- Every `if`/`for`/`while` uses braces (matches reference files).
- Use `sealed` classes for closed state hierarchies (`DropifyAsyncState`, `DropifyValue`).
- Favor `const` constructors and `@immutable` value types.
- No use of `late` for fields that can be `final` + initialized in `initState`.
