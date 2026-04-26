# Quickstart: Dropify Flutter Implementation Plan

## Prerequisites

- Flutter stable with Dart 3.10.3 or newer compatible with `pubspec.yaml`.
- Package dependencies resolved with `flutter pub get` at the repository root and in `example/` when needed.

## Implementation Order

1. Add failing tests for core primitives: matcher, debouncer, cancel token, entries, controller, selection identity, values, theme data, and paging state.
2. Implement core primitives and update `lib/dropify_flutter.dart` exports.
3. Add failing widget tests for `RawDropify`: open/close, outside tap, Escape, single selection, live multi, confirmable multi, clear, search, validation, form reset, keyboard, and semantics.
4. Implement `RawDropify` and internal anchor, panel, search, and focus helpers.
5. Add failing tests for `RawStaticDropify`, then implement static filtering, disabled rows, empty state, and builder threshold behavior.
6. Add failing async tests with `Completer` and `fake_async`, then implement `RawAsyncDropify` cancellation, debounce, cache, stale-result protection, retry, and state slots.
7. Add failing pagination tests with caller-owned `DropifyPagingState`, then implement `RawPaginatedDropify` as a pure `PagingState` consumer.
8. Add failing theme/widget/golden tests, then implement `DropifyDropdown`, `DropifyAsyncDropdown`, `DropifyPaginatedDropdown`, `DropifyTheme`, and `DropifyThemeData`.
9. Build example pages for static, async, paginated, multi-select, themed, validation, and raw usage.
10. Finish README, dartdoc, semantic key documentation, and pub.dev dry-run readiness.

## Verification Commands

Run from the repository root unless noted.

```sh
dart format --set-exit-if-changed .
dart analyze
flutter test
```

Example app checks:

```sh
cd example
flutter test
flutter build web
```

Release readiness:

```sh
flutter pub publish --dry-run
```

## Minimal Static Integration Target

```dart
import 'package:dropify_flutter/dropify_flutter.dart';

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

## Minimal Async Integration Target

```dart
DropifyAsyncDropdown<Country>(
  fetcher: (query, {required cancel}) {
    return api.searchCountries(query, cancel: cancel);
  },
  itemLabelBuilder: (country) => country.name,
  label: 'Country',
  onChanged: (country) {},
)
```

## Minimal Paginated Integration Target

```dart
DropifyPaginatedDropdown<int, Country>(
  state: state,
  fetchNextPage: fetchNextPage,
  onSearchChanged: resetForSearch,
  itemLabelBuilder: (country) => country.name,
  label: 'Country',
  onChanged: (country) {},
)
```

## Expected Done State

- All six variants are exported from `package:dropify_flutter/dropify_flutter.dart`.
- Static, async, and paginated variants support single and multi-select paths.
- Confirmable multi-select stages, applies, and cancels predictably.
- Validation is available through the core raw behavior and themed wrappers.
- Async and paginated late results cannot overwrite current query state.
- All built-in visible labels/messages are configurable.
- Keyboard and screen reader flows are covered by tests.
- Example app demonstrates the full v0.1.0 surface without analyzer, test, build, or layout issues.
