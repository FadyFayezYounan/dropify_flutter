# 004 — Async Data Source + DropifyAsyncDropdown (M3)

> Parent spec: [000-dropify_flutter.md](000-dropify_flutter.md)
>
> Depends on: [003-static_dropdown.md](003-static_dropdown.md) merged.
>
> Scope: future-backed dropdowns (single + multi) with loading / error / empty states. Cancel out-of-order responses.

## Goal

Wire `AsyncDropifyDataSource<T>` into `RawDropify`, then ship `DropifyAsyncDropdown<T>` and `DropifyAsyncDropdown.multi` that reuse the M2 default chrome and add per-state builders for loading, error, and empty.

Out-of-order fetches must be canceled — slow first response, fast second response: only the second one wins.

## Deliverables

### 1. Async wiring in `RawDropify` (extend, do not rewrite)

In `lib/src/core/raw_dropify.dart`, complete the sealed switch on `DropifyDataSource`:

- `AsyncDropifyDataSource<T>`:
  - Maintain a request token (monotonic int) inside the `State`. Each fetch increments it; only the response whose token matches the latest is applied.
  - Trigger fetch when:
    - `dataSource.fetchOnOpen == true` and the panel opens (and `controller.entries` is empty or stale).
    - `controller.query` changes, after the debounce window.
    - `controller.refresh()` is called.
    - `controller.retry()` is called (after an error).
  - Lifecycle: `status` transitions `idle → loading → (data | empty | error)` and back to `loading` on subsequent fetches. The controller exposes `status`, `error`, `entries` so the body builder can switch on `state.status`.
  - `controller.refresh()` and `controller.retry()` are no longer `UnimplementedError` — implement them. `loadMore()` still throws (paginated only, M4).

The async `dataSource.fetch(query)` may throw or return; both paths flow into the controller. Don't swallow stack traces — store the original `Object error` and re-throw is unnecessary.

### 2. `lib/src/widgets/dropify_async_dropdown.dart`

```dart
class DropifyAsyncDropdown<T> extends StatelessWidget {
  const DropifyAsyncDropdown({
    super.key,
    this.controller,
    required this.fetch,
    this.fetchOnOpen = true,
    this.initialValue,
    this.onChanged,
    this.label,
    this.hintText,
    this.searchEnabled = true,
    this.searchHint,
    this.itemBuilder,
    this.anchorBuilder,
    this.panelDecoration,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.theme,
    this.enabled = true,
    this.focusNode,
  });

  const DropifyAsyncDropdown.multi({
    super.key,
    /* + multi-shared props from M2 */
  });

  final Future<List<DropifyEntry<T>>> Function(String query) fetch;
  final bool fetchOnOpen;
  final Widget Function(BuildContext)? loadingBuilder;
  final Widget Function(BuildContext, Object error, VoidCallback retry)? errorBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
  // ... other shared params
}
```

Implementation:

- Builds an `AsyncDropifyDataSource(fetch: fetch, fetchOnOpen: fetchOnOpen)` and hands it to `RawDropify`.
- The body builder is `_DropifyPanel` from M2, but with state-aware swap-in:
  - `status == loading` → `loadingBuilder` > `theme.defaultLoadingBuilder` > built-in centered `CircularProgressIndicator`.
  - `status == error` → `errorBuilder(context, error, controller.retry)` > `theme.defaultErrorBuilder` > built-in retry button.
  - `status == empty` → existing M2 empty path (unchanged).
  - `status == data` → existing M2 list path.
  - `status == idle` → render a quiet placeholder (e.g. nothing, or a hint) — happens when `fetchOnOpen: false` and no query yet.

The search field stays at the top across all states (so users can type during loading). Built-in keyboard nav still works once data lands.

### 3. Theme defaults

`DropifyThemeData.defaultLoadingBuilder` / `defaultErrorBuilder` / `defaultEmptyBuilder` were declared in M0 as nullable. Provide built-in fallbacks here so the widget always has *something* to render:

- Loading: 32×32 progress indicator centered with vertical padding.
- Error: column with the stringified error and a "Retry" text button.
- Empty: a centered "No results" string styled by `itemTextStyle`.

These defaults live in the constructor logic of `_DropifyPanel`, not on `DropifyThemeData` (the theme remains the *override* surface). Keep theme fields as nullable overrides so the renderer can do `theme.defaultLoadingBuilder?.call(context) ?? builtInLoading(context)`.

### 4. Public exports

Add `DropifyAsyncDropdown` to the barrel.

### 5. Example page

`example/lib/pages/async_page.dart`. A fake API helper (in-page) that:

- Returns results after 600 ms.
- Errors deterministically when query is `"err"`.
- Returns `[]` when query is `"empty"`.
- Otherwise returns 20 fuzzy-matched entries.

Demonstrate:

- Single + multi side-by-side.
- Out-of-order race: the page logs request tokens to the console, and the test for out-of-order is also a unit test.
- A retry button via custom `errorBuilder`.
- A custom `loadingBuilder`.

Wire into the gallery.

## Tests

`test/widgets/dropify_async_dropdown_test.dart` (use `fakeAsync` + `Completer`):

- `fetchOnOpen: true` triggers fetch on first open.
- Query change debounces, then fetches.
- Loading state renders builder.
- Error state renders builder with the right `error` object and a working `retry` callback.
- Empty state renders when fetch returns `[]`.
- **Out-of-order cancellation**: completer A is created (token=1, slow), then query changes (token=2, fast). B completes first → state shows B's data. A completes after → ignored. Verify by asserting `state.entries` and that no transient flash to A's data occurs.
- `controller.refresh()` re-fetches with the current query.
- `controller.retry()` re-fetches and clears the error.
- Multi: chips, min/max, `closeOnSelect: false` defaults still hold.
- Disposing the widget mid-fetch does not throw (token-guard ignores the late completion).

`test/core/dropify_controller_test.dart` — extend with: `refresh()` / `retry()` no longer throw when controller is bound to an async `RawDropify`; `loadMore()` still throws.

## Verification

1. `flutter analyze` + `dart format` clean.
2. `flutter test` green.
3. `cd example && flutter run` — `async_page.dart`:
   - Type a query → spinner → results.
   - Type fast successive queries → only the latest result wins (no flash from earlier responses).
   - Trigger error path → custom error widget with retry → tap retry → loads.
   - Type "empty" → empty builder.
   - `fetchOnOpen: false` variant: opens to idle state, only fetches after typing.
4. Screenshot async loading + async error + async empty states.

## Out of scope

- Pagination. → M5/M4 (M4 in milestones, but next sub-plan #005).
- `FormField`. → M6/M5 (M5 in milestones).
- Cupertino sibling.

## Done when

- All four async states (idle/loading/data/empty/error) render correctly with both default and custom builders.
- Out-of-order cancellation is provably correct under tests.
- `controller.refresh()` and `controller.retry()` are first-class.
- M0–M2 functionality unaffected.
