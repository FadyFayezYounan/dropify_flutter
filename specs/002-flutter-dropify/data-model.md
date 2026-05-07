# Data Model: Dropify Flutter Universal Dropdown Package

## Dropify Entry

Represents one selectable option.

**Fields**:

- `value: T`: consumer value emitted by selection.
- `label: String?`: default visible label when supplied.
- `leading: Widget?`: optional leading visual.
- `trailing: Widget?`: optional trailing visual.
- `enabled: bool`: whether the entry can be focused, selected, or toggled.
- `searchableText: String?`: search text override.

**Validation rules**:

- Disabled entries remain visible but cannot be selected, toggled, or keyboard-activated.
- Default static search text resolves as `searchableText`, then `label`, then `value.toString()`.
- Duplicate identity keys represent the same logical option.

## Dropify Value

Represents the form validation value.

**Shapes**:

- `DropifySingleValue<T>(T? value)`
- `DropifyMultiValue<T>(Set<T> values)`

**Validation rules**:

- Single mode emits one selected value or no value.
- Multi mode emits a complete selected set.
- Form reset restores `initialValue` or `initialValues`.

## Selection Mode

Commits user interaction into selected values.

**Values**:

- `single`: selecting an enabled item commits immediately and closes the panel.
- `multi`: toggling an enabled item commits immediately and keeps the panel open.

**Related state**:

- `confirmable: bool`: when true in multi mode, toggles update a staged set until Apply commits or Cancel/Escape/close discards.

## Selection Identity

Defines matching, toggling, clearing, validation, and displayed selected state.

**Fields**:

- `keyOf: Object Function(T item)?`
- `equals: bool Function(T a, T b)?`

**Validation rules**:

- `keyOf` takes precedence when present.
- `equals` is used when `keyOf` is absent and custom comparison is supplied.
- Dart equality is the fallback.

## Dropify Controller

User-facing handle for dropdown state.

**Fields**:

- `mode: DropifySelectionMode`
- `value: T?`
- `values: Set<T>`
- `isOpen: bool`

**State transitions**:

- `open`: opens the anchored panel and triggers `onOpen`.
- `close`: closes the panel and triggers `onClose`; confirmable staged changes are discarded.
- `setValue`: replaces the single value.
- `setValues`: replaces the multi value set.
- `toggle`: toggles a multi value using resolved identity.
- `clear`: clears the active selection and updates validation.

## Search Query

Current text used by static filtering, async fetching, or paginated reset notification.

**Fields**:

- `query: String`
- `controller: TextEditingController?`
- `debounce: Duration`
- `hintText: String?`

**Validation rules**:

- Static search filters locally without debounce unless a consumer wraps it.
- Async and paginated search default to 300 ms debounce.
- Printable keyboard input routes into the search field when visible.
- The search field stays fixed at the top of the open panel.

## Async Result State

Visible state for `RawAsyncDropify` and `DropifyAsyncDropdown`.

**States**:

- `idle`
- `loading`
- `refreshing(staleItems)`
- `data(items)`
- `empty(hasQuery)`
- `error(error, stackTrace)`

**State transitions**:

- Open with `loadOnOpen` and cache miss: `idle -> loading`.
- Successful fetch with items: `loading|refreshing -> data`.
- Successful fetch without items: `loading|refreshing -> empty`.
- Failed fetch: `loading|refreshing -> error`.
- New query with existing data: `data -> refreshing(staleItems)`.
- Retry: repeats the same query.

**Validation rules**:

- Each fetch receives a fresh `DropifyCancelToken`.
- Replacement fetch cancels the previous token.
- Late stale results are ignored.
- Instance cache is cleared on dispose or reset.

## Paging State

Caller-owned state for paginated dropdowns.

**Fields**:

- `pages: List<List<T>>?`
- `keys: List<PageKey>?`
- `error: Object?`
- `hasNextPage: bool`
- `isLoading: bool`
- `search: String?`
- `cancelToken: DropifyCancelToken?`

**Relationships**:

- `DropifyPagingState<PageKey, T>` extends `PagingStateBase<PageKey, T>`.
- `RawPaginatedDropify` accepts `PagingState<PageKey, T>` and does not mutate it.

**Validation rules**:

- Caller cancels obsolete page requests on search changes, refresh, and disposal.
- Caller checks `cancelToken.isCancelled` before appending fetched data.
- `reset()` clears page fields, preserves search, and prepares a fresh token.
- Retry calls the caller-provided `fetchNextPage`.

## Theme Data

Package styling tokens.

**Fields**:

- Anchor decoration, icons, padding, and text styles.
- Panel decoration, constraints, elevation, padding, and animation.
- Search field decoration, icons, padding, and text style.
- Entry text styles, selected/hover/focus decorations, spacing, and selected icon.
- State slot builders for loading, error, empty, no results, pagination progress, pagination errors, and no more items.
- Multi-select footer button styles and padding.

**Validation rules**:

- Resolution order is instance value, `DropifyTheme`, host `ThemeData.extensions`, then `DropifyThemeData.fromMaterial(context)`.
- Themed defaults adapt to Material 3 host tokens.

## Visible Copy

Consumer-configurable labels and messages.

**Fields**:

- Search hint.
- Clear, Apply, Cancel, Retry labels.
- Loading, refreshing, empty, no results, first-page error, new-page error, no-more-items messages.
- Accessibility labels and hints where the visible widget does not already provide sufficient text.

**Validation rules**:

- Every built-in visible string has a sensible English default.
- Consumers can override all built-in visible strings.

## Validation State

Form-related validity and error display.

**Fields**:

- `validator: FormFieldValidator<DropifyValue<T>>?`
- `autovalidateMode: AutovalidateMode?`
- `errorText: String?`
- `errorTextBuilder: Widget Function(BuildContext, String error)?`

**State transitions**:

- Value change updates `FormField` state.
- Submit calls validator and exposes error text to the anchor.
- Reset restores initial selection and clears/reset validation according to Flutter form behavior.
