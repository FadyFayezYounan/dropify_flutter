import 'package:flutter/material.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_entry.dart';
import '../core/dropify_menu_body_mode.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import 'raw_static_dropify.dart';
import '_dropify_themed_helpers.dart';

/// A Material-styled dropdown backed by in-memory [DropifyEntry] values.
///
/// Use this widget when every option is available locally. The dropdown can
/// render a search field, disabled entries, clear affordances, form validation,
/// and single or multi-selection flows.
///
/// The [entries] list is filtered locally when [searchable] is true. To provide
/// a custom row builder or matcher, use [RawStaticDropify].
///
/// See also:
///
///  * [RawStaticDropify], which provides static dropdown behavior without the
///    Material-styled anchor.
///  * [DropifyAsyncDropdown], for debounced remote search.
///  * [DropifyPaginatedDropdown], for caller-owned paginated results.
class DropifyDropdown<T> extends StatelessWidget {
  /// Creates a single-selection static dropdown.
  ///
  /// The [entries] argument is required. The [searchable] argument defaults to
  /// false and [showClearButton] defaults to false.
  const DropifyDropdown({
    super.key,
    required this.entries,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.searchable = false,
    this.searchHintText,
    this.showClearButton = false,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.itemLabelBuilder,
    this.keyOf,
    this.equals,
    this.menuBodyMode = DropifyMenuBodyMode.automatic,
    this.scrollToSelectedOnOpen = true,
  }) : selectionMode = DropifySelectionMode.single,
       initialValues = null,
       onChangedMulti = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

  /// Creates a multi-selection static dropdown.
  ///
  /// When [confirmable] is false, toggles are emitted immediately. When
  /// [confirmable] is true, toggles are staged until the user applies them.
  const DropifyDropdown.multi({
    super.key,
    required this.entries,
    this.controller,
    this.initialValues,
    ValueChanged<Set<T>>? onChanged,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.searchable = false,
    this.searchHintText,
    this.showClearButton = false,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.itemLabelBuilder,
    this.keyOf,
    this.equals,
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null,
       onChangedMulti = onChanged,
       menuBodyMode = DropifyMenuBodyMode.automatic,
       scrollToSelectedOnOpen = true;

  /// The options shown by the dropdown.
  ///
  /// Disabled entries remain visible but cannot be selected.
  final List<DropifyEntry<T>> entries;

  /// The active selection mode for this widget instance.
  final DropifySelectionMode selectionMode;

  /// An optional external controller for selection and open state.
  ///
  /// If null, the widget creates and disposes its own controller.
  final DropifyController<T>? controller;

  /// The initially selected value for single-selection dropdowns.
  final T? initialValue;

  /// The initially selected values for multi-selection dropdowns.
  final Set<T>? initialValues;

  /// Called when single selection changes.
  final ValueChanged<T?>? onChanged;

  /// Called when multi selection changes.
  final ValueChanged<Set<T>>? onChangedMulti;

  /// The label displayed by the default themed anchor.
  final String? label;

  /// The hint text displayed when no value is selected.
  final String? hintText;

  /// Helper text displayed below the anchor.
  final String? helperText;

  /// An optional icon displayed before the selected value or hint.
  final Widget? prefixIcon;

  /// Whether the panel includes a search field.
  ///
  /// Defaults to false.
  final bool searchable;

  /// Hint text for the search field.
  ///
  /// If null, the theme-provided search decoration is used.
  final String? searchHintText;

  /// Whether a clear button is shown when a value is selected.
  ///
  /// Defaults to false.
  final bool showClearButton;

  /// Whether the dropdown accepts user interaction.
  ///
  /// Defaults to true.
  final bool enabled;

  /// Validates the current Dropify value when used inside a [Form].
  final FormFieldValidator<DropifyValue<T>>? validator;

  /// Controls when validation runs.
  final AutovalidateMode? autovalidateMode;

  /// Builds the visible label for an item value.
  ///
  /// If null, each entry's [DropifyEntry.label] or value string is used.
  final String Function(T item)? itemLabelBuilder;

  /// Returns a stable identity key for a value.
  ///
  /// Use this when new object instances can represent the same logical item.
  final Object Function(T item)? keyOf;

  /// Compares two values for selection identity.
  ///
  /// Prefer [keyOf] when a stable identity key is available.
  final bool Function(T a, T b)? equals;

  /// Whether multi-selection changes are staged until applied.
  ///
  /// Defaults to false.
  final bool confirmable;

  /// The label for the confirm button in confirmable multi-selection.
  ///
  /// If null, the default visible copy is used.
  final String? confirmLabel;

  /// The label for the cancel button in confirmable multi-selection.
  ///
  /// If null, the default visible copy is used.
  final String? cancelLabel;

  /// Controls whether non-empty static row bodies are eager or lazy.
  ///
  /// Defaults to [DropifyMenuBodyMode.automatic], which keeps the built-in
  /// static threshold. Paginated dropdowns do not use this setting.
  final DropifyMenuBodyMode menuBodyMode;

  /// Whether opening the menu should jump to the selected visible row.
  ///
  /// Defaults to true. If the selected value is not present in the current
  /// visible rows, opening preserves normal initial scroll offset behavior.
  final bool scrollToSelectedOnOpen;

  @override
  Widget build(BuildContext context) {
    final anchor = themedAnchorBuilder<T>(
      label: label,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      itemLabelBuilder: itemLabelBuilder,
    );
    final effectiveEntries = entriesWithLabels(entries, itemLabelBuilder);
    if (selectionMode == DropifySelectionMode.single) {
      return RawStaticDropify<T>(
        entries: effectiveEntries,
        anchorBuilder: anchor,
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        searchable: searchable,
        searchHintText: searchHintText,
        showClearButton: showClearButton,
        enabled: enabled,
        validator: validator,
        autovalidateMode: autovalidateMode,
        keyOf: keyOf,
        equals: equals,
        menuBodyMode: menuBodyMode,
        scrollToSelectedOnOpen: scrollToSelectedOnOpen,
      );
    }
    return RawStaticDropify<T>.multi(
      entries: effectiveEntries,
      anchorBuilder: anchor,
      controller: controller,
      initialValues: initialValues,
      onChanged: onChangedMulti,
      searchable: searchable,
      searchHintText: searchHintText,
      showClearButton: showClearButton,
      enabled: enabled,
      validator: validator,
      autovalidateMode: autovalidateMode,
      keyOf: keyOf,
      equals: equals,
      confirmable: confirmable,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    );
  }
}
