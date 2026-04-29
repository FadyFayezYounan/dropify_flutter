# Static Dropdowns

Use static dropdowns when every option is already available in memory.

## Material Dropdown

```dart
DropifyDropdown<String>(
  entries: const [
    DropifyEntry(value: 'apple', label: 'Apple'),
    DropifyEntry(value: 'banana', label: 'Banana'),
  ],
  label: 'Fruit',
  searchable: true,
  onChanged: (value) {},
)
```

## Entries

`DropifyEntry<T>` describes one selectable option.

```dart
const DropifyEntry(
  value: 'orange',
  label: 'Orange',
  searchableText: 'orange citrus',
  enabled: true,
)
```

The default static matcher checks `searchableText`, then `label`, then
`value.toString()`. Matching is case-insensitive.

## Disabled Entries

Disabled entries remain in the list but cannot be selected.

```dart
const DropifyEntry(
  value: 'archived',
  label: 'Archived item',
  enabled: false,
)
```

## Custom Matching

Use `RawStaticDropify` when the matching or row UI must be custom.

```dart
RawStaticDropify<Product>(
  entries: products,
  searchable: true,
  matcher: (entry, query) {
    return entry.value.sku.contains(query) ||
        entry.effectiveSearchText.toLowerCase().contains(query.toLowerCase());
  },
  anchorBuilder: (context, state) {
    return TextButton(
      onPressed: state.enabled ? state.open : null,
      child: Text(state.value?.name ?? 'Choose product'),
    );
  },
)
```

## Large Lists

When a filtered static list has more than 50 entries, Dropify uses a builder
presentation for visible rows instead of building every row eagerly.

## Common Mistakes

- Do not use static dropdowns for remote data. Use `DropifyAsyncDropdown` or
  `DropifyPaginatedDropdown` instead.
- Do not derive test keys from localized labels. Prefer `keyOf` for stable item
  identity and semantics for visible text.
- Do not rely on object equality for model objects if new instances represent
  the same logical item. Provide `keyOf: (item) => item.id`.

## Related APIs

- `DropifyEntry<T>` describes static options.
- `DropifyDropdown<T>` provides Material styling.
- `RawStaticDropify<T>` provides raw static behavior with custom builders.
