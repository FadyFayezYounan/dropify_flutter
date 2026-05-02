# Dropify Flutter

A universal Flutter dropdown package for static lists, debounced async search,
caller-owned paginated results, multi-select, raw custom overlays, and `Form`
validation through one consistent API.

## Install

```yaml
dependencies:
  dropify_flutter: ^0.1.0
```

```dart
import 'package:dropify_flutter/dropify_flutter.dart';
```

## Which Widget Should I Use?

| Use case | Widget |
|---|---|
| In-memory options with Material styling | `DropifyDropdown<T>` |
| Remote search with loading, empty, error, and retry states | `DropifyAsyncDropdown<T>` |
| Infinite lists backed by caller-owned `PagingState` | `DropifyPaginatedDropdown<PageKey, T>` |
| Fully custom anchor or panel UI | `RawDropify<T>` |
| Raw static, async, or paginated behavior with custom rows | `RawStaticDropify<T>`, `RawAsyncDropify<T>`, `RawPaginatedDropify<PageKey, T>` |

## Package Layers

Dropify is split into three layers:

| Layer | Purpose |
|---|---|
| Core | `RawDropify`, `DropifyController`, `DropifyValue`, and selection identity. |
| Raw variants | Static, async, and paginated dropdown behavior without Material anchor styling. |
| Themed variants | Material 3-oriented widgets backed by `DropifyThemeData`. |

All public APIs are exported from `package:dropify_flutter/dropify_flutter.dart`.

## Static Dropdown

Use `DropifyDropdown` when all options are available in memory.

```dart
DropifyDropdown<String>(
  entries: const [
    DropifyEntry(value: 'apple', label: 'Apple'),
    DropifyEntry(value: 'banana', label: 'Banana'),
    DropifyEntry(value: 'orange', label: 'Orange', enabled: false),
  ],
  label: 'Fruit',
  searchable: true,
  showClearButton: true,
  onChanged: (value) {},
)
```

Static search uses `DropifyEntry.searchableText`, then `label`, then
`value.toString()`. Disabled entries remain visible but cannot be selected.

When a static dropdown opens with an existing selection, Dropify jumps the row
body to the first selected item that is present in the current filtered rows.
Set `scrollToSelectedOnOpen: false` to keep the normal initial offset.

## Async Dropdown

Use `DropifyAsyncDropdown` when options come from a remote search or expensive
lookup.

```dart
DropifyAsyncDropdown<Country>(
  fetcher: (query, {required cancel}) {
    return api.searchCountries(query, cancel: cancel);
  },
  itemLabelBuilder: (country) => country.name,
  label: 'Country',
  onChanged: (country) {},
)
```

The fetcher receives a `DropifyCancelToken`. Replacement searches cancel the
previous token, late stale results are ignored, and retry repeats the latest
query. Async results are cached for the lifetime of the widget instance by
default.

Async dropdowns also jump to a selected item when it is present in the currently
rendered loaded or refreshing rows. Dropify never fetches extra async results to
locate a selected value.

## Menu Body Modes

Static and async dropdowns expose `menuBodyMode`:

| Mode | Static rows | Async loaded/refreshing rows |
|---|---|---|
| `DropifyMenuBodyMode.automatic` | Eager up to 50 filtered rows, lazy above 50. | Lazy indexed rows. |
| `DropifyMenuBodyMode.eagerColumn` | `SingleChildScrollView` with an eager `Column`. | `SingleChildScrollView` with an eager `Column`. |
| `DropifyMenuBodyMode.lazyIndexed` | Lazy indexed rows for every non-empty filtered list. | Lazy indexed rows. |

Paginated dropdowns do not expose these options; their row body remains owned by
the caller-supplied paging state.

## Paginated Dropdown

Use `DropifyPaginatedDropdown` when the caller owns paging state.

```dart
DropifyPaginatedDropdown<int, Country>(
  state: pagingState,
  fetchNextPage: fetchNextPage,
  onSearchChanged: resetForSearch,
  itemLabelBuilder: (country) => country.name,
  label: 'Country',
  onChanged: (country) {},
)
```

Dropify never mutates `PagingState`. It renders first-page, next-page, empty,
error, retry, and no-more-items states from the state supplied by the caller.
Search changes call `onSearchChanged` after debounce so the caller can cancel
old work, reset pages, and fetch the new query.

## Selection Modes

Every dropdown variant supports single selection and multi-selection.

```dart
DropifyDropdown<String>.multi(
  entries: entries,
  label: 'Tags',
  onChanged: (values) {},
)
```

For staged multi-select, set `confirmable` on the multi constructor.

```dart
DropifyDropdown<String>.multi(
  entries: entries,
  label: 'Tags',
  confirmable: true,
  confirmLabel: 'Apply',
  cancelLabel: 'Cancel',
  onChanged: (values) {},
)
```

Use `keyOf` or `equals` when values should be compared by stable identity rather
than Dart object equality.

## Form Validation

Dropify widgets integrate with `Form` through their `validator` argument.
Validators receive a `DropifyValue<T>` that can be pattern matched.

```dart
DropifyDropdown<String>(
  entries: entries,
  label: 'Fruit',
  validator: (value) {
    return switch (value) {
      DropifySingleValue<String>(value: final selected) =>
        selected == null ? 'Choose a fruit' : null,
      DropifyMultiValue<String>() => null,
    };
  },
)
```

`Form.reset()` restores the dropdown to its initial selection and resets the
validation state.

## Theming

Use `DropifyTheme` for a subtree override, or install `DropifyThemeData` as a
Flutter `ThemeExtension`.

```dart
DropifyTheme(
  data: DropifyThemeData.fromMaterial(Theme.of(context)).copyWith(
    panelMaxHeight: 360,
    panelElevation: 6,
    panelShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
  child: DropifyDropdown<String>(entries: entries),
)
```

Theme resolution follows this order: instance value, `DropifyTheme`, host
`ThemeData.extension<DropifyThemeData>()`, then
`DropifyThemeData.fromMaterial(Theme.of(context))`.

## Accessibility And Testing

Dropify exposes semantic labels and stable keys for anchors, panels, search,
items, state slots, retry actions, and confirmable multi-select footer actions.
Stable keys do not depend on localized visible text.

See [Accessibility and testing](doc/accessibility_and_testing.md) for the full
key list and testing guidance.

## Guides

- [Static dropdowns](doc/static_dropdowns.md)
- [Async dropdowns](doc/async_dropdowns.md)
- [Paginated dropdowns](doc/paginated_dropdowns.md)
- [Raw customization](doc/raw_customization.md)
- [Selection and forms](doc/selection_and_forms.md)
- [Theming](doc/theming.md)
- [Accessibility and testing](doc/accessibility_and_testing.md)
- [Example app](example/README.md)

## Prior Art

Dropify follows Flutter's `RawMenuAnchor`, `MenuAnchor`, and Material
`DropdownMenu` interaction patterns. The paginated API is designed to work with
`infinite_scroll_pagination` and caller-owned async search flows.
