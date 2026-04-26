import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_entry.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/_default_matcher.dart';
import '../theme/dropify_theme.dart';

/// Builds a static Dropify entry.
typedef DropifyEntryBuilder<T> =
    Widget Function(
      BuildContext context,
      DropifyEntry<T> entry,
      bool selected,
      VoidCallback onTap,
    );

/// A raw dropdown backed by in-memory entries.
class RawStaticDropify<T> extends StatelessWidget {
  /// Creates a single-selection static dropdown.
  const RawStaticDropify({
    super.key,
    required this.entries,
    required this.anchorBuilder,
    this.entryBuilder,
    this.matcher,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.searchController,
    this.searchable = false,
    this.searchHintText,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.showClearButton = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.onOpen,
    this.onClose,
    this.validator,
    this.autovalidateMode,
    this.errorTextBuilder,
    this.keyOf,
    this.equals,
    this.noResultsBuilder,
  }) : selectionMode = DropifySelectionMode.single,
       initialValues = null,
       onChangedMulti = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

  /// Creates a multi-selection static dropdown.
  const RawStaticDropify.multi({
    super.key,
    required this.entries,
    required this.anchorBuilder,
    this.entryBuilder,
    this.matcher,
    this.controller,
    this.initialValues,
    ValueChanged<Set<T>>? onChanged,
    this.searchController,
    this.searchable = false,
    this.searchHintText,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.showClearButton = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.onOpen,
    this.onClose,
    this.validator,
    this.autovalidateMode,
    this.errorTextBuilder,
    this.keyOf,
    this.equals,
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
    this.noResultsBuilder,
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null,
       onChangedMulti = onChanged;

  final List<DropifyEntry<T>> entries;
  final AnchorBuilder<T> anchorBuilder;
  final DropifyEntryBuilder<T>? entryBuilder;
  final bool Function(DropifyEntry<T> entry, String query)? matcher;
  final DropifySelectionMode selectionMode;
  final DropifyController<T>? controller;
  final T? initialValue;
  final Set<T>? initialValues;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<Set<T>>? onChangedMulti;
  final TextEditingController? searchController;
  final bool searchable;
  final String? searchHintText;
  final Duration searchDebounce;
  final bool showClearButton;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;
  final FormFieldValidator<DropifyValue<T>>? validator;
  final AutovalidateMode? autovalidateMode;
  final Widget Function(BuildContext, String error)? errorTextBuilder;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;
  final WidgetBuilder? noResultsBuilder;

  @override
  Widget build(BuildContext context) {
    Widget panelBuilder(BuildContext context, DropifyPanelState<T> state) {
      final match = matcher ?? defaultDropifyMatcher<T>;
      final filtered = entries
          .where((entry) => match(entry, state.searchQuery))
          .toList(growable: false);
      if (filtered.isEmpty) {
        final theme = DropifyTheme.of(context);
        return noResultsBuilder?.call(context) ??
            theme.noResultsBuilder?.call(context) ??
            Center(child: Text(theme.noResultsText ?? 'No results'));
      }
      Widget item(BuildContext context, int index) {
        final entry = filtered[index];
        final selected = state.isSelected(entry.value);
        final onTap = entry.enabled
            ? () {
                if (state.mode == DropifySelectionMode.single) {
                  state.select(entry.value);
                } else {
                  state.toggle(entry.value);
                }
              }
            : () {};
        return Opacity(
          opacity: entry.enabled ? 1 : 0.45,
          child: IgnorePointer(
            ignoring: !entry.enabled,
            child:
                entryBuilder?.call(context, entry, selected, onTap) ??
                _DefaultEntry<T>(
                  entry: entry,
                  selected: selected,
                  onTap: onTap,
                ),
          ),
        );
      }

      if (filtered.length > 50) {
        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          itemCount: filtered.length,
          itemBuilder: item,
        );
      }
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            filtered.length,
            (index) => item(context, index),
          ),
        ),
      );
    }

    if (selectionMode == DropifySelectionMode.single) {
      return RawDropify<T>(
        panelBuilder: panelBuilder,
        anchorBuilder: anchorBuilder,
        controller: controller,
        initialValue: initialValue,
        onChanged: onChanged,
        searchController: searchController,
        searchable: searchable,
        searchHintText: searchHintText,
        searchDebounce: searchDebounce,
        showClearButton: showClearButton,
        enabled: enabled,
        autofocus: autofocus,
        focusNode: focusNode,
        onOpen: onOpen,
        onClose: onClose,
        validator: validator,
        autovalidateMode: autovalidateMode,
        errorTextBuilder: errorTextBuilder,
        keyOf: keyOf,
        equals: equals,
      );
    }
    return RawDropify<T>.multi(
      panelBuilder: panelBuilder,
      anchorBuilder: anchorBuilder,
      controller: controller,
      initialValues: initialValues,
      onChanged: onChangedMulti,
      searchController: searchController,
      searchable: searchable,
      searchHintText: searchHintText,
      searchDebounce: searchDebounce,
      showClearButton: showClearButton,
      enabled: enabled,
      autofocus: autofocus,
      focusNode: focusNode,
      onOpen: onOpen,
      onClose: onClose,
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

class _DefaultEntry<T> extends StatelessWidget {
  const _DefaultEntry({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final DropifyEntry<T> entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = DropifyTheme.of(context);
    return InkWell(
      key: ValueKey<String>(
        'dropify.item.${entry.value.toString().replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_')}',
      ),
      onTap: onTap,
      child: Padding(
        padding: theme.entryPadding ?? const EdgeInsets.all(12),
        child: Row(
          children: [
            if (entry.leading != null) entry.leading!,
            if (entry.leading != null) SizedBox(width: theme.entrySpacing ?? 8),
            Expanded(
              child: Text(
                entry.label ?? entry.value.toString(),
                style: entry.enabled
                    ? theme.entryTextStyle
                    : theme.entryDisabledTextStyle,
              ),
            ),
            if (entry.trailing != null) entry.trailing!,
            if (selected)
              Icon(
                theme.entrySelectedIcon ?? Icons.check,
                key: const ValueKey<String>('dropify.item.selectedIcon'),
              ),
          ],
        ),
      ),
    );
  }
}
