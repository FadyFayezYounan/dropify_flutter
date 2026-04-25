# 006 — DropifyFormField (M5)

> Parent spec: [000-dropify_flutter.md](000-dropify_flutter.md)
>
> Depends on: [005-paginated_dropdown.md](005-paginated_dropdown.md) merged.
>
> Scope: Layer 3 form integration. A single `DropifyFormField<T>` (and `.multi`) for all three data sources, configured via a sealed `source:` arg. Validator + error display in the anchor.

## Goal

Wrap any of the M2/M3/M4 concrete widgets in `FormField<T>` / `FormField<List<T>>` so they integrate cleanly with `Form`. One unified form-field class — not three siblings — because the `FormField` ceremony dominates and three near-duplicates would be noisy. The source-specific config lives in the sealed `source:` arg.

This is the only file in the package that knows about `Form` / `FormField`.

## Deliverables

### 1. Sealed `DropifyFormSource<T>`

```dart
sealed class DropifyFormSource<T> {
  const DropifyFormSource();

  const factory DropifyFormSource.static({
    required List<DropifyEntry<T>> entries,
    DropifyStaticMatcher<T>? matcher,
  }) = StaticDropifyFormSource<T>;

  const factory DropifyFormSource.async({
    required Future<List<DropifyEntry<T>>> Function(String query) fetch,
    bool fetchOnOpen,
  }) = AsyncDropifyFormSource<T>;

  const factory DropifyFormSource.paginated({
    required Future<List<DropifyEntry<T>>> Function(int pageKey, String query) fetchPage,
    int firstPageKey,
    int pageSize,
  }) = PaginatedDropifyFormSource<T>;
}
```

Lives in `lib/src/widgets/dropify_form_field.dart`. Use Dart's `sealed` keyword so the form field's switch is exhaustive at compile time.

### 2. `DropifyFormField<T>`

```dart
class DropifyFormField<T> extends FormField<T> {
  DropifyFormField({
    super.key,
    required DropifyFormSource<T> source,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
    super.enabled = true,
    DropifyController<T>? controller,
    String? label,
    String? hintText,
    /* shared props passed through to the underlying widget */
  }) : super(
          builder: (state) {
            // switch on `source`; build the matching M2/M3/M4 widget
            // with onChanged → state.didChange + super.didChange
            // and pass an error decoration into the anchor
            // ...
          },
        );

  factory DropifyFormField.multi({
    Key? key,
    required DropifyFormSource<T> source,
    List<T>? initialValues,
    FormFieldSetter<List<T>>? onSaved,
    FormFieldValidator<List<T>>? validator,
    AutovalidateMode? autovalidateMode,
    int? minSelection,
    int? maxSelection,
    /* shared multi props */
  }) = _MultiDropifyFormField<T>;
}
```

Implementation notes:

- `_MultiDropifyFormField<T>` extends `FormField<List<T>>`; the public `.multi` factory exposes it without leaking the private name.
- The internal builder switches on `source`:
  - `StaticDropifyFormSource` → `DropifyDropdown<T>` (or `.multi`).
  - `AsyncDropifyFormSource` → `DropifyAsyncDropdown<T>`.
  - `PaginatedDropifyFormSource` → `DropifyPaginatedDropdown<T>`.
- The wrapped widget's `onChanged` calls `state.didChange(value)` so `Form` validation runs.
- `state.errorText` is forwarded into the anchor via the existing error-state hook reserved in M2's `_DropifyAnchor`. Render a red border + error string below the anchor (`InputDecoration.errorText` style).
- `state.reset()` resets controller selection to `initialValue` / `initialValues` and re-validates.
- `enabled: false` propagates to the underlying widget's `enabled` prop.
- If the consumer didn't pass a `controller`, instantiate one internally; honor `initialValue` / `initialValues`.

### 3. Public exports

Add `DropifyFormField`, `DropifyFormSource`, and the three concrete `DropifyFormSource` variants to the barrel. Keep `_MultiDropifyFormField` private.

### 4. Example page

`example/lib/pages/form_page.dart`. A `Form` with three fields, demonstrating one `DropifyFormField` per source:

- Single static field with a `validator` enforcing required selection.
- Single async field with `validator` ensuring the value is "approved".
- Multi paginated field with `validator` requiring `>= 2` selections.

A submit button triggers `Form.of(context).validate()` and shows a `SnackBar` with the saved values on success. Wire into gallery.

## Tests

`test/widgets/dropify_form_field_test.dart`:

- Construction with each `source` variant builds the right underlying widget (verify via `find.byType(DropifyDropdown<...>)` etc).
- `validator` runs on submit; failure shows the error text in the anchor.
- `onChanged` (internal) drives `state.didChange` → `Form.of(context).validate()` reflects new value.
- `onSaved` is called with the latest selection on `Form.of(context).save()`.
- `autovalidateMode: AutovalidateMode.onUserInteraction` runs validation after first interaction.
- `initialValue` / `initialValues` populate the field; `state.reset()` restores them.
- `enabled: false` disables the anchor.
- `.multi` returns a `FormField<List<T>>` and validators receive `List<T>`.
- Async/paginated form fields propagate per-state builders (smoke test that `loadingBuilder` etc still work inside the form-field wrapper).

## Verification

1. `flutter analyze` + `dart format` clean.
2. `flutter test` green (M0–M4 tests still pass).
3. `cd example && flutter run` — `form_page.dart`:
   - Submit empty form → all three fields show errors.
   - Fill correctly → submit shows SnackBar with saved values.
   - Reset button (if added) restores initial state.
4. Screenshot the form in error vs valid states.

## Out of scope

- Polish & a11y, README, dartdoc, goldens. → M6 (#007).
- Cupertino sibling.

## Done when

- One `DropifyFormField<T>` (and `.multi`) handles all three data sources via the sealed `source:` arg.
- Validator, `onSaved`, `autovalidateMode`, error decoration in the anchor all work.
- The form example demos all three sources side-by-side.
- M0–M4 functionality unaffected.
