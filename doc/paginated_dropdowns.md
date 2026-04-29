# Paginated Dropdowns

Use paginated dropdowns when options are loaded page by page and the caller owns
the paging state.

## Minimal Example

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

## Caller-Owned State

Dropify consumes `PagingState<PageKey, T>` and calls `fetchNextPage` when more
data is needed. It does not mutate pages, keys, loading flags, or errors.

```dart
Future<void> fetchNextPage() async {
  if (state.isLoading || !state.hasNextPage) {
    return;
  }

  setState(() {
    state = state.copyWith(isLoading: true, error: null);
  });

  try {
    final page = await api.fetchCountries(
      pageKey: nextPageKey,
      query: search,
    );
    setState(() {
      state = state.copyWith(
        pages: [...?state.pages, page.items],
        keys: [...?state.keys, nextPageKey],
        hasNextPage: page.hasNextPage,
        isLoading: false,
      );
    });
  } catch (error) {
    setState(() {
      state = state.copyWith(error: error, isLoading: false);
    });
  }
}
```

## Search Reset

`onSearchChanged` is called after debounce. Reset paging state there and cancel
old work if your data source supports cancellation.

```dart
void resetForSearch(String query) {
  cancelToken.cancel();
  cancelToken = DropifyCancelToken();
  search = query;
  state = const PagingState<int, Country>();
  fetchNextPage();
}
```

`DropifyPagingState<PageKey, T>` is available as a convenience state object when
you want search text and cancellation metadata near the paging state.

## Rendered States

| Paging state | Rendered UI |
|---|---|
| `pages == null && isLoading` | First-page progress. |
| Existing pages and `isLoading` | New-page progress footer. |
| First-page error | First-page retry. |
| New-page error | Retry footer while keeping existing items. |
| Empty loaded pages | No-items state. |
| `hasNextPage == false` | No-more-items footer. |

## Common Mistakes

- Do not expect Dropify to append pages for you. It only calls
  `fetchNextPage`.
- Do not mix pages from old and new search queries. Reset state when search
  changes.
- Do not use visible labels as stable item identity. Provide `keyOf` for model
  objects.

## Related APIs

- `DropifyPaginatedDropdown<PageKey, T>` provides Material styling.
- `RawPaginatedDropify<PageKey, T>` provides raw paginated behavior.
- `PagingState<PageKey, T>` is re-exported from `infinite_scroll_pagination`.
- `DropifyPagingState<PageKey, T>` stores paging, search, and cancellation data.
