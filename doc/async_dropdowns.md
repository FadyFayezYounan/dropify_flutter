# Async Dropdowns

Use async dropdowns when options are loaded from a search API, database, or
expensive lookup.

## Minimal Example

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

## Fetcher Contract

`DropifyAsyncFetcher<T>` receives the latest query and a
`DropifyCancelToken`.

```dart
typedef DropifyAsyncFetcher<T> = Future<List<T>> Function(
  String query, {
  required DropifyCancelToken cancel,
});
```

Replacement searches cancel the previous token. Fetchers should either pass the
token into their own API layer or call `cancel.throwIfCancelled()` before
committing expensive work.

## Loading States

Raw async widgets expose these states:

| State | Meaning |
|---|---|
| `DropifyAsyncIdle<T>` | No request has started. |
| `DropifyAsyncLoading<T>` | The first request is loading. |
| `DropifyAsyncRefreshing<T>` | A replacement request is loading while stale items remain visible. |
| `DropifyAsyncData<T>` | Items loaded successfully. |
| `DropifyAsyncEmpty<T>` | The latest request completed with no items. |
| `DropifyAsyncError<T>` | The latest request failed and can be retried. |

The themed dropdown renders default loading, empty, error, and retry UI from
`DropifyThemeData`.

## Debounce And Cache

Search is debounced by 300 milliseconds by default. `DropifyAsyncDropdown` and
`RawAsyncDropify` expose `searchDebounce` for custom timing.

`cacheItems` defaults to true. The cache belongs to one widget instance and is
cleared when that instance is disposed. Set `cacheItems` to false to always ask
the fetcher for the latest query result.

`loadOnOpen` defaults to true. Set it to false when the first request should wait
until the caller changes the search text or opens through another controlled
flow.

## Body Modes And Selected Row Scroll

Async dropdowns default `menuBodyMode` to `DropifyMenuBodyMode.automatic`, which
uses lazy indexed rows for loaded and refreshing data. Set
`DropifyMenuBodyMode.eagerColumn` to eagerly build the currently rendered async
rows, or `DropifyMenuBodyMode.lazyIndexed` to force lazy indexed rendering.

When `scrollToSelectedOnOpen` is true, Dropify jumps to the selected value only
when it is present in the currently rendered loaded or refreshing rows. Cache
hits can jump immediately from cached rows. Cache misses wait for the latest
successful fetch. Loading, idle, empty, and error states remain direct state
widgets and do not create row scroll bodies.

Dropify never performs an extra fetch to locate a selected async value, and
paginated dropdowns do not expose `menuBodyMode` or `scrollToSelectedOnOpen`.

## Retry

When the latest request fails, retry repeats the same query. Cancelled and stale
requests do not update visible state.

## Raw Customization

Use `RawAsyncDropify` to customize item, loading, empty, or error builders.

```dart
RawAsyncDropify<User>(
  fetcher: searchUsers,
  anchorBuilder: userAnchorBuilder,
  itemBuilder: (context, user, selected, onTap) {
    return ListTile(
      selected: selected,
      title: Text(user.name),
      onTap: onTap,
    );
  },
  errorBuilder: (context, error, retry) {
    return TextButton(onPressed: retry, child: const Text('Try again'));
  },
)
```

## Common Mistakes

- Do not ignore the cancellation token for long-running work.
- Do not update external selection state from stale fetch results.
- Do not use async dropdowns for infinite lists. Use paginated dropdowns when
  the list can grow page by page.

## Related APIs

- `DropifyAsyncDropdown<T>` provides Material styling.
- `RawAsyncDropify<T>` provides raw async behavior.
- `DropifyMenuBodyMode` controls eager versus lazy loaded async rows.
- `DropifyCancelToken` coordinates cancellation.
- `DropifyThemeData` controls async state-slot builders.
