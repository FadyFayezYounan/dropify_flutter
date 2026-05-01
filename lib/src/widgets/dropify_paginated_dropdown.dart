import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../internal/_dropify_menu_item_button.dart';
import 'raw_paginated_dropify.dart';
import '_dropify_themed_helpers.dart';

/// A Material-styled dropdown backed by caller-owned paginated state.
///
/// This widget consumes a [PagingState] and calls [fetchNextPage] when it needs
/// data. It never mutates the supplied state; callers remain responsible for
/// loading pages, storing errors, resetting search, and cancelling old work.
///
/// See also:
///
///  * [RawPaginatedDropify], which exposes custom paginated item and footer
///    builders.
///  * [DropifyPagingState], a convenience paging state with search and
///    cancellation metadata.
///  * [DropifyAsyncDropdown], for debounced async search without paging.
class DropifyPaginatedDropdown<PageKey, T> extends StatelessWidget {
  /// Creates a single-selection paginated dropdown.
  ///
  /// The [state], [fetchNextPage], and [itemLabelBuilder] arguments are
  /// required.
  const DropifyPaginatedDropdown({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.itemLabelBuilder,
    this.onSearchChanged,
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
  }) : selectionMode = DropifySelectionMode.single,
       initialValues = null,
       onChangedMulti = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

  /// Creates a multi-selection paginated dropdown.
  ///
  /// When [confirmable] is true, selected values are staged until the user
  /// applies them.
  const DropifyPaginatedDropdown.multi({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.itemLabelBuilder,
    this.onSearchChanged,
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
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null,
       onChangedMulti = onChanged;

  /// The caller-owned paging state to render.
  final PagingState<PageKey, T> state;

  /// Requests the next page from the caller.
  ///
  /// The caller must update [state] when loading starts, succeeds, or fails.
  final FutureOr<void> Function() fetchNextPage;

  /// Builds the visible label for an item value.
  final String Function(T item) itemLabelBuilder;

  /// Called with the debounced search query.
  ///
  /// Use this to cancel old work, reset paging state, and fetch the new query.
  final void Function(String query)? onSearchChanged;

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
      return RawPaginatedDropify<PageKey, T>(
        state: state,
        fetchNextPage: fetchNextPage,
        onSearchChanged: onSearchChanged,
        anchorBuilder: anchor,
        itemBuilder: (context, item, index, selected, onTap) =>
            DropifyMenuItemButton(
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
      );
    }
    return RawPaginatedDropify<PageKey, T>.multi(
      state: state,
      fetchNextPage: fetchNextPage,
      onSearchChanged: onSearchChanged,
      anchorBuilder: anchor,
      itemBuilder: (context, item, index, selected, onTap) =>
          DropifyMenuItemButton(
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
      confirmable: confirmable,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    );
  }
}
