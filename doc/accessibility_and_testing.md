# Accessibility And Testing

Dropify exposes semantics and stable keys so widget tests do not depend on
localized visible text.

## Stable Keys

Keys use the format `dropify.<scope>.<role>[.<qualifier>]`.

| Role | Key |
|---|---|
| Anchor | `dropify.anchor` |
| Clear button | `dropify.anchor.clear` |
| Panel | `dropify.panel` |
| Search field | `dropify.search.field` |
| Search clear | `dropify.search.clear` |
| Item selected icon | `dropify.item.selectedIcon` |
| Validation error | `dropify.validation.error` |
| Multi footer | `dropify.multi.footer` |
| Multi apply | `dropify.multi.apply` |
| Multi cancel | `dropify.multi.cancel` |
| Async loading | `dropify.async.loading` |
| Async refreshing | `dropify.async.refreshing` |
| Async empty | `dropify.async.empty` |
| Async error | `dropify.async.error` |
| Async retry | `dropify.async.retry` |
| Paging first-page progress | `dropify.paging.firstPageProgress` |
| Paging new-page progress | `dropify.paging.newPageProgress` |
| Paging first-page error | `dropify.paging.firstPageError` |
| Paging new-page error | `dropify.paging.newPageError` |
| Paging no items | `dropify.paging.noItems` |
| Paging no more items | `dropify.paging.noMoreItems` |
| Paging retry | `dropify.paging.retry` |

Item keys may append a stable identity suffix when `keyOf` is available:
`dropify.item.<identity>`.

## Semantics

Anchors expose dropdown state, selected values, enabled state, and validation
errors. Items expose selectable, selected, disabled, and label state. Loading,
empty, error, retry, and paging footer states expose meaningful labels.

## Keyboard Expectations

- Arrow keys navigate panel items.
- Enter and Space activate the focused item.
- Escape closes the panel and discards staged confirmable multi changes.
- Tab follows Flutter focus traversal.
- Confirmable multi footer buttons are keyboard reachable.

## Testing Guidance

Prefer stable keys for Dropify-owned structure and semantics or labels for user
content.

```dart
await tester.tap(find.byKey(const ValueKey<String>('dropify.anchor')));
await tester.pumpAndSettle();

expect(find.byKey(const ValueKey<String>('dropify.panel')), findsOneWidget);
expect(find.text('Apple'), findsOneWidget);
```

Use `keyOf` when test code needs stable item keys for model values.

```dart
DropifyDropdown<User>(
  entries: userEntries,
  keyOf: (user) => user.id,
)
```

## Common Mistakes

- Do not locate package controls by localized labels when a stable key exists.
- Do not use keys as a substitute for semantic labels. Both are needed.
- Do not derive keys from translated visible copy.

## Related APIs

- `keyOf` controls stable item identity.
- `DropifyThemeData` controls visible state-slot copy through builders.
- `DropifyController` can drive journey tests programmatically.
