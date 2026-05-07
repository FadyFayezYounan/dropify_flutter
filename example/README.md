# Dropify Flutter Example

This app demonstrates the public `dropify_flutter` package surface across
static, async, paginated, selection, form, theme, and accessibility scenarios.

## Run The Example

From the package root:

```sh
cd example
flutter pub get
flutter run
```

## Pages

| Page | Source | Demonstrates |
|---|---|---|
| Static dropdowns | `lib/pages/static_dropdown_page.dart` | Raw and themed static dropdowns, search, disabled entries, clear action, validation, and large lists. |
| Async dropdowns | `lib/pages/async_dropdown_page.dart` | Debounced remote search, loading, empty, error, retry, refresh, and cache behavior. |
| Paginated dropdowns | `lib/pages/paginated_dropdown_page.dart` | Caller-owned `PagingState`, first-page loading, next-page loading, search reset, retry, empty, and no-more-items states. |
| Selection and forms | `lib/pages/selection_forms_page.dart` | Single selection, live multi-select, confirmable multi-select, validation, and form reset. |
| Accessibility and theme | `lib/pages/accessibility_theme_page.dart` | Theme overrides, visible state copy, semantics, keyboard behavior, and stable test keys. |

## Fake API

`lib/fake_api.dart` provides deterministic data sources for the async and
paginated examples. It includes success, empty, delayed, stale-response, error,
and paginated scenarios so the example app can demonstrate state transitions
without a network dependency.

## Verification

Run these commands before changing example behavior:

```sh
flutter test
flutter build web
```

From the package root, also run:

```sh
dart format --set-exit-if-changed .
dart analyze
flutter test
```

## Related Documentation

- [Package README](../README.md)
- [Static dropdowns](../doc/static_dropdowns.md)
- [Async dropdowns](../doc/async_dropdowns.md)
- [Paginated dropdowns](../doc/paginated_dropdowns.md)
- [Raw customization](../doc/raw_customization.md)
- [Selection and forms](../doc/selection_and_forms.md)
- [Theming](../doc/theming.md)
- [Accessibility and testing](../doc/accessibility_and_testing.md)
