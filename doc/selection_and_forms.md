# Selection And Forms

Dropify uses the same selection and validation model across static, async, and
paginated variants.

## Single Selection

Single-selection constructors emit `T?`.

```dart
DropifyDropdown<String>(
  entries: entries,
  onChanged: (value) {},
)
```

Selecting an enabled item commits the value and closes the panel.

## Live Multi-Select

Multi constructors emit the complete selected `Set<T>` whenever an item is
toggled.

```dart
DropifyDropdown<String>.multi(
  entries: entries,
  onChanged: (values) {},
)
```

The panel remains open after each toggle.

## Confirmable Multi-Select

Set `confirmable` when the user should stage changes before committing them.

```dart
DropifyDropdown<String>.multi(
  entries: entries,
  confirmable: true,
  confirmLabel: 'Apply',
  cancelLabel: 'Cancel',
  onChanged: (values) {},
)
```

Opening the panel initializes staged values from committed values. Apply commits
the staged set. Cancel, Escape, outside tap, and programmatic close discard the
staged set.

## Identity

Use `keyOf` for stable model identity.

```dart
DropifyDropdown<User>(
  entries: userEntries,
  itemLabelBuilder: (user) => user.name,
  keyOf: (user) => user.id,
)
```

Use `equals` only when identity cannot be represented as a stable key.

## Validation

Validators receive `DropifyValue<T>`.

```dart
validator: (value) {
  return switch (value) {
    DropifySingleValue<String>(value: final selected) =>
      selected == null ? 'Choose an item' : null,
    DropifyMultiValue<String>(values: final selected) =>
      selected.isEmpty ? 'Choose at least one item' : null,
  };
}
```

`Form.validate()` updates the anchor error presentation. `Form.reset()` restores
the initial selection and resets validation state.

## Common Mistakes

- Do not add a separate form wrapper around Dropify. Use the built-in
  `validator` argument.
- Do not mutate the selected `Set<T>` emitted by multi-select. Treat it as a
  value and replace your own state.
- Do not compare model objects by label. Use `keyOf` for stable selection.

## Related APIs

- `DropifySelectionMode` describes single or multi behavior.
- `DropifySingleValue<T>` and `DropifyMultiValue<T>` are passed to validators.
- `DropifyController<T>` can clear or replace selection programmatically.
