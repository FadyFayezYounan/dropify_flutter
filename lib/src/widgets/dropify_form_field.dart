import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../core/dropify_data_source.dart';
import '../core/dropify_entry.dart';
import '../core/raw_dropify.dart';
import '../theme/dropify_theme_data.dart';
import 'dropify_async_dropdown.dart';
import 'dropify_dropdown.dart';
import 'dropify_paginated_dropdown.dart';

/// Describes the concrete dropdown used by a [DropifyFormField].
sealed class DropifyFormSource<T> {
  /// Creates a form source backed by static [entries].
  const factory DropifyFormSource.entries({
    required List<DropifyEntry<T>> entries,
    DropifyStaticMatcher<T>? matcher,
  }) = DropifyEntriesFormSource<T>;

  /// Creates a form source backed by an async [fetch] callback.
  const factory DropifyFormSource.async({
    required DropifyAsyncFetcher<T> fetch,
    bool fetchOnOpen,
  }) = DropifyAsyncFormSource<T>;

  /// Creates a form source backed by a paginated [fetchPage] callback.
  const factory DropifyFormSource.paginated({
    required DropifyPageFetcher<T> fetchPage,
    int firstPageKey,
    int pageSize,
  }) = DropifyPaginatedFormSource<T>;

  const DropifyFormSource._();
}

/// A static source used by [DropifyFormField].
class DropifyEntriesFormSource<T> extends DropifyFormSource<T> {
  /// Creates a static form source.
  const DropifyEntriesFormSource({required this.entries, this.matcher})
    : super._();

  /// Entries shown by the dropdown.
  final List<DropifyEntry<T>> entries;

  /// Optional static matcher override.
  final DropifyStaticMatcher<T>? matcher;
}

/// An async source used by [DropifyFormField].
class DropifyAsyncFormSource<T> extends DropifyFormSource<T> {
  /// Creates an async form source.
  const DropifyAsyncFormSource({required this.fetch, this.fetchOnOpen = true})
    : super._();

  /// Fetches entries for the current query.
  final DropifyAsyncFetcher<T> fetch;

  /// Whether opening the dropdown triggers the first fetch.
  final bool fetchOnOpen;
}

/// A paginated source used by [DropifyFormField].
class DropifyPaginatedFormSource<T> extends DropifyFormSource<T> {
  /// Creates a paginated form source.
  const DropifyPaginatedFormSource({
    required this.fetchPage,
    this.firstPageKey = 0,
    this.pageSize = 20,
  }) : super._();

  /// Fetches one page for the current query.
  final DropifyPageFetcher<T> fetchPage;

  /// The first page key supplied to [fetchPage].
  final int firstPageKey;

  /// The requested page size.
  final int pageSize;
}

/// A [FormField] adapter for static, async, and paginated Dropify widgets.
///
/// Select the backing widget with [DropifyFormSource.entries],
/// [DropifyFormSource.async], or [DropifyFormSource.paginated]. Validation,
/// saving, and autovalidation follow Flutter's standard [FormField] contract.
///
/// {@tool snippet}
/// ```dart
/// DropifyFormField<String>(
///   source: DropifyFormSource.entries(entries: const [
///     DropifyEntry(value: 'apple', label: 'Apple'),
///   ]),
///   validator: (value) => value == null ? 'Choose a fruit' : null,
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [DropifyDropdown], for static dropdowns outside a form.
///  * [DropifyAsyncDropdown], for async dropdowns outside a form.
///  * [DropifyPaginatedDropdown], for paginated dropdowns outside a form.
class DropifyFormField<T> extends StatelessWidget {
  /// Creates a single-select Dropify form field.
  const DropifyFormField({
    super.key,
    required this.source,
    this.initialValue,
    FormFieldSetter<T>? onSaved,
    FormFieldValidator<T>? validator,
    ValueChanged<T?>? onChanged,
    this.autovalidateMode,
    this.label,
    this.hintText,
    this.errorText,
    this.searchEnabled = true,
    this.searchHint,
    this.theme,
    this.enabled = true,
    this.queryDebounce = const Duration(milliseconds: 300),
  }) : _isMulti = false,
       initialValues = const <Never>[],
       _singleOnSaved = onSaved,
       _singleValidator = validator,
       _singleOnChanged = onChanged,
       _multiOnSaved = null,
       _multiValidator = null,
       _multiOnChanged = null;

  /// Creates a multi-select Dropify form field.
  const DropifyFormField.multi({
    super.key,
    required this.source,
    this.initialValues = const <Never>[],
    FormFieldSetter<List<T>>? onSaved,
    FormFieldValidator<List<T>>? validator,
    ValueChanged<List<T>>? onChanged,
    this.autovalidateMode,
    this.label,
    this.hintText,
    this.errorText,
    this.searchEnabled = true,
    this.searchHint,
    this.theme,
    this.enabled = true,
    this.queryDebounce = const Duration(milliseconds: 300),
  }) : _isMulti = true,
       initialValue = null,
       _singleOnSaved = null,
       _singleValidator = null,
       _singleOnChanged = null,
       _multiOnSaved = onSaved,
       _multiValidator = validator,
       _multiOnChanged = onChanged;

  /// Source used to choose the concrete dropdown widget.
  final DropifyFormSource<T> source;

  /// Initial selected value for single-select fields.
  final T? initialValue;

  /// Initial selected values for multi-select fields.
  final List<T> initialValues;

  /// When to run validation automatically.
  final AutovalidateMode? autovalidateMode;

  /// Optional label shown above the selected value or chips.
  final String? label;

  /// Text shown when there is no selection.
  final String? hintText;

  /// Optional non-validation error text shown by the default anchor.
  final String? errorText;

  /// Whether the default panel includes a search field.
  final bool searchEnabled;

  /// Hint text for the default search field.
  final String? searchHint;

  /// Per-widget theme override.
  final DropifyThemeData? theme;

  /// Whether the default anchor can open the dropdown.
  final bool enabled;

  /// Debounce applied to async and paginated query changes.
  final Duration queryDebounce;

  final bool _isMulti;
  final FormFieldSetter<T>? _singleOnSaved;
  final FormFieldValidator<T>? _singleValidator;
  final ValueChanged<T?>? _singleOnChanged;
  final FormFieldSetter<List<T>>? _multiOnSaved;
  final FormFieldValidator<List<T>>? _multiValidator;
  final ValueChanged<List<T>>? _multiOnChanged;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(FlagProperty('isMulti', value: _isMulti, ifTrue: 'multi'));
    properties.add(
      FlagProperty('searchEnabled', value: searchEnabled, ifFalse: 'no search'),
    );
    properties.add(
      FlagProperty('enabled', value: enabled, ifFalse: 'disabled'),
    );
    properties.add(StringProperty('label', label, defaultValue: null));
    properties.add(StringProperty('hintText', hintText, defaultValue: null));
    properties.add(StringProperty('errorText', errorText, defaultValue: null));
    properties.add(
      DiagnosticsProperty<AutovalidateMode?>(
        'autovalidateMode',
        autovalidateMode,
        defaultValue: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isMulti) {
      return FormField<List<T>>(
        initialValue: initialValues,
        onSaved: _multiOnSaved,
        validator: _multiValidator,
        autovalidateMode: autovalidateMode,
        builder: _buildMultiField,
      );
    }
    return FormField<T>(
      initialValue: initialValue,
      onSaved: _singleOnSaved,
      validator: _singleValidator,
      autovalidateMode: autovalidateMode,
      builder: _buildSingleField,
    );
  }

  Widget _buildSingleField(FormFieldState<T> field) {
    final String? effectiveErrorText = field.errorText ?? errorText;
    switch (source) {
      case DropifyEntriesFormSource<T>(
        entries: final List<DropifyEntry<T>> entries,
        matcher: final DropifyStaticMatcher<T>? matcher,
      ):
        return DropifyDropdown<T>(
          entries: entries,
          initialValue: field.value,
          onChanged: (T? value) {
            field.didChange(value);
            _singleOnChanged?.call(value);
          },
          label: label,
          hintText: hintText,
          errorText: effectiveErrorText,
          searchEnabled: searchEnabled,
          searchHint: searchHint,
          staticMatcher: matcher,
          theme: theme,
          enabled: enabled,
        );
      case DropifyAsyncFormSource<T>(
        fetch: final DropifyAsyncFetcher<T> fetch,
        fetchOnOpen: final bool fetchOnOpen,
      ):
        return DropifyAsyncDropdown<T>(
          fetch: fetch,
          fetchOnOpen: fetchOnOpen,
          initialValue: field.value,
          onChanged: (T? value) {
            field.didChange(value);
            _singleOnChanged?.call(value);
          },
          label: label,
          hintText: hintText,
          errorText: effectiveErrorText,
          searchEnabled: searchEnabled,
          searchHint: searchHint,
          theme: theme,
          enabled: enabled,
          queryDebounce: queryDebounce,
        );
      case DropifyPaginatedFormSource<T>(
        fetchPage: final DropifyPageFetcher<T> fetchPage,
        firstPageKey: final int firstPageKey,
        pageSize: final int pageSize,
      ):
        return DropifyPaginatedDropdown<T>(
          fetchPage: fetchPage,
          firstPageKey: firstPageKey,
          pageSize: pageSize,
          initialValue: field.value,
          onChanged: (T? value) {
            field.didChange(value);
            _singleOnChanged?.call(value);
          },
          label: label,
          hintText: hintText,
          errorText: effectiveErrorText,
          searchEnabled: searchEnabled,
          searchHint: searchHint,
          theme: theme,
          enabled: enabled,
          queryDebounce: queryDebounce,
        );
    }
  }

  Widget _buildMultiField(FormFieldState<List<T>> field) {
    final String? effectiveErrorText = field.errorText ?? errorText;
    final List<T> values = field.value ?? List<T>.empty();
    switch (source) {
      case DropifyEntriesFormSource<T>(
        entries: final List<DropifyEntry<T>> entries,
        matcher: final DropifyStaticMatcher<T>? matcher,
      ):
        return DropifyDropdown<T>.multi(
          entries: entries,
          initialValues: values,
          onChanged: (List<T> nextValues) {
            field.didChange(nextValues);
            _multiOnChanged?.call(nextValues);
          },
          label: label,
          hintText: hintText,
          errorText: effectiveErrorText,
          searchEnabled: searchEnabled,
          searchHint: searchHint,
          staticMatcher: matcher,
          theme: theme,
          enabled: enabled,
        );
      case DropifyAsyncFormSource<T>(
        fetch: final DropifyAsyncFetcher<T> fetch,
        fetchOnOpen: final bool fetchOnOpen,
      ):
        return DropifyAsyncDropdown<T>.multi(
          fetch: fetch,
          fetchOnOpen: fetchOnOpen,
          initialValues: values,
          onChanged: (List<T> nextValues) {
            field.didChange(nextValues);
            _multiOnChanged?.call(nextValues);
          },
          label: label,
          hintText: hintText,
          errorText: effectiveErrorText,
          searchEnabled: searchEnabled,
          searchHint: searchHint,
          theme: theme,
          enabled: enabled,
          queryDebounce: queryDebounce,
        );
      case DropifyPaginatedFormSource<T>(
        fetchPage: final DropifyPageFetcher<T> fetchPage,
        firstPageKey: final int firstPageKey,
        pageSize: final int pageSize,
      ):
        return DropifyPaginatedDropdown<T>.multi(
          fetchPage: fetchPage,
          firstPageKey: firstPageKey,
          pageSize: pageSize,
          initialValues: values,
          onChanged: (List<T> nextValues) {
            field.didChange(nextValues);
            _multiOnChanged?.call(nextValues);
          },
          label: label,
          hintText: hintText,
          errorText: effectiveErrorText,
          searchEnabled: searchEnabled,
          searchHint: searchHint,
          theme: theme,
          enabled: enabled,
          queryDebounce: queryDebounce,
        );
    }
  }
}
