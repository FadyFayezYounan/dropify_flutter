# Dropify Flutter — Universal Dropdown Package, v1 Plan

## Context

`dropify_flutter` is a fresh Flutter package (empty `lib/`, only a stub). The goal is a **universal dropdown** that can drive _any_ visual style/shape from a single primitive, while shipping ergonomic, opinionated widgets for the four common cases:

1. Static single-select
2. Static multi-select
3. Async (Future-backed) single/multi-select
4. Paginated (via `infinite_scroll_pagination`) single/multi-select

All four flavors share one core: anchor → overlay → search → state-driven body. Today there is no Flutter package that covers static + async + paginated + form-field with a single coherent API and a theme system. Material's `DropdownMenu` covers static only, and async/paginated typically force devs to wire `OverlayPortal` + lists by hand.

The package is layered after Flutter's own `RawMenuAnchor` → `MenuAnchor` → `DropdownMenu` ladder, so the code style and naming match the three reference files in `refrences/`.

## Architecture (3 layers)

```
                   ┌──────────────────────────────┐
Layer 3 (form)     │  DropifyFormField<T> / .multi│  wraps a concrete widget in FormField<T>
                   └──────────────┬───────────────┘
                                  │
                   ┌──────────────┴──────────────────────────────────────────┐
Layer 2 (concrete) │  DropifyDropdown / DropifyAsyncDropdown /                │
                   │  DropifyPaginatedDropdown   (each + .multi)              │
                   │  -- opinionated chrome: search bar, panel decoration,    │
                   │     loading/error/empty defaults, anchor decoration      │
                   └──────────────┬──────────────────────────────────────────┘
                                  │
                   ┌──────────────┴──────────────┐
Layer 1 (raw)      │  RawDropify<T> / .multi     │  single responsibility:
                   │                              │   anchor + overlay + state
                   │                              │   plumbing. Body is 100%
                   │                              │   user-controlled.
                   └──────────────┬──────────────┘
                                  │ built on
                   ┌──────────────┴──────────────┐
Flutter primitive  │  RawMenuAnchor + MenuController │  focus traversal, tap-
                   │                                  │  outside, scroll-close,
                   │                                  │  view-resize-close,
                   │                                  │  escape-to-dismiss
                   └─────────────────────────────────┘
```

**Layering rule**: Layer 2 is implemented as a thin `RawDropify` body builder that renders the opinionated panel; no overlay/positioning logic is duplicated above Layer 1.

## Public API (v1)

### `DropifyEntry<T>` (mirrors `DropdownMenuEntry<T>`)

```dart
@immutable
class DropifyEntry<T> {
  const DropifyEntry({
    required this.value,
    required this.label,
    this.labelWidget,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
    this.style,
  });

  final T value;
  final String label;          // used by default search matcher
  final Widget? labelWidget;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool enabled;
  final ButtonStyle? style;    // optional, for default item rendering
}
```

Selection equality uses `==` on `value` (matches Material's `DropdownMenuEntry` contract).

### `DropifyController<T>`

`TextEditingController`-style. Optional on every widget; an internal one is created when omitted (mirroring `TextField`).

```dart
abstract class DropifyController<T> implements Listenable {
  factory DropifyController.single({T? initialValue}) = _SingleDropifyController<T>;
  factory DropifyController.multi({List<T> initialValues = const []}) = _MultiDropifyController<T>;

  bool get isMulti;
  bool get isOpen;
  String get query;
  DropifyStatus get status;            // for async/paginated — idle/loading/data/error/empty
  Object? get error;
  List<DropifyEntry<T>> get entries;   // current snapshot (filtered for static, fetched for async)

  // Single-select view (throws if multi)
  T? get singleValue;
  set singleValue(T? value);

  // Multi-select view (throws if single)
  List<T> get multiValues;
  set multiValues(List<T> values);

  // Operations
  void open({Offset? position});
  void close();
  void setQuery(String value);
  Future<void> refresh();              // async/paginated only — re-runs fetch
  Future<void> loadMore();             // paginated only
  void retry();                        // async/paginated only
}
```

### `DropifyState<T>`

The single object passed to `RawDropify.bodyBuilder` (and to layer-2 sub-builders such as `loadingBuilder`, `errorBuilder`).

```dart
@immutable
class DropifyState<T> {
  final DropifyController<T> controller;
  final List<DropifyEntry<T>> entries;       // already filtered by query
  final DropifyStatus status;                // idle/loading/data/error/empty
  final Object? error;
  final bool hasMore;                        // paginated
  final RawMenuOverlayInfo overlayInfo;      // anchor rect, overlay size, tap region group
  // Helpers for body:
  bool isSelected(T value);
  void toggle(T value);                      // honors single vs multi semantics
}

enum DropifyStatus { idle, loading, data, empty, error }
```

### `RawDropify<T>` (Layer 1 — the primitive)

```dart
class RawDropify<T> extends StatefulWidget {
  const RawDropify({
    super.key,
    this.controller,
    this.dataSource,                                // sealed: Static | Async | Paginated
    required this.anchorBuilder,                    // closed-state widget
    required this.bodyBuilder,                      // open-state widget (full panel)
    this.onSelectionChanged,
    this.onOpenChanged,
    this.onQueryChanged,
    this.useRootOverlay = false,
    this.consumeOutsideTaps = false,
    this.closeOnSelect,                             // default: true single, false multi
    this.queryDebounce = const Duration(milliseconds: 300),
    this.staticMatcher,                             // default: case-insensitive label.contains
  });

  const RawDropify.multi({ /* same params, multi-select semantics */ });

  // ... layer-1 fields
}

typedef DropifyAnchorBuilder<T> = Widget Function(
  BuildContext context,
  DropifyController<T> controller,
);

typedef DropifyBodyBuilder<T> = Widget Function(
  BuildContext context,
  DropifyState<T> state,
);
```

Implemented on top of `RawMenuAnchor.overlayBuilder`. `RawDropify` does **not** render any chrome — no search field, no panel decoration, no item list. The `bodyBuilder` returns whatever the developer wants; the only thing the core does inside the overlay is wrap the body in a `TapRegion(groupId: state.overlayInfo.tapRegionGroupId)`.

### Data sources (sealed)

```dart
sealed class DropifyDataSource<T> { const DropifyDataSource(); }

class StaticDropifyDataSource<T> extends DropifyDataSource<T> {
  const StaticDropifyDataSource(this.entries);
  final List<DropifyEntry<T>> entries;
}

class AsyncDropifyDataSource<T> extends DropifyDataSource<T> {
  const AsyncDropifyDataSource({required this.fetch, this.fetchOnOpen = true});
  final Future<List<DropifyEntry<T>>> Function(String query) fetch;
  final bool fetchOnOpen;
}

class PaginatedDropifyDataSource<T> extends DropifyDataSource<T> {
  const PaginatedDropifyDataSource({
    required this.fetchPage,
    this.firstPageKey = 1,
    this.pageSize = 20,
  });
  final Future<List<DropifyEntry<T>>> Function(int pageKey, String query) fetchPage;
  final int firstPageKey;
  final int pageSize;
}
```

The core inspects the runtime type and wires the right state machine. Static filtering uses `staticMatcher`; async/paginated uses the debounced query.

### Layer 2 — concrete widgets (siblings)

Each concrete widget delegates to `RawDropify` and provides:

- a default **anchor** (border + label + hint + chevron + chip strip for multi), customizable via `anchorBuilder`
- a default **panel** (search field on top, scrollable list of entries with selection state), customizable via `panelDecoration` and per-state builders
- per-state builders for async (`loadingBuilder`, `errorBuilder`, `emptyBuilder`)
- chip rendering for multi (`chipBuilder`)

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
    this.itemBuilder,                  // override default item rendering
    this.anchorBuilder,
    this.panelDecoration,
    this.emptyBuilder,
    this.staticMatcher,
    this.theme,                        // explicit override; otherwise inherited
    // ... a11y, validators-friendly props
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
    /* + same shared props */
  });
}

class DropifyAsyncDropdown<T> extends StatelessWidget {
  // same shape, but takes:
  //   required Future<List<DropifyEntry<T>>> Function(String query) fetch;
  //   final bool fetchOnOpen;
  //   final Widget Function(BuildContext, Object error, VoidCallback retry)? errorBuilder;
  //   final Widget Function(BuildContext)? loadingBuilder;
  // .multi mirrors DropifyDropdown.multi.
}

class DropifyPaginatedDropdown<T> extends StatelessWidget {
  // takes:
  //   required Future<List<DropifyEntry<T>>> Function(int pageKey, String query) fetchPage;
  //   final int firstPageKey;
  //   final int pageSize;
  //   final Widget Function(BuildContext, VoidCallback retry)? newPageErrorBuilder;
  //   final Widget Function(BuildContext)? noMoreItemsBuilder;
  // Internally uses PagingController from infinite_scroll_pagination.
  // .multi mirrors DropifyDropdown.multi.
}
```

### Layer 3 — `DropifyFormField<T>` / `.multi`

Wraps any of the layer-2 widgets in `FormField<T>` / `FormField<List<T>>`. Provides `validator`, `onSaved`, `autovalidateMode`, and an error decoration in the anchor.

```dart
class DropifyFormField<T> extends FormField<T> {
  // chooses the concrete widget via a sealed `source:` arg:
  //   DropifyFormSource.static(entries: ...)
  //   DropifyFormSource.async(fetch: ...)
  //   DropifyFormSource.paginated(fetchPage: ...)
  // .multi → FormField<List<T>>
}
```

A single `DropifyFormField` for all data sources (instead of three sibling form fields) keeps the form ergonomics simple; the source-specific config lives in the sealed `source:` arg. Picked deliberately even though Layer 2 is sibling-class-heavy, because here the `FormField` ceremony dominates and three near-duplicate classes would be noisy.

### Theming

```dart
@immutable
class DropifyThemeData {
  // anchor chrome
  final InputDecorationTheme? anchorDecoration;
  final TextStyle? anchorTextStyle;
  final IconData chevronIcon;
  // panel chrome
  final ShapeBorder panelShape;
  final Color? panelBackground;
  final EdgeInsetsGeometry panelPadding;
  final double panelMaxHeight;
  final BoxConstraints? panelConstraints;
  // search
  final InputDecoration searchDecoration;
  final Duration queryDebounce;
  // item
  final EdgeInsetsGeometry itemPadding;
  final TextStyle? itemTextStyle;
  final Color? selectedItemBackground;
  final Color? hoveredItemBackground;
  // chips (multi)
  final WidgetStateProperty<Color?>? chipBackground;
  final TextStyle? chipTextStyle;
  // states
  final Widget Function(BuildContext)? defaultLoadingBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)? defaultErrorBuilder;
  final Widget Function(BuildContext)? defaultEmptyBuilder;

  DropifyThemeData copyWith({...});
  DropifyThemeData lerp(DropifyThemeData other, double t);
  factory DropifyThemeData.light();
  factory DropifyThemeData.dark();
  factory DropifyThemeData.fromMaterial(BuildContext context); // bridges Theme.of for material apps
}

class DropifyTheme extends InheritedWidget {
  const DropifyTheme({super.key, required this.data, required super.child});
  final DropifyThemeData data;

  static DropifyThemeData of(BuildContext context);
  static DropifyThemeData? maybeOf(BuildContext context);
}
```

Per-widget props always win over the inherited theme. Defaults are pure-widgets (no `MaterialApp` requirement), but the `fromMaterial` factory makes integration trivial in Material apps.

## File layout

```
lib/
├── dropify_flutter.dart                       # public barrel; re-exports the surface above
└── src/
    ├── core/
    │   ├── raw_dropify.dart                   # RawDropify<T> + .multi (built on RawMenuAnchor)
    │   ├── dropify_controller.dart            # DropifyController + single/multi impls
    │   ├── dropify_state.dart                 # DropifyState<T>, DropifyStatus enum
    │   ├── dropify_entry.dart                 # DropifyEntry<T>
    │   └── dropify_data_source.dart           # sealed Static/Async/Paginated source
    ├── theme/
    │   ├── dropify_theme.dart                 # DropifyTheme inherited widget
    │   └── dropify_theme_data.dart            # DropifyThemeData + light/dark/fromMaterial
    ├── widgets/
    │   ├── dropify_dropdown.dart              # static concrete + .multi
    │   ├── dropify_async_dropdown.dart        # async concrete + .multi
    │   ├── dropify_paginated_dropdown.dart    # paginated concrete + .multi
    │   ├── dropify_form_field.dart            # DropifyFormField<T> + .multi
    │   ├── _dropify_anchor.dart               # default anchor: label+chevron+chips
    │   ├── _dropify_panel.dart                # default panel: search + list
    │   └── _dropify_search_field.dart         # default search field, debounced
    └── internal/
        ├── debouncer.dart                     # async query debounce
        ├── default_matcher.dart               # static label.contains matcher
        └── paging.dart                        # adapter to PagingController<int, DropifyEntry<T>>

example/lib/
├── main.dart                                  # gallery
├── pages/
│   ├── static_page.dart                       # single + multi
│   ├── async_page.dart                        # single + multi
│   ├── paginated_page.dart                    # single + multi
│   ├── form_page.dart                         # FormField examples
│   ├── theming_page.dart                      # light/dark/custom theme
│   └── raw_page.dart                          # bespoke dropdown built directly on RawDropify

test/
├── core/
│   ├── raw_dropify_test.dart
│   ├── dropify_controller_test.dart
│   └── dropify_state_test.dart
├── widgets/
│   ├── dropify_dropdown_test.dart
│   ├── dropify_async_dropdown_test.dart
│   ├── dropify_paginated_dropdown_test.dart
│   └── dropify_form_field_test.dart
├── theme/
│   └── dropify_theme_test.dart
└── golden/                                    # optional, for default chrome
```

## Behavioral decisions (locked in v1)

- **Foundation**: `RawMenuAnchor` from `package:flutter/widgets.dart`. Inherits focus/tap-outside/scroll-close/view-resize-close/escape semantics — no reimplementation.
- **Identity**: `==` on `DropifyEntry.value` (matches `DropdownMenuEntry`). Pagination dedupes pages by the same key. No `keyOf` extractor.
- **Search**: layer 2 renders the search field at the top of the panel by default; `searchEnabled: false` removes it. Layer 1 owns only the _query state_ — placement is up to the body builder.
- **Static matcher**: case-insensitive `label.contains(query)`, overridable via `staticMatcher` (and via theme).
- **Async query**: debounced (`queryDebounce`, default 300 ms). Per-fetch cancellation via a request-token guard so out-of-order responses are dropped.
- **Pagination**: `PagingController<int, DropifyEntry<T>>` from `infinite_scroll_pagination`. Query change resets the controller to `firstPageKey`.
- **Close-on-select**: single → `true`, multi → `false`, both overridable.
- **Multi constraints**: optional `minSelection` / `maxSelection`; controller rejects toggles that would violate them and exposes a `lastRejectionReason` for UX.
- **Disabled entries**: `enabled: false` is non-toggleable, rendered with reduced opacity (default), keyboard skip.
- **Keyboard**: arrow up/down move focus inside panel, enter selects, escape closes (inherited from `RawMenuAnchor`'s default shortcuts). Search field consumes typing; arrow keys still navigate the list.
- **Cupertino/Material agnostic**: layer 1 uses only `package:flutter/widgets.dart`. Layer 2 uses `widgets.dart` chrome (nothing requires `MaterialApp`); the `fromMaterial` theme factory is the only Material bridge.
- **A11y**: each entry exposes `Semantics(button: true, selected: ...)`; the search field has its label, the panel announces result count on update.
- **Anchor width vs panel width**: panel width follows anchor by default (`panelConstraints` overridable via theme/prop).

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  infinite_scroll_pagination: ^5.1.0 # pin major when implementing; verify API at v5+

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

`infinite_scroll_pagination` is a hard dependency for v1 (the user explicitly chose the "full" scope). If we later need to slim down, paginated mode could be split into a `dropify_pagination` companion package — flagged but **out of scope** for v1.

## Delivery milestones (within v1)

Each milestone is a self-contained, reviewable PR. Milestones build on each other; **do not** start the next one before the previous one is merged & the example page works.

1. **M0 — Skeleton**: `pubspec` deps, file scaffold, `DropifyEntry`, `DropifyStatus`, `DropifyState`, `DropifyController` (single + multi), `DropifyTheme[Data]` with light/dark factories. Pure data + theme; no widgets that render. Unit tests.
2. **M1 — RawDropify on RawMenuAnchor**: `RawDropify<T>` + `.multi` with the `Static` data source only. Anchor + body builders, query state, debounce, static matcher. Example: a bespoke dropdown page proves Layer 1 works alone.
3. **M2 — DropifyDropdown (static concrete)**: default anchor, default panel, default search field, default item rendering, chip strip for multi. Example: static page (single + multi). Widget tests.
4. **M3 — Async data source**: `AsyncDropifyDataSource` + `DropifyAsyncDropdown` + `.multi` with `loadingBuilder`/`errorBuilder`/`emptyBuilder` defaults. Cancel out-of-order responses. Example: async page hitting a fake API.
5. **M4 — Paginated data source**: `PaginatedDropifyDataSource`, `_paging.dart` adapter, `DropifyPaginatedDropdown` + `.multi`. Query-change resets paging. Example: paginated page with infinite scroll. Tests for dedupe + reset.
6. **M5 — DropifyFormField**: single `DropifyFormField<T>` / `.multi` with sealed `source:`. Validator + error display in the anchor. Example: form page with all three sources.
7. **M6 — Polish & a11y**: keyboard nav verification, screen-reader pass, theming page in example, README + dartdoc, golden tests for default chrome (light + dark).

Stop the line if any milestone forces an API change in a previous milestone — fix the abstraction before continuing.

## Critical files to create

- [lib/src/core/raw_dropify.dart](lib/src/core/raw_dropify.dart) — Layer 1 primitive; the keystone of the package.
- [lib/src/core/dropify_controller.dart](lib/src/core/dropify_controller.dart) — single source of truth for selection + query + open state across all four modes.
- [lib/src/core/dropify_data_source.dart](lib/src/core/dropify_data_source.dart) — sealed type that lets `RawDropify` branch its state machine without the body builder caring.
- [lib/src/widgets/dropify_paginated_dropdown.dart](lib/src/widgets/dropify_paginated_dropdown.dart) — only widget that touches `infinite_scroll_pagination`; isolating it here keeps the rest of the package decoupled from that dep.
- [lib/src/widgets/dropify_form_field.dart](lib/src/widgets/dropify_form_field.dart) — Layer 3; the only file that knows about `Form`/`FormField`.
- [lib/src/theme/dropify_theme_data.dart](lib/src/theme/dropify_theme_data.dart) — theme contract; touch carefully, every default chrome widget reads from it.
- [lib/dropify_flutter.dart](lib/dropify_flutter.dart) — public surface; export _only_ the API listed above (no `src/` imports leak out).

## Reference patterns to copy from `refrences/`

- `_RawMenuAnchorBaseMixin` style mixin (refrences/flutter_raw_menu_anchor.dart:467) — apply the same shape to `_RawDropifyBaseMixin` so single + multi share lifecycle code (attach/detach controller, scroll-close, view-resize-close).
- `MenuController._attach` / `_detach` pattern (refrences/flutter_raw_menu_anchor.dart:1076) — replicate for `DropifyController` so a controller can only be bound to one widget at a time.
- `RawMenuOverlayInfo` (refrences/flutter_raw_menu_anchor.dart:54) — surface this through `DropifyState.overlayInfo` so body builders can position custom decorations relative to the anchor.
- `MenuController.maybeOf` / `maybeIsOpenOf` (refrences/flutter_raw_menu_anchor.dart:1092) — provide `DropifyController.maybeOf(context)` for descendants of a `RawDropify` body.
- Doc style and `{@tool dartpad}` blocks (refrences/flutter_dropdown_menu.dart) — match in dartdoc, including section headings and `See also:` lists.

## Verification

For each milestone:

1. **Unit & widget tests** (CI-gated):
   - `flutter test` green for every milestone.
   - Each public class has at minimum: construction, mutation, edge-case (empty / error / disabled / min-max).
   - Async tests use `fakeAsync` + a `Completer<List<DropifyEntry<T>>>` to simulate slow/error responses and verify cancellation of stale requests.
   - Paginated tests verify dedupe across pages, reset on query change, error-on-page handling.
2. **Example app smoke test**:
   - `cd example && flutter run -d <device>` (use `mcp__dart__list_devices` then `mcp__dart__launch_app`).
   - Visit each page (static / async / paginated / form / theming / raw) and exercise: open, type to search, scroll, select, multi-toggle, retry on error, submit form, switch theme.
   - Use `mcp__dart__hot_reload` between iterations; capture screenshots via `act-flutter-screenshot` for the README gallery.
3. **Static analysis & lints**:
   - `dart analyze` clean.
   - `dart format --set-exit-if-changed .` clean.
4. **Golden tests** (M6 only) for default light/dark chrome of the static dropdown anchor + open panel.

## Out of scope for v1 (deferred, but designed not to block)

- Cupertino-themed siblings (`CupertinoDropifyDropdown`).
- Hierarchical / grouped entries (sections, headers inside the panel).
- Drag-to-reorder selected chips in multi.
- Server-side **highlight** of search matches (just default bold-substring on labels in v1).
- Splitting paginated mode into a companion package (`dropify_pagination`) to avoid the hard dep.
- Per-entry custom payload widgets beyond `labelWidget` / `leadingIcon` / `trailingIcon`.
- RTL-specific anchor decoration tuning (tested but not specifically polished).
- Persistent recent-selections / "frecency" sort.

## Final spec destination

After this plan is approved, the same content (lightly edited for an audience of _implementers_ rather than _reviewers_) will be written to [ai_specs/001-flutter_dropify.md](ai_specs/001-flutter_dropify.md) as the durable spec the user asked for. The plan file here remains the planning artifact; the spec is the implementation contract.
