import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../theme/dropify_theme.dart';
import 'raw_paginated_dropify.dart';

/// A Material-themed paginated Dropify dropdown.
class DropifyPaginatedDropdown<PageKey, T> extends StatelessWidget {
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
    this.errorTextBuilder,
    this.keyOf,
    this.equals,
  }) : selectionMode = DropifySelectionMode.single,
       initialValues = null,
       onChangedMulti = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

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
    this.errorTextBuilder,
    this.keyOf,
    this.equals,
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null,
       onChangedMulti = onChanged;

  final PagingState<PageKey, T> state;
  final FutureOr<void> Function() fetchNextPage;
  final String Function(T item) itemLabelBuilder;
  final ValueChanged<String>? onSearchChanged;
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
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  Widget build(BuildContext context) {
    Widget anchor(BuildContext context, DropifyAnchorState<T> state) {
      final text = state.mode == DropifySelectionMode.single
          ? (state.value == null ? null : itemLabelBuilder(state.value as T))
          : (state.values.isEmpty
                ? null
                : state.values.map(itemLabelBuilder).join(', '));
      return buildDropifyMaterialAnchor<T>(
        context: context,
        state: state,
        label: label,
        hintText: hintText,
        valueText: text,
        helperText: helperText,
        prefixIcon: prefixIcon,
        errorTextBuilder: errorTextBuilder,
      );
    }

    Widget item(
      BuildContext context,
      T value,
      int index,
      bool selected,
      VoidCallback onTap,
    ) {
      final theme = DropifyTheme.of(context);
      return ListTile(
        onTap: onTap,
        title: Text(itemLabelBuilder(value), style: theme.entryTextStyle),
        trailing: selected ? Icon(theme.entrySelectedIcon) : null,
      );
    }

    if (selectionMode == DropifySelectionMode.single) {
      return RawPaginatedDropify<PageKey, T>(
        state: state,
        fetchNextPage: fetchNextPage,
        onSearchChanged: onSearchChanged,
        anchorBuilder: anchor,
        itemBuilder: item,
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
    return RawPaginatedDropify<PageKey, T>.multi(
      state: state,
      fetchNextPage: fetchNextPage,
      onSearchChanged: onSearchChanged,
      anchorBuilder: anchor,
      itemBuilder: item,
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
