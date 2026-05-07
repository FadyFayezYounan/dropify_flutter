# Public API Contract

All listed APIs are additive for `dropify_flutter` v0.1.0 and exported through:

```dart
import 'package:dropify_flutter/dropify_flutter.dart';
```

## Core Exports

```dart
export 'src/core/raw_dropify.dart' show RawDropify;
export 'src/core/dropify_controller.dart' show DropifyController;
export 'src/core/dropify_entry.dart' show DropifyEntry;
export 'src/core/dropify_selection.dart' show DropifySelectionMode;
export 'src/core/dropify_value.dart'
    show DropifyValue, DropifySingleValue, DropifyMultiValue;
export 'src/core/dropify_cancel_token.dart'
    show DropifyCancelToken, DropifyCancelledException;
export 'src/core/dropify_paging_state.dart' show DropifyPagingState;
```

## Raw Widget Exports

```dart
export 'src/widgets/raw_static_dropify.dart' show RawStaticDropify;
export 'src/widgets/raw_async_dropify.dart'
    show RawAsyncDropify, DropifyAsyncState, DropifyAsyncFetcher;
export 'src/widgets/raw_paginated_dropify.dart' show RawPaginatedDropify;
```

## Themed Widget Exports

```dart
export 'src/widgets/dropify_dropdown.dart' show DropifyDropdown;
export 'src/widgets/dropify_async_dropdown.dart' show DropifyAsyncDropdown;
export 'src/widgets/dropify_paginated_dropdown.dart'
    show DropifyPaginatedDropdown;
```

## Theme Exports

```dart
export 'src/theme/dropify_theme.dart' show DropifyTheme;
export 'src/theme/dropify_theme_data.dart' show DropifyThemeData;
```

## Paging Dependency Re-Exports

```dart
export 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart'
    show PagingState, PagingStateBase, Defaulted, Omit;
```

## Required Public Constructors

The implementation must provide single and multi constructors for:

- `RawDropify<T>`
- `RawStaticDropify<T>`
- `RawAsyncDropify<T>`
- `RawPaginatedDropify<PageKey, T>`
- `DropifyDropdown<T>`
- `DropifyAsyncDropdown<T>`
- `DropifyPaginatedDropdown<PageKey, T>`

Multi constructors must support `confirmable`, `confirmLabel`, and `cancelLabel`.

## Required Shared Arguments

Raw and themed variants expose the relevant subset of:

- `controller`
- `initialValue` or `initialValues`
- `onChanged` or `onChangedMulti`
- `searchController`
- `searchable`
- `searchHintText`
- `searchDebounce`
- `showClearButton`
- `enabled`
- `autofocus`
- `focusNode`
- `onOpen`
- `onClose`
- `validator`
- `autovalidateMode`
- `errorTextBuilder`
- `keyOf`
- `equals`
- configurable labels/messages for all built-in visible copy

## Static Contract

`RawStaticDropify` and `DropifyDropdown` accept `List<DropifyEntry<T>>`.

Required behavior:

- Default search is case-insensitive contains over `searchableText`, `label`, or `value.toString()`.
- A custom matcher can override default matching.
- Disabled entries render inactive and cannot be selected.
- Lists larger than 50 entries use visible-row builder presentation.

## Async Contract

`DropifyAsyncFetcher<T>`:

```dart
typedef DropifyAsyncFetcher<T> = Future<List<T>> Function(
  String query, {
  required DropifyCancelToken cancel,
});
```

Required behavior:

- Default debounce is 300 ms.
- `loadOnOpen` defaults to true.
- `cacheItems` defaults to true.
- Cache lifetime is one widget instance and clears on dispose/reset.
- Replacement fetch cancels the previous token.
- Late stale results are ignored.
- Loading, refreshing, data, empty, error, and retry slots are exposed.

## Paginated Contract

`RawPaginatedDropify` and `DropifyPaginatedDropdown` accept:

- `PagingState<PageKey, T> state`
- `FutureOr<void> Function() fetchNextPage`
- `void Function(String query)? onSearchChanged`
- `int invisibleItemsThreshold`

Required behavior:

- Dropify never mutates caller paging state.
- `fetchNextPage` is invoked on first open when enabled and no pages are loaded.
- Search changes notify the caller after debounce.
- Retry actions call `fetchNextPage`.
- First-page loading, new-page loading, first-page error, new-page error, no-items, and no-more-items slots are exposed.

## Theme Contract

`DropifyThemeData` must support:

- `DropifyThemeData.fromMaterial(ThemeData theme)`
- `copyWith`
- `lerp`
- package-specific slot builders
- anchor, panel, search, entry, state, and footer token groups

Resolution order:

```text
instance value
DropifyTheme.of(context)
Theme.of(context).extension<DropifyThemeData>()
DropifyThemeData.fromMaterial(Theme.of(context))
```

## Semver Contract

After v0.1.0 release, public widgets, models, exported types, constructor parameters, enum values, semantic keys, and documented behaviors cannot break within the same semver minor version.
