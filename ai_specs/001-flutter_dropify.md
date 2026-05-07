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
export 'src/core/dropify_cancel_token.dart'
    show DropifyCancelToken, DropifyCancelledException;
export 'src/core/dropify_paging_state.dart' show DropifyPagingState;

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
// for the value type used in their own state. Includes Defaulted/Omit so users
// can subclass DropifyPagingState in their own state code if they need extra fields.
export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingState, PagingStateBase, Defaulted, Omit;
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
      dropify_cancel_token.dart              # DropifyCancelToken + DropifyCancelledException
      dropify_paging_state.dart              # DropifyPagingState<PageKey, T> (extends PagingStateBase)
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
    Future<List<T>> Function(String query, {required DropifyCancelToken cancel});

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

- On open: if `loadOnOpen && (cache miss for current query)`, dispatch `fetcher(query, cancel: token)`. Otherwise emit cached data.
- On search change: debounce per `RawDropify.searchDebounce`, then fetch. **Always cancels** the in-flight request via `token.cancel()` before issuing the next one.
- On widget dispose, panel close (when `keepAliveOnClose: false`), or another fetch starting: the previous `DropifyCancelToken` is cancelled.
- Cache keyed by `query` string; cleared on widget dispose. `cacheItems: false` disables.
- When data is present and a refetch starts, transitions to `DropifyAsyncRefreshing(staleItems)` so the panel can show the old list with a small spinner.
- `loadingBuilder` / `errorBuilder` / `emptyBuilder` resolve in this order: instance arg → `DropifyThemeData` → built-in default.
- Selecting an item in single mode closes the panel as usual; in multi mode toggles.

### 10.4 Cancel token

Defined once in `lib/src/core/dropify_cancel_token.dart` and reused by both async and paginated layers:

```dart
class DropifyCancelToken {
  DropifyCancelToken();

  bool _cancelled = false;
  final Completer<void> _completer = Completer<void>();

  bool get isCancelled => _cancelled;
  Future<void> get whenCancelled => _completer.future;

  void cancel() {
    if (_cancelled) {
      return;
    }
    _cancelled = true;
    _completer.complete();
  }

  void throwIfCancelled() {
    if (_cancelled) {
      throw const DropifyCancelledException();
    }
  }
}

class DropifyCancelledException implements Exception {
  const DropifyCancelledException();
  @override
  String toString() => 'DropifyCancelledException: operation cancelled';
}
```

If users prefer `package:dio`'s `CancelToken`, they can wire `DropifyCancelToken.whenCancelled.then((_) => dioToken.cancel())` at the call site — the contract is intentionally trivial.

---

## 11. Layer 2c — `RawPaginatedDropify`

Paginated fetch using `infinite_scroll_pagination: ^5.1.1`. **The user owns the `PagingState`** and the `fetchNextPage` callback — `RawPaginatedDropify` is a pure consumer of both. No `PagingController` is involved.

### 11.1 API

```dart
class RawPaginatedDropify<PageKey, T> extends StatefulWidget {
  const RawPaginatedDropify({
    required this.state,                   // PagingState<PageKey, T> — owned by caller
    required this.fetchNextPage,           // Future<void> Function() or VoidCallback
    required this.anchorBuilder,
    required this.itemBuilder,             // (ctx, item, index, selected, onTap) => Widget
    this.firstPageProgressBuilder,
    this.newPageProgressBuilder,
    this.firstPageErrorBuilder,            // receives retry callback (= fetchNextPage)
    this.newPageErrorBuilder,
    this.noItemsFoundBuilder,
    this.noMoreItemsBuilder,
    this.invisibleItemsThreshold = 3,
    this.onSearchChanged,                  // void Function(String query) — caller resets/refetches
    this.keyOf,
    // …passes through RawDropify args; searchable defaults to true here too…
  });

  // .multi constructor analogous

  final PagingState<PageKey, T> state;
  final FutureOr<void> Function() fetchNextPage;
  final void Function(String query)? onSearchChanged;
  // …
}
```

### 11.2 Caller responsibilities

The caller (typically a `StatefulWidget`, but a `Bloc` / `Cubit` / `Notifier` / `ChangeNotifier` works just as well) holds the paging state, mutates it on transitions, and feeds it back into `RawPaginatedDropify` on each rebuild. The recommended state type is `DropifyPagingState<PageKey, T>` (defined in §11.5), which extends `PagingStateBase` and bakes in two fields the package always needs: `search` and `cancelToken`. This mirrors the cancel-aware pattern from `BlocPagingState` in the user-supplied example.

A canonical `setState`-based caller:

```dart
class _MyScreenState extends State<MyScreen> {
  DropifyPagingState<int, Country> _state = DropifyPagingState();

  Future<void> _fetchNextPage() async {
    final current = _state;
    if (current.isLoading || !current.hasNextPage) {
      return;
    }

    // Compute next page key per the v5.1.1 contract.
    final pageKey = current.lastPageIsEmpty ? null : current.nextIntPageKey;
    if (pageKey == null) {
      setState(() => _state = current.copyWith(hasNextPage: false));
      return;
    }

    // Cancel any in-flight fetch from a previous call before issuing a new one.
    current.cancelToken?.cancel();
    final token = DropifyCancelToken();

    setState(() => _state = current.copyWith(
      isLoading:   true,
      error:       null,
      cancelToken: token,
    ));

    try {
      final items = await api.searchCountries(
        current.search,
        page: pageKey,
        cancel: token,
      );
      if (token.isCancelled) {
        return;
      }
      final isLast = items.isEmpty;
      setState(() => _state = _state.copyWith(
        isLoading:   false,
        error:       null,
        hasNextPage: !isLast,
        pages:       [...?_state.pages, items],
        keys:        [...?_state.keys, pageKey],
        cancelToken: null,
      ));
    } catch (e) {
      if (!token.isCancelled) {
        setState(() => _state = _state.copyWith(
          isLoading:   false,
          error:       e,
          cancelToken: null,
        ));
      }
    }
  }

  void _onSearchChanged(String q) {
    // Cancel pending fetch, reset pages, preserve search.
    _state.cancelToken?.cancel();
    setState(() => _state = _state.reset().copyWith(search: q));
    _fetchNextPage();
  }

  @override
  void dispose() {
    _state.cancelToken?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RawPaginatedDropify<int, Country>(
    state:           _state,
    fetchNextPage:   _fetchNextPage,
    onSearchChanged: _onSearchChanged,
    anchorBuilder:   ...,
    itemBuilder:     ...,
  );
}
```

A bloc-based equivalent ships in `example/lib/pages/paginated_page.dart` to demonstrate that the same `DropifyPagingState` works as a `Bloc<PagingEvent, DropifyPagingState<int, Country>>` state without modification.

### 11.3 Internal behavior

- The panel body wraps the user's `state` and `fetchNextPage` into a `PagedListView` directly:

  ```dart
  PagedListView<PageKey, T>(
    state: widget.state,
    fetchNextPage: widget.fetchNextPage,
    builderDelegate: PagedChildBuilderDelegate<T>(
      invisibleItemsThreshold: widget.invisibleItemsThreshold,
      itemBuilder: (ctx, item, i) =>
          widget.itemBuilder(ctx, item, i, isSelected(item), () => onTap(item)),
      firstPageProgressIndicatorBuilder: _resolve(widget.firstPageProgressBuilder, theme.firstPageProgressBuilder, _defaults.firstPageProgress),
      newPageProgressIndicatorBuilder:   _resolve(widget.newPageProgressBuilder,   theme.newPageProgressBuilder,   _defaults.newPageProgress),
      firstPageErrorIndicatorBuilder:    _resolveError(widget.firstPageErrorBuilder, theme.firstPageErrorBuilder, _defaults.firstPageError, retry: widget.fetchNextPage),
      newPageErrorIndicatorBuilder:      _resolveError(widget.newPageErrorBuilder,   theme.newPageErrorBuilder,   _defaults.newPageError,   retry: widget.fetchNextPage),
      noItemsFoundIndicatorBuilder:      _resolve(widget.noItemsFoundBuilder, theme.noResultsBuilder, _defaults.noResults),
      noMoreItemsIndicatorBuilder:       _resolve(widget.noMoreItemsBuilder,  theme.noMoreItemsBuilder, _defaults.noMoreItems),
    ),
  )
  ```

- **No internal state** for pagination — `RawPaginatedDropify` does not call `setState` to mutate `PagingState`. It only reads.
- **Search**: when the search query changes (after debounce), the widget calls `onSearchChanged?.call(query)`. It is the caller's responsibility to reset their local `PagingState` and trigger a fresh `fetchNextPage()`. If `onSearchChanged` is null, the search field is still rendered but query changes have no side effect — useful when search is purely cosmetic / handled out-of-band.
- **`loadOnOpen` semantics**: on first open, if `state.pages == null`, `RawPaginatedDropify` calls `fetchNextPage()` once. Disable by passing `loadOnOpen: false` (inherited from `RawDropify`).
- **Retry**: the error builders receive a `VoidCallback retry` that simply calls `widget.fetchNextPage` again — the caller's `fetchNextPage` is expected to be retry-safe (clear `error` then attempt fetch).

### 11.4 Why expose `PagingState` directly?

- The caller already manages the source of truth (search query, user-specific filters, custom cursor logic). Forcing them to construct a `PagingController` would mean dropify owns state the caller really owns.
- It mirrors `PagedListView`'s own simplest contract (`state` + `fetchNextPage`), so users who already know `infinite_scroll_pagination` find the API obvious.
- It avoids a second source of truth: only one widget tree holds the state, and dropify is a pure consumer.

### 11.5 `DropifyPagingState<PageKey, T>` — recommended state type

A first-class `PagingStateBase` subclass shipped with the package. It adds the two fields every dropify-paginated caller needs:

- `search`: the current query string used to scope fetches.
- `cancelToken`: a `DropifyCancelToken?` representing an in-flight fetch that should be cancelled on the next state mutation (search change, refresh, or dispose).

```dart
@immutable
final class DropifyPagingState<PageKey, T> extends PagingStateBase<PageKey, T> {
  DropifyPagingState({
    super.pages,
    super.keys,
    super.error,
    super.hasNextPage,
    super.isLoading,
    this.search,
    this.cancelToken,
  });

  final String? search;
  final DropifyCancelToken? cancelToken;

  @override
  DropifyPagingState<PageKey, T> copyWith({
    Defaulted<List<List<T>>?>? pages       = const Omit(),
    Defaulted<List<PageKey>?>? keys        = const Omit(),
    Defaulted<Object?>?         error       = const Omit(),
    Defaulted<bool>?            hasNextPage = const Omit(),
    Defaulted<bool>?            isLoading   = const Omit(),
    Defaulted<String?>          search      = const Omit(),
    Defaulted<DropifyCancelToken?> cancelToken = const Omit(),
  }) {
    return DropifyPagingState<PageKey, T>(
      pages:       pages       is Omit ? this.pages       : pages       as List<List<T>>?,
      keys:        keys        is Omit ? this.keys        : keys        as List<PageKey>?,
      error:       error       is Omit ? this.error       : error,
      hasNextPage: hasNextPage is Omit ? this.hasNextPage : hasNextPage as bool,
      isLoading:   isLoading   is Omit ? this.isLoading   : isLoading   as bool,
      search:      search      is Omit ? this.search      : search      as String?,
      cancelToken: cancelToken is Omit ? this.cancelToken : cancelToken as DropifyCancelToken?,
    );
  }

  /// Reset all paging fields to their initial values while preserving [search]
  /// and minting a fresh [cancelToken]. The previous token is **not** cancelled
  /// here — callers should cancel it before calling [reset] if a fetch is
  /// in-flight (see the §11.2 example).
  @override
  DropifyPagingState<PageKey, T> reset() {
    return DropifyPagingState<PageKey, T>(
      pages:       null,
      keys:        null,
      error:       null,
      hasNextPage: true,
      isLoading:   false,
      search:      search,
      cancelToken: DropifyCancelToken(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DropifyPagingState<PageKey, T>
        && super == other
        && search == other.search
        && cancelToken == other.cancelToken;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, search, cancelToken);
}
```

**Cancellation contract:**

| Mutation | Caller does | Why |
|----------|-------------|-----|
| Search changes | `state.cancelToken?.cancel(); state.reset().copyWith(search: q);` then `fetchNextPage()` | Discard stale fetch; new query owns its own token. |
| Pull-to-refresh / explicit refresh | `state.cancelToken?.cancel(); state.reset();` then `fetchNextPage()` | Same as above, search preserved by `reset()`. |
| New page fetch starts | `current.cancelToken?.cancel();` then `copyWith(cancelToken: newToken, isLoading: true)` | Defensive: ensures only one fetch is alive at a time. |
| Widget / bloc disposal | `state.cancelToken?.cancel()` in `dispose` / `close` | Prevents `setState` after dispose and lets the API client free network resources. |

After `await fetchFn(...)` returns, the caller **must check `token.isCancelled`** before mutating state — if cancelled, drop the result silently. The §11.2 example shows the canonical `try / cancel-check / catch / cancel-check` shape.

`RawPaginatedDropify` accepts the parent type `PagingState<PageKey, T>`, so callers can still pass a plain `PagingState()` if they don't want cancellation. `DropifyPagingState` is strictly recommended for production use.

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
- `required PagingState<PageKey, T> state`
- `required FutureOr<void> Function() fetchNextPage`
- `void Function(String query)? onSearchChanged`
- `required String Function(T) itemLabelBuilder`
- All paginated slot builders optional.
- `searchable` defaults to **`true`**.

The themed wrapper does not own pagination state either — the caller still manages `PagingState` exactly as in §11.2. Layer 3 only adds default theming for the anchor and item rows.

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
| Source | client `matcher` | server fetch | caller-owned via `onSearchChanged` callback |
| Debounce | none (instant) | `searchDebounce` (default 300 ms) | `searchDebounce` (default 300 ms) |
| Empty behavior | `noResultsBuilder` when filtered list is empty | `DropifyAsyncEmpty(hasQuery: true)` | `noItemsFoundBuilder` |
| Reset | clearing query restores full list | clearing query refetches with `''` | `onSearchChanged('')` fires; caller resets `PagingState` and refetches |
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
| `paginated_page.dart` | `DropifyPaginatedDropdown` with fake paginated API (page size 20, 200 total items, optional injected error). Caller uses `DropifyPagingState<int, Country>` + `DropifyCancelToken`, demonstrating cancel-on-search, cancel-on-dispose, retry, no-more-items. A second variant on the same page wires the same state to a tiny `Bloc` to prove the state type works with bloc unchanged. |
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
- `dropify_cancel_token_test.dart` — `cancel()` is idempotent, `isCancelled` flips, `whenCancelled` completes once, `throwIfCancelled` throws `DropifyCancelledException` after cancellation and is a no-op before.
- `dropify_paging_state_test.dart` — defaults match `PagingState()`; `copyWith` honors `Omit` semantics for every field including `search` and `cancelToken`; `reset()` clears pages/keys/error/isLoading, sets `hasNextPage: true`, **preserves `search`**, and **mints a fresh `cancelToken`** distinct from the previous one (`identical(...) == false`); equality and `hashCode` cover `search` and `cancelToken`.

### 18.2 Widget (`test/widgets/`)

For each widget: anchor renders, opens on tap, closes on outside tap, closes on `Esc`, single selects + closes, multi toggles + stays open, `clear` resets, `searchable: true` shows field and filters, validation error displays.

Specifics:

- `raw_async_dropify_test.dart` — uses `Completer<List<T>>` to drive state transitions; asserts loading→data→empty→error→retry; cache hit on re-open same query; cache miss on changed query; cancellation when query changes mid-flight.
- `raw_paginated_dropify_test.dart` — uses a stateful host that owns `DropifyPagingState<int, T>` and a `fetchNextPage` driven by a `Completer`. Asserts each state shape renders the right slot: `firstPageProgress` (pages == null + isLoading), `newPageProgress` (has pages + isLoading), `firstPageError` + retry, `newPageError`, `noItemsFound` (pages exists, all empty), `noMoreItems` (`hasNextPage == false`). Asserts `onSearchChanged` fires after debounce on query change and is **not** called when search is cleared without a prior query. Cancellation behavior: when search changes mid-fetch, the previous `DropifyCancelToken.isCancelled` flips to `true` before the next fetch resolves, and the late result is dropped without mutating state.
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
| 1 | **Skeleton, theme & paging primitives** | `DropifyThemeData`, `DropifyTheme`, `ThemeExtension`, `_defaultMatcher`, `_Debouncer`, `DropifyEntry`, `DropifyController`, `DropifySelectionMode`, `DropifyValue`, `DropifyCancelToken`, `DropifyCancelledException`, `DropifyPagingState`. | Unit tests in §18.1 pass (incl. cancel-token + paging-state tests). No widgets yet. |
| 2 | **Layer 1 — `RawDropify`** | `RawDropify` (single + multi ctors), `_DropifyAnchor`, `_DropifyPanel`, `_DropifySearchField`, `_DropifyFocusScope`. Uses `RawMenuAnchor`. Validation via internal `FormField`. Confirmable footer. Clear button. | Widget tests cover open/close, single/multi select, search, validation, confirmable, clear, keyboard. |
| 3 | **Layer 2a — `RawStaticDropify`** | The widget + tests. Default `entryBuilder`. | Static page in example app works end-to-end. |
| 4 | **Layer 2b — `RawAsyncDropify`** | The widget + `DropifyAsyncState` + `DropifyAsyncFetcher` (uses `DropifyCancelToken` from phase 1) + tests with `Completer`-driven fakes. | Async page in example app works (loading / data / empty / error / retry / refreshing); aborted fetches do not mutate state after cancellation. |
| 5 | **Layer 2c — `RawPaginatedDropify`** | The widget + tests with caller-owned `DropifyPagingState` + `Completer`-driven `fetchNextPage`. Wires `onSearchChanged` debounce. | Paginated page in example app works end-to-end with cancel-on-search and cancel-on-dispose proven via tests. |
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
