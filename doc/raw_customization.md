# Raw Customization

Use raw widgets when the default Material anchor or rows are not enough.

## Raw Core

`RawDropify<T>` owns overlay, selection, search, validation, and controller
coordination. You provide two builders:

- `anchorBuilder` builds the closed control.
- `panelBuilder` builds the open panel contents.

```dart
RawDropify<String>(
  anchorBuilder: (context, state) {
    return OutlinedButton(
      onPressed: state.enabled ? state.open : null,
      child: Text(state.value ?? 'Choose one'),
    );
  },
  panelBuilder: (context, state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final value in values)
          ListTile(
            selected: state.isSelected(value),
            title: Text(value),
            onTap: () => state.select(value),
          ),
      ],
    );
  },
)
```

## Builder State

`DropifyAnchorState<T>` exposes the committed selection, open state, enabled
state, current validation error, and actions for opening, closing, and clearing.

`DropifyPanelState<T>` exposes the committed selection, current search query,
selection helpers, and panel focus node. Panel builders should use
`state.select`, `state.toggle`, and `state.close` instead of opening or closing
their own overlay.

## Raw Variants

Use the specialized raw variants when you want Dropify to provide data behavior
but not Material anchor styling.

| Widget | Adds |
|---|---|
| `RawStaticDropify<T>` | Entry filtering, disabled entries, large-list presentation. |
| `RawAsyncDropify<T>` | Debounced fetching, cancellation, stale-result protection, retry. |
| `RawPaginatedDropify<PageKey, T>` | Paging-state rendering, next-page requests, paging footers. |

## Validation

Raw widgets use the same `validator` contract as themed widgets. The anchor
builder receives current error text through `DropifyAnchorState.errorText`.

## Common Mistakes

- Do not duplicate overlay state in a raw panel. Use the state object supplied
  by Dropify.
- Do not ignore `state.enabled` in custom anchors.
- Do not use raw widgets just to change colors. Prefer `DropifyThemeData` for
  visual styling.

## Related APIs

- `RawDropify<T>` is the unstyled core.
- `AnchorBuilder<T>` builds the closed control.
- `PanelBuilder<T>` builds the open panel body.
- `DropifyController<T>` provides programmatic open, close, clear, and selection.
