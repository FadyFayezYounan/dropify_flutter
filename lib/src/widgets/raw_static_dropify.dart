import 'package:flutter/material.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_entry.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/_default_matcher.dart';
import '../internal/_dropify_menu_scroll_shell.dart';
import '../theme/dropify_theme.dart';

/// Builds a static Dropify entry.
typedef DropifyEntryBuilder<T> =
    Widget Function(
      BuildContext context,
      DropifyEntry<T> entry,
      bool selected,
      VoidCallback? onTap,
    );

/// A raw dropdown backed by in-memory [DropifyEntry] values.
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
    this.matchAnchorWidth = true,
    this.panelConstraints,
    this.enabled = true,
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
    this.matchAnchorWidth = true,
    this.panelConstraints,
    this.enabled = true,
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
  final bool matchAnchorWidth;
  final BoxConstraints? panelConstraints;
  final bool enabled;
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
      final activeMatcher = matcher ?? defaultDropifyMatcher<T>;
      final filtered = entries
          .where((entry) => activeMatcher(entry, state.searchQuery))
          .toList(growable: false);
      if (filtered.isEmpty) {
        return (noResultsBuilder ?? DropifyTheme.of(context).noResultsBuilder)
                ?.call(context) ??
            const Center(child: Text('No results found'));
      }
      Widget buildEntry(BuildContext context, int index) {
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
            : null;
        final builder = entryBuilder ?? _defaultEntryBuilder<T>;
        return builder(context, entry, selected, onTap);
      }

      if (filtered.length > 50) {
        return DropifyMenuScrollShell(
          builder: (context, controller) => ListView.builder(
            controller: controller,
            primary: false,
            padding: EdgeInsets.zero,
            shrinkWrap: false,
            itemCount: filtered.length,
            itemBuilder: buildEntry,
          ),
        );
      }
      return DropifyMenuScrollShell(
        builder: (context, controller) => SingleChildScrollView(
          controller: controller,
          primary: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var index = 0; index < filtered.length; index++)
                buildEntry(context, index),
            ],
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
        matchAnchorWidth: matchAnchorWidth,
        panelConstraints: panelConstraints,
        enabled: enabled,
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
      matchAnchorWidth: matchAnchorWidth,
      panelConstraints: panelConstraints,
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

Widget _defaultEntryBuilder<T>(
  BuildContext context,
  DropifyEntry<T> entry,
  bool selected,
  VoidCallback? onTap,
) {
  final theme = DropifyTheme.of(context);
  final child = InkWell(
    onTap: onTap,
    child: Container(
      key: ValueKey<String>('dropify.item.${entry.value.hashCode}'),
      padding: theme.entryPadding,
      decoration: selected ? theme.entrySelectedDecoration : null,
      child: Row(
        spacing: theme.entrySpacing ?? 8,
        children: [
          if (entry.leading != null) entry.leading!,
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
              key: const ValueKey<String>('dropify.item.selectedIcon'),
              theme.entrySelectedIcon,
              size: 18,
            ),
        ],
      ),
    ),
  );
  return Semantics(
    button: true,
    selected: selected,
    enabled: entry.enabled,
    label: entry.label ?? entry.value.toString(),
    child: IgnorePointer(
      ignoring: !entry.enabled,
      child: Opacity(opacity: entry.enabled ? 1 : 0.5, child: child),
    ),
  );
}
