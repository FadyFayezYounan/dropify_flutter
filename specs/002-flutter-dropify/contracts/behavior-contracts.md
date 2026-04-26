# Behavior Contracts

## Open And Close

- Tapping an enabled anchor opens the panel.
- Tapping outside closes the panel.
- Escape closes the panel.
- Disabled anchors do not open and do not show clear affordances.
- `onOpen` and `onClose` fire once per state transition.

## Single Selection

- Selecting an enabled item commits `T?`.
- Selection uses resolved identity rules.
- The panel closes after successful selection.
- Clearing emits no value and updates validation.

## Live Multi Selection

- Toggling an enabled item immediately emits the complete selected set.
- The panel remains open after toggles.
- Clearing emits an empty set and updates validation.

## Confirmable Multi Selection

- Opening the panel initializes staged values from committed values.
- Toggling changes only the staged set.
- Apply commits staged values and emits the complete selected set.
- Cancel, Escape, outside tap, or programmatic close discards staged values.

## Search

- Search field is sticky at the top of the panel when enabled.
- Static search filters immediately.
- Async and paginated search use the configured debounce.
- Printable characters route into visible search.
- Clearing search restores the static full list, refetches async query `''`, or calls paginated `onSearchChanged('')`.

## Validation

- Validators receive `DropifySingleValue<T>` or `DropifyMultiValue<T>`.
- Anchor state exposes current error text.
- Themed anchors render error text by default.
- `Form.validate()` updates anchor error presentation.
- `Form.reset()` restores initial selection and resets validation state.

## Async Search

- Opening with `loadOnOpen` and cache miss starts a fetch.
- Starting a replacement fetch cancels the previous token.
- If stale data exists, replacement fetch shows refreshing state with stale items.
- Successful latest fetch renders data or empty state.
- Failed latest fetch renders error state with retry.
- Retry repeats the same query.
- Cancelled or stale fetch completion does not update visible state.
- Dispose cancels active token and prevents state updates after disposal.

## Paginated Results

- `state.pages == null && state.isLoading` renders first-page progress.
- Existing pages with `state.isLoading` render new-page progress.
- First-page error renders first-page retry.
- New-page error renders footer retry while keeping existing items.
- Empty loaded pages render no-items state.
- `hasNextPage == false` renders no-more-items state.
- Scrolling within `invisibleItemsThreshold` requests `fetchNextPage`.
- Search changes call `onSearchChanged` so the caller can cancel, reset, and fetch.
- Dropify never mixes pages from old and new search queries.

## Keyboard

- Arrow keys navigate panel items.
- Enter and Space activate the focused item.
- Escape closes the panel and cancels staged confirmable multi changes.
- Tab follows Flutter focus traversal and does not open the panel from the anchor.
- Footer buttons are keyboard reachable in confirmable multi mode.

## Accessibility

- Anchor semantics identify dropdown role, label, selected value, enabled state, error state, and open hint.
- Item semantics identify selectable role, label, selected state, and disabled state.
- Loading, empty, error, retry, and async status changes use meaningful semantics.
- Live regions are used for state changes where appropriate.
- Built-in visible labels and messages are configurable for localization.
