import 'package:flutter/material.dart';

import '../core/dropify_entry.dart';
import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../internal/dropify_anchor_state.dart';
import '../theme/dropify_theme.dart';
import 'raw_static_dropify.dart';

/// A Material 3 themed static dropdown that wraps [RawStaticDropify].
class DropifyDropdown<T> extends StatelessWidget {
  /// Creates a single-selection themed dropdown.
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
  }) : onChangedMulti = null,
       initialValues = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

  /// Creates a multi-selection themed dropdown.
  const DropifyDropdown.multi({
    super.key,
    required this.entries,
    this.controller,
    this.onChangedMulti,
    this.initialValues,
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
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
  }) : initialValue = null,
       onChanged = null;

  final List<DropifyEntry<T>> entries;
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
  final String Function(T item)? itemLabelBuilder;
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;

  Widget _buildThemedAnchor(BuildContext context, DropifyAnchorState<T> state) {
    final theme = DropifyTheme.of(context);
    final trailingIcon = theme.trailingIcon ?? Icons.arrow_drop_down;
    final clearIcon = theme.clearIcon ?? Icons.close;

    final displayValue = state.mode == DropifySelectionMode.single
        ? (state.value != null
              ? (itemLabelBuilder?.call(state.value as T) ??
                    state.value.toString())
              : null)
        : (state.values.isNotEmpty ? '${state.values.length} selected' : null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            hintText: hintText,
            helperText: helperText,
            prefixIcon: prefixIcon,
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showClearButton && state.clear != null)
                  IconButton(
                    icon: Icon(clearIcon, size: 20),
                    onPressed: state.clear,
                    visualDensity: VisualDensity.compact,
                  ),
                Icon(trailingIcon, size: 20),
              ],
            ),
            errorText: state.errorText,
            enabled: enabled,
          ),
          isEmpty: displayValue == null,
          child: Text(
            displayValue ?? hintText ?? '',
            style: theme.anchorValueTextStyle,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (onChangedMulti != null || initialValues != null || confirmable) {
      return RawStaticDropify<T>.multi(
        entries: entries,
        anchorBuilder: _buildThemedAnchor,
        controller: controller,
        initialValues: initialValues,
        onChangedMulti: onChangedMulti,
        searchable: searchable,
        searchHintText: searchHintText,
        showClearButton: showClearButton,
        enabled: enabled,
        validator: validator,
        autovalidateMode: autovalidateMode,
        confirmable: confirmable,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
      );
    }

    return RawStaticDropify<T>(
      entries: entries,
      anchorBuilder: _buildThemedAnchor,
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      searchable: searchable,
      searchHintText: searchHintText,
      showClearButton: showClearButton,
      enabled: enabled,
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
  }
}
