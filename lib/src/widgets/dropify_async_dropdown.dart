import 'package:flutter/material.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import 'raw_async_dropify.dart';
import '_dropify_themed_helpers.dart';

/// A Material-styled async Dropify dropdown.
class DropifyAsyncDropdown<T> extends StatelessWidget {
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
  }) : selectionMode = DropifySelectionMode.single,
       initialValues = null,
       onChangedMulti = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

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
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null,
       onChangedMulti = onChanged;

  final DropifyAsyncFetcher<T> fetcher;
  final String Function(T item) itemLabelBuilder;
  final DropifySelectionMode selectionMode;
  final DropifyController<T>? controller;
  final T? initialValue;
  final Set<T>? initialValues;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<Set<T>>? onChangedMulti;
  final String? label;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final bool searchable;
  final String? searchHintText;
  final bool showClearButton;
  final bool enabled;
  final FormFieldValidator<DropifyValue<T>>? validator;
  final AutovalidateMode? autovalidateMode;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;
  final bool confirmable;
  final String? confirmLabel;
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
        itemBuilder: (context, item, selected, onTap) =>
            themedItem(context, item, selected, onTap, itemLabelBuilder),
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
    return RawAsyncDropify<T>.multi(
      fetcher: fetcher,
      anchorBuilder: anchor,
      itemBuilder: (context, item, selected, onTap) =>
          themedItem(context, item, selected, onTap, itemLabelBuilder),
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
