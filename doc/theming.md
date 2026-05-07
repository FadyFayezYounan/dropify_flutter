# Theming

Dropify themed widgets use Material 3-oriented defaults and package-specific
theme tokens.

## Local Theme

Use `DropifyTheme` to style a subtree.

```dart
DropifyTheme(
  data: DropifyThemeData.fromMaterial(Theme.of(context)).copyWith(
    panelMaxHeight: 360,
    entrySpacing: 12,
  ),
  child: DropifyDropdown<String>(entries: entries),
)
```

## App Theme Extension

Install `DropifyThemeData` on `ThemeData.extensions` for app-wide defaults.

```dart
ThemeData(
  extensions: [
    DropifyThemeData.fromMaterial(theme).copyWith(
      panelElevation: 6,
    ),
  ],
)
```

## Resolution Order

Dropify resolves theme values in this order:

1. Instance value.
2. Nearest `DropifyTheme`.
3. `Theme.of(context).extension<DropifyThemeData>()`.
4. `DropifyThemeData.fromMaterial(Theme.of(context))`.

## Token Groups

| Group | Examples |
|---|---|
| Anchor | Decoration, padding, value text, hint text, error text, trailing icon, clear icon. |
| Panel | Decoration, shape, side, color, elevation, clip behavior, max height. |
| Search | Input decoration, padding, text style, search icon, clear icon. |
| Entry | Text style, disabled text style, selected decoration, selected icon, spacing, divider. |
| Async state | Loading, empty, error, retry builders. |
| Paging footer | First-page progress, new-page progress, error, no-items, no-more-items builders. |
| Confirmable footer | Confirm and cancel button styles, footer padding. |

## Common Mistakes

- Do not use raw widgets just to style the default Material dropdown. Use theme
  tokens first.
- Do not localize stable keys. Customize visible text through builders and
  labels while keeping keys stable.
- Do not assume Material defaults are hardcoded. They are derived from the
  ambient `ThemeData`.

## Related APIs

- `DropifyTheme` applies a local package theme.
- `DropifyThemeData` stores token values and state-slot builders.
- `DropifyThemeData.fromMaterial` derives defaults from `ThemeData`.
