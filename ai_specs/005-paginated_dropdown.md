# 005 — Paginated Data Source + DropifyPaginatedDropdown (M4)

> Parent spec: [000-dropify_flutter.md](000-dropify_flutter.md)
>
> Depends on: [004-async_dropdown.md](004-async_dropdown.md) merged.
>
> Scope: page-keyed infinite-scroll dropdowns (single + multi), backed by `infinite_scroll_pagination` v5+.

## Goal

Wire `PaginatedDropifyDataSource<T>` into `RawDropify`, then ship `DropifyPaginatedDropdown<T>` and `.multi`. Query changes reset the paging state to `firstPageKey`. Pages dedupe by `DropifyEntry.value` (`==`), matching the package's identity rule.

This is the only widget in the package that touches `infinite_scroll_pagination`. Isolating it to one file keeps the rest of the package decoupled from that dep, so a future split into a `dropify_pagination` companion package is mechanical.

## Deliverables

### 1. Verify `infinite_scroll_pagination` v5+ API

Before writing code, check current API for `PagingController` and the recommended `PagedSliver*` / `PagedList*` widgets at the pinned major. Use context7 (`mcp__plugin_context7_context7__resolve-library-id` then `query-docs`) for up-to-date docs. Note any breaking changes from older docs and pin notes in this sub-plan if anything diverges.

### 2. `lib/src/internal/paging.dart`

Adapter that bridges `DropifyController<T>` ↔ `PagingController<int, DropifyEntry<T>>`:

- Owns the `PagingController`; disposes it with the widget.
- On `controller.query` change (after debounce): refresh — call `pagingController.refresh()` so it re-requests `firstPageKey` with the new query.
- On `pagingController` page request: invoke `dataSource.fetchPage(pageKey, controller.query)`. On success, append the page; if `page.length < pageSize`, signal `appendLastPage`, else `appendPage(items, nextKey: pageKey + 1)`. On error, set `error` on the controller (for the panel's error UI).
- Dedupe across pages by `entry.value` — track a `Set<T>` of seen values and skip duplicates before appending. (A buggy backend sending the same row in two pages must not break the list.)
- Mirror paging state into `DropifyController`: expose `status` (loading/data/error/empty), `entries` (the running concatenated list), `hasMore`, and `error`. The body's panel reads from the controller, not from `PagingController`, so the panel widget's API stays uniform with M2/M3.
- `controller.loadMore()`: fire `pagingController.notifyPageRequestListeners(nextKey)` (or v5 equivalent). Mostly the user doesn't call this — `infinite_scroll_pagination`'s scroll trigger does — but the API is there.
- `controller.refresh()`: `pagingController.refresh()`.
- `controller.retry()`: same — refresh on fatal error, or retry-page on per-page error.

### 3. Async wiring in `RawDropify` (extend)

Complete the sealed switch's `PaginatedDropifyDataSource<T>` case in `raw_dropify.dart` by delegating to the `paging.dart` adapter. No other changes to Layer 1.

### 4. `lib/src/widgets/dropify_paginated_dropdown.dart`

```dart
class DropifyPaginatedDropdown<T> extends StatelessWidget {
  const DropifyPaginatedDropdown({
    super.key,
    this.controller,
    required this.fetchPage,
    this.firstPageKey = 1,
    this.pageSize = 20,
    this.initialValue,
    this.onChanged,
    this.label,
    this.hintText,
    this.searchEnabled = true,
    this.searchHint,
    this.itemBuilder,
    this.anchorBuilder,
    this.panelDecoration,
    this.loadingBuilder,        // first-page loading
    this.errorBuilder,          // first-page error
    this.emptyBuilder,          // empty list across all pages
    this.newPageProgressBuilder, // small footer spinner during page load
    this.newPageErrorBuilder,    // footer with retry CTA on per-page error
    this.noMoreItemsBuilder,     // optional footer when hasMore == false
    this.theme,
    this.enabled = true,
    this.focusNode,
  });

  const DropifyPaginatedDropdown.multi({ /* + multi shared props */ });

  final Future<List<DropifyEntry<T>>> Function(int pageKey, String query) fetchPage;
  final int firstPageKey;
  final int pageSize;
}
```

Implementation:

- Wraps `RawDropify` with `PaginatedDropifyDataSource(fetchPage: ..., firstPageKey: ..., pageSize: ...)`.
- The body uses a paginated list widget from `infinite_scroll_pagination` v5+ (likely `PagedListView` or its slivers). Compose this *inside* the M2 `_DropifyPanel` shell so the search field sits on top and the panel decoration matches the rest of the package.
- Footer state widgets (`newPageProgressBuilder`, `newPageErrorBuilder`, `noMoreItemsBuilder`) thread through `infinite_scroll_pagination`'s status builders.
- First-page states (`loadingBuilder`, `errorBuilder`, `emptyBuilder`) reuse the same fallback chain as M3: explicit prop > theme builder > built-in.

### 5. Public exports

Add `DropifyPaginatedDropdown` to the barrel.

### 6. Example page

`example/lib/pages/paginated_page.dart`:

- Fake API: returns 20 results per page, total 200 rows. Synthesizes labels like `"Item N"`.
- Errors deterministically on page 3 once (then succeeds on retry) to demo `newPageErrorBuilder`.
- Returns empty for query `"empty"`.
- Two dropdowns: single + multi.
- Custom `noMoreItemsBuilder` showing total count.

Wire into gallery.

## Tests

`test/widgets/dropify_paginated_dropdown_test.dart` (use `fakeAsync`):

- First page loads on open; subsequent pages load on scroll-to-end.
- Dedupe across pages: backend returns same value twice across two pages → list contains it once.
- Query change resets paging to `firstPageKey` and clears prior entries.
- Per-page error: footer renders `newPageErrorBuilder`; tapping retry re-fetches just that page.
- First-page error: full-panel `errorBuilder`; tapping retry goes back to first-page loading.
- `hasMore` flips to false when a page returns `< pageSize` rows; `noMoreItemsBuilder` shows.
- `controller.refresh()` resets paging.
- `controller.loadMore()` advances to the next page when called explicitly.
- Selection works during pagination: selecting an item on page 2 keeps prior pages intact, multi state still consistent.
- Disposing mid-fetch does not throw.

`test/internal/paging_test.dart`:

- The adapter handles `pagingController` lifecycle correctly: refresh, append, error, dispose.
- Dedupe set is correctly seeded and cleared on refresh.

## Verification

1. `flutter analyze` + `dart format` clean.
2. `flutter test` green.
3. `cd example && flutter run` — `paginated_page.dart`:
   - Open → first page loads → scroll → next pages append.
   - Type a query → paging resets, query-aware fetches load.
   - Trigger page-3 error → footer shows error + retry → tap retry → loads.
   - Multi-toggle across pages: chips reflect cross-page selections.
   - "No more items" appears at the end of the list.
4. Screenshot loading footer + per-page error + end-of-list.

## Out of scope

- `FormField`. → M5 (next sub-plan #006).
- Splitting paginated mode into a companion package — flagged in parent spec as a future option, not for v1.
- Polish & a11y. → M6 (#007).

## Done when

- A user can write `DropifyPaginatedDropdown(fetchPage: ...)` and get a fully working infinite-scroll dropdown with default chrome.
- `.multi` is fully functional.
- All paginated tests pass; M0–M3 tests still pass.
- The `infinite_scroll_pagination` import lives only in `dropify_paginated_dropdown.dart` and `paging.dart`.
