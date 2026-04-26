import 'package:flutter/material.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../internal/dropify_anchor_state.dart';
import '../theme/dropify_theme.dart';
import 'raw_async_dropify.dart';

/// A Material 3 themed async dropdown that wraps [RawAsyncDropify].
class DropifyAsyncDropdown<T> extends StatelessWidget {
  const DropifyAsyncDropdown({
    super.key,
    required this.fetcher,
    required this.itemLabelBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.loadOnOpen = true,
    this.cacheItems = true,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.searchHintText,
    this.showClearButton = false,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
  }) : onChangedMulti = null,
       initialValues = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

  const DropifyAsyncDropdown.multi({
    super.key,
    required this.fetcher,
    required this.itemLabelBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.loadOnOpen = true,
    this.cacheItems = true,
    this.controller,
    this.onChangedMulti,
    this.initialValues,
    this.label,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.searchHintText,
    this.showClearButton = false,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
  }) : initialValue = null,
       onChanged = null;

  final DropifyAsyncFetcher<T> fetcher;
  final String Function(T) itemLabelBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)? errorBuilder;
  final Widget Function(BuildContext, bool)? emptyBuilder;
  final bool loadOnOpen;
  final bool cacheItems;

  final DropifyController<T>? controller;
  final T? initialValue;
  final Set<T>? initialValues;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<Set<T>>? onChangedMulti;

  final String? label;
  final String? hintText;
  final String? helperText;
  final Widget? prefixIcon;
  final String? searchHintText;
  final bool showClearButton;
  final bool enabled;
  final FormFieldValidator<DropifyValue<T>>? validator;
  final AutovalidateMode? autovalidateMode;
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;

  Widget _buildThemedAnchor(BuildContext context, DropifyAnchorState<T> state) {
    final theme = DropifyTheme.of(context);
    final displayValue = state.mode == DropifySelectionMode.single
        ? (state.value != null ? itemLabelBuilder(state.value as T) : null)
        : (state.values.isNotEmpty ? '${state.values.length} selected' : null);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: prefixIcon,
        suffixIcon: Icon(theme.trailingIcon ?? Icons.arrow_drop_down),
        errorText: state.errorText,
        enabled: enabled,
      ),
      isEmpty: displayValue == null,
      child: Text(
        displayValue ?? hintText ?? '',
        style: theme.anchorValueTextStyle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMulti =
        onChangedMulti != null || initialValues != null || confirmable;

    if (isMulti) {
      return RawAsyncDropify<T>.multi(
        fetcher: fetcher,
        anchorBuilder: _buildThemedAnchor,
        itemBuilder: (ctx, item, selected, onTap) {
          return InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Text(itemLabelBuilder(item))),
                  if (selected) const Icon(Icons.check, size: 18),
                ],
              ),
            ),
          );
        },
        loadingBuilder: loadingBuilder,
        errorBuilder: errorBuilder,
        emptyBuilder: emptyBuilder,
        loadOnOpen: loadOnOpen,
        cacheItems: cacheItems,
        controller: controller,
        initialValues: initialValues,
        onChangedMulti: onChangedMulti,
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

    return RawAsyncDropify<T>(
      fetcher: fetcher,
      anchorBuilder: _buildThemedAnchor,
      itemBuilder: (ctx, item, selected, onTap) {
        return InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Expanded(child: Text(itemLabelBuilder(item))),
                if (selected) const Icon(Icons.check, size: 18),
              ],
            ),
          ),
        );
      },
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      emptyBuilder: emptyBuilder,
      loadOnOpen: loadOnOpen,
      cacheItems: cacheItems,
      controller: controller,
      initialValue: initialValue,
      onChanged: onChanged,
      searchHintText: searchHintText,
      showClearButton: showClearButton,
      enabled: enabled,
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
  }
}
