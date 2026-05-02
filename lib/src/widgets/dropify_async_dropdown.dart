import 'package:flutter/material.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_menu_body_mode.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../internal/_dropify_menu_item_button.dart';
import 'raw_async_dropify.dart';
import '_dropify_themed_helpers.dart';

/// A Material-styled dropdown backed by a debounced async fetcher.
///
/// Use this widget when options are loaded from a remote search, database, or
/// other asynchronous source. The fetcher receives a [DropifyCancelToken] so
/// replacement searches can cancel old work and stale results can be ignored.
///
/// See also:
///
///  * [RawAsyncDropify], which exposes custom async item and state builders.
///  * [DropifyDropdown], for in-memory entries.
///  * [DropifyPaginatedDropdown], for caller-owned paginated results.
class DropifyAsyncDropdown<T> extends StatelessWidget {
  /// Creates a single-selection async dropdown.
  ///
  /// The [fetcher] and [itemLabelBuilder] arguments are required.
  const DropifyAsyncDropdown({
    super.key,
    required this.fetcher,
    required this.itemLabelBuilder,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.searchable = true,
    this.searchHintText,
    this.showClearButton = false,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
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

  /// Creates a multi-selection async dropdown.
  ///
  /// When [confirmable] is true, selected values are staged until the user
  /// applies them.
  const DropifyAsyncDropdown.multi({
    super.key,
    required this.fetcher,
    required this.itemLabelBuilder,
    this.controller,
    this.initialValues,
    ValueChanged<Set<T>>? onChanged,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.searchable = true,
    this.searchHintText,
    this.showClearButton = false,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.keyOf,
    this.equals,
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
    this.menuBodyMode = DropifyMenuBodyMode.automatic,
    this.scrollToSelectedOnOpen = true,
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null,
       onChangedMulti = onChanged;

  /// Fetches items for the current search query.
  ///
  /// Replacement fetches cancel the previous token. Cancelled and stale
  /// completions do not update visible state.
  final DropifyAsyncFetcher<T> fetcher;

  /// Builds the visible label for an item value.
  final String Function(T item) itemLabelBuilder;

  /// The active selection mode for this widget instance.
  final DropifySelectionMode selectionMode;

  /// An optional external controller for selection and open state.
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
  /// Defaults to true.
  final bool searchable;

  /// Hint text for the search field.
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

  /// Returns a stable identity key for a value.
  final Object Function(T item)? keyOf;

  /// Compares two values for selection identity.
  final bool Function(T a, T b)? equals;

  /// Controls whether loaded async row bodies are eager or lazy.
  ///
  /// Defaults to [DropifyMenuBodyMode.automatic], which uses lazy indexed rows
  /// for async loaded and refreshing data. Paginated dropdowns do not use this
  /// setting.
  final DropifyMenuBodyMode menuBodyMode;

  /// Whether opening the menu should jump to the selected visible row.
  ///
  /// Defaults to true. Async dropdowns only inspect currently rendered loaded or
  /// refreshing rows and never fetch extra items to find a selection.
  final bool scrollToSelectedOnOpen;

  /// Whether multi-selection changes are staged until applied.
  final bool confirmable;

  /// The label for the confirm button in confirmable multi-selection.
  final String? confirmLabel;

  /// The label for the cancel button in confirmable multi-selection.
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    final anchor = themedAnchorBuilder<T>(
      label: label,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      itemLabelBuilder: itemLabelBuilder,
    );
    if (selectionMode == DropifySelectionMode.single) {
      return RawAsyncDropify<T>(
        fetcher: fetcher,
        anchorBuilder: anchor,
        itemBuilder: (context, item, selected, onTap) => DropifyMenuItemButton(
          itemKey: dropifyMenuItemKey(keyOf?.call(item), item),
          semanticsLabel: itemLabelBuilder(item),
          selected: selected,
          onPressed: onTap,
          child: Text(itemLabelBuilder(item)),
        ),
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
    return RawAsyncDropify<T>.multi(
      fetcher: fetcher,
      anchorBuilder: anchor,
      itemBuilder: (context, item, selected, onTap) => DropifyMenuItemButton(
        itemKey: dropifyMenuItemKey(keyOf?.call(item), item),
        semanticsLabel: itemLabelBuilder(item),
        selected: selected,
        onPressed: onTap,
        child: Text(itemLabelBuilder(item)),
      ),
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
      menuBodyMode: menuBodyMode,
      scrollToSelectedOnOpen: scrollToSelectedOnOpen,
      confirmable: confirmable,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    );
  }
}
