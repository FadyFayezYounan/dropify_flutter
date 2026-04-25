# 001 — Core Skeleton (M0)

> Parent spec: [000-dropify_flutter.md](000-dropify_flutter.md)
>
> Scope of this sub-plan: data + theme primitives only. **No widgets that render.** This is the foundation every later milestone builds on; touch this carefully because changing it later forces ripple edits.

## Goal

Land the non-rendering core of `dropify_flutter`:

- `pubspec.yaml` deps wired up.
- File scaffold for `lib/src/{core,theme,widgets,internal}/`.
- `DropifyEntry<T>`, `DropifyStatus`, `DropifyState<T>`, `DropifyController<T>` (single + multi factories).
- Sealed `DropifyDataSource<T>` with `Static`, `Async`, `Paginated` variants.
- `DropifyTheme` inherited widget + `DropifyThemeData` with `light()`, `dark()`, `fromMaterial(context)` factories.
- Public barrel `lib/dropify_flutter.dart` exporting only the API surface listed in the parent spec.

No `RawDropify`, no concrete dropdown widgets, no form field, no example pages yet.

## Deliverables

### 1. `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter
  infinite_scroll_pagination: ^5.1.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
```

Even though `infinite_scroll_pagination` is unused in M0, declare it so the dep graph stabilizes early.

### 2. File scaffold

Create empty (or single-class) files to lock in the layout, so later milestones don't re-litigate paths:

```
lib/
├── dropify_flutter.dart
└── src/
    ├── core/
    │   ├── dropify_entry.dart
    │   ├── dropify_state.dart
    │   ├── dropify_controller.dart
    │   ├── dropify_data_source.dart
    │   └── raw_dropify.dart                # placeholder, M1 fills it
    ├── theme/
    │   ├── dropify_theme.dart
    │   └── dropify_theme_data.dart
    ├── widgets/                            # left empty in M0
    └── internal/
        ├── debouncer.dart                  # placeholder, M1 fills
        └── default_matcher.dart            # placeholder, M2 fills
```

### 3. `DropifyEntry<T>`

Mirror `DropdownMenuEntry<T>`:

```dart
@immutable
class DropifyEntry<T> {
  const DropifyEntry({
    required this.value,
    required this.label,
    this.labelWidget,
    this.leadingIcon,
    this.trailingIcon,
    this.enabled = true,
    this.style,
  });

  final T value;
  final String label;
  final Widget? labelWidget;
  final Widget? leadingIcon;
  final Widget? trailingIcon;
  final bool enabled;
  final ButtonStyle? style;

  // == / hashCode based on value (matches Material's contract).
}
```

### 4. `DropifyStatus` + `DropifyState<T>`

```dart
enum DropifyStatus { idle, loading, data, empty, error }
```

For M0, `DropifyState<T>` is a plain immutable value object. The `RawMenuOverlayInfo overlayInfo` field is part of the contract; until M1 wires it up, ship a `@visibleForTesting` constructor that takes a stub. The widget-facing constructor stays internal.

Helpers `isSelected(T)` / `toggle(T)` delegate to the controller; implement now so M1 can drop them in unchanged.

### 5. `DropifyController<T>`

Implement the abstract class plus `_SingleDropifyController<T>` and `_MultiDropifyController<T>`. Key contracts:

- `factory DropifyController.single({T? initialValue})`
- `factory DropifyController.multi({List<T> initialValues = const []})`
- `extends ChangeNotifier` (so `Listenable` is satisfied) — or an internal `ValueNotifier` if simpler.
- Throw `StateError` when single-only getters/setters are used on a multi controller and vice versa (see parent spec contract).
- `open()` / `close()` flip `isOpen` and notify; in M0 they don't actually attach to an overlay (no `RawDropify` yet) — they're pure state.
- `setQuery(String)` updates `query` and notifies. Debouncing belongs in M1's `RawDropify`, not here.
- `refresh()` / `loadMore()` / `retry()` throw `UnimplementedError` in M0 with a clear message ("wired in M3/M4"). They land in async/paginated milestones.
- Single-bind guard: replicate `MenuController._attach` / `_detach` pattern (refrences/flutter_raw_menu_anchor.dart:1076) so a controller can only be attached to one widget at a time. Even though no widget consumes the controller in M0, ship the `_attach` / `_detach` plumbing now — it's read-only state and validates the design.
- Provide `static DropifyController<T>? maybeOf<T>(BuildContext)` returning `null` for now; M1 will wire the inherited model.

Multi-select rejection: `lastRejectionReason` (enum: `minSelectionViolated`, `maxSelectionViolated`, `entryDisabled`) lives on the multi controller. Toggles that violate `minSelection`/`maxSelection` are no-ops that set the reason and notify.

### 6. `DropifyDataSource<T>` (sealed)

Exactly as in the parent spec — `StaticDropifyDataSource`, `AsyncDropifyDataSource`, `PaginatedDropifyDataSource`. Pure data classes, no behavior. Use Dart's `sealed` keyword so M1 can `switch` exhaustively.

### 7. Theme

`DropifyThemeData`:

- Match the field list in the parent spec exactly. Any field that has no sensible default in M0 (e.g. per-state builder defaults) is nullable.
- `copyWith({...})`, `lerp(other, t)`, `==` / `hashCode` (be honest — use `Object.hash` / `listEquals` style equality).
- `factory DropifyThemeData.light()` and `.dark()` ship pure-widget defaults (no Material types). Use `widgets.dart`-only types: `Color`, `BoxDecoration`, `TextStyle` from `painting`, etc. — no `ThemeData`, no `ColorScheme`, no `Material` widgets.
- `factory DropifyThemeData.fromMaterial(BuildContext)` reads `Theme.of(context)` and bridges into the pure-widget shape. This is the **only** Material-aware code in the package.

`DropifyTheme`:

- Standard `InheritedWidget` with `data` payload.
- `static DropifyThemeData of(BuildContext)` — returns `DropifyThemeData.light()` as fallback if no ancestor; do **not** require Material context.
- `static DropifyThemeData? maybeOf(BuildContext)`.
- `updateShouldNotify` compares `data` by `==`.

### 8. Public barrel

`lib/dropify_flutter.dart` exports only:

- `DropifyEntry`
- `DropifyStatus`, `DropifyState`
- `DropifyController` (the factory class, not the private impls)
- `DropifyDataSource`, `StaticDropifyDataSource`, `AsyncDropifyDataSource`, `PaginatedDropifyDataSource`
- `DropifyTheme`, `DropifyThemeData`

Nothing from `src/` should leak transitively. Keep imports inside `src/` as relative paths; the barrel uses `export 'src/...'`.

## Tests (M0)

`test/core/`:

- `dropify_entry_test.dart` — equality by value, `enabled` default, `copyWith`-free contract (it's not in the API).
- `dropify_controller_test.dart`:
  - single: `initialValue` honored; `singleValue=` notifies; `multiValues` getter throws.
  - multi: `initialValues` honored; toggle adds/removes; `singleValue` getter throws; `minSelection`/`maxSelection` reject and set `lastRejectionReason`; disabled-entry toggle rejected.
  - both: `setQuery` notifies; `open`/`close` flip `isOpen`; `refresh`/`loadMore`/`retry` throw `UnimplementedError`; `_attach`/`_detach` enforces single-bind.
- `dropify_state_test.dart` — `isSelected` and `toggle` delegation; status enum exhaustiveness.
- `dropify_data_source_test.dart` — sealed exhaustiveness via a `switch` in a test (compile-time check).

`test/theme/`:

- `dropify_theme_test.dart` — `of` fallback when no ancestor; `maybeOf` returns null; `lerp` endpoint identity (`lerp(a, b, 0) == a`, `lerp(a, b, 1) == b`); `light()` / `dark()` distinct; `fromMaterial` reads from `Theme.of`.

## Verification

1. `flutter analyze` clean (no warnings, no infos).
2. `dart format --set-exit-if-changed .` clean.
3. `flutter test` green.
4. Smoke import test: a throwaway scratch file `import 'package:dropify_flutter/dropify_flutter.dart';` and reference every exported symbol — confirms the barrel surface is complete and nothing private leaks. Delete the scratch file before merging.

## Out of scope (do NOT do in M0)

- Any widget that renders pixels (anchor, panel, search field).
- Overlay/positioning logic.
- Debounce mechanics (file exists as placeholder; impl is M1).
- Default static matcher impl (file exists as placeholder; impl is M2).
- Pagination adapter.
- Example app.
- Goldens.

## Done when

- All deliverables above are merged on `main`.
- Tests + analyzer + formatter all green.
- Public barrel exports exactly the M0 surface — no more, no less.
- Next milestone (M1) can `import 'package:dropify_flutter/dropify_flutter.dart';` and have everything it needs to build `RawDropify`.
