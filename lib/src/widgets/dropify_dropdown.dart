import 'package:flutter/widgets.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_entry.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import 'raw_static_dropify.dart';

/// A Material-themed static Dropify dropdown.
class DropifyDropdown<T> extends StatelessWidget {
  /// Creates a single-selection themed static dropdown.
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
    this.errorTextBuilder,
    this.itemLabelBuilder,
    this.keyOf,
    this.equals,
  }) : selectionMode = DropifySelectionMode.single,
       initialValues = null,
       onChangedMulti = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

  /// Creates a multi-selection themed static dropdown.
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
    this.errorTextBuilder,
    this.itemLabelBuilder,
    this.keyOf,
    this.equals,
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null,
       onChangedMulti = onChanged;

  final List<DropifyEntry<T>> entries;
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
  final Widget Function(BuildContext, String error)? errorTextBuilder;
  final String Function(T item)? itemLabelBuilder;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    String labelFor(T item) => itemLabelBuilder?.call(item) ?? item.toString();
    String? valueText(DropifyAnchorState<T> state) {
      if (state.mode == DropifySelectionMode.single) {
        final value = state.value;
        if (value == null) {
          return null;
        }
        for (final entry in entries) {
          if (entry.value == value) {
            return entry.label ?? labelFor(value);
          }
        }
        return labelFor(value);
      }
      if (state.values.isEmpty) {
        return null;
      }
      return state.values.map(labelFor).join(', ');
    }

    Widget anchor(BuildContext context, DropifyAnchorState<T> state) {
      return buildDropifyMaterialAnchor<T>(
        context: context,
        state: state,
        label: label,
        hintText: hintText,
        valueText: valueText(state),
        helperText: helperText,
        prefixIcon: prefixIcon,
        errorTextBuilder: errorTextBuilder,
      );
    }

    if (selectionMode == DropifySelectionMode.single) {
      return RawStaticDropify<T>(
        entries: entries,
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
        errorTextBuilder: errorTextBuilder,
        keyOf: keyOf,
        equals: equals,
      );
    }
    return RawStaticDropify<T>.multi(
      entries: entries,
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
      errorTextBuilder: errorTextBuilder,
      keyOf: keyOf,
      equals: equals,
      confirmable: confirmable,
      confirmLabel: confirmLabel,
      cancelLabel: cancelLabel,
    );
  }
}
