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
///
/// The [onTap] callback is null when the entry is disabled.
typedef DropifyEntryBuilder<T> =
    Widget Function(
      BuildContext context,
      DropifyEntry<T> entry,
      bool selected,
      VoidCallback? onTap,
    );

/// A raw dropdown backed by in-memory [DropifyEntry] values.
///
/// This widget adds static entry filtering, disabled entry handling, empty
/// state rendering, and large-list presentation to [RawDropify]. It does not
/// provide a Material-styled anchor; callers provide [anchorBuilder].
class RawStaticDropify<T> extends StatelessWidget {
  /// Creates a single-selection static dropdown.
  ///
  /// The [entries] and [anchorBuilder] arguments are required.
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
  ///
  /// When [confirmable] is false, toggles are emitted immediately. When
  /// [confirmable] is true, toggles are staged until the user applies them.
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

  /// The in-memory entries shown by the dropdown.
  final List<DropifyEntry<T>> entries;

  /// Builds the closed anchor.
  final AnchorBuilder<T> anchorBuilder;

  /// Builds each filtered entry row.
  ///
  /// If null, a default row using [DropifyTheme] values is used.
  final DropifyEntryBuilder<T>? entryBuilder;

  /// Returns whether [entry] matches the current search query.
  ///
  /// If null, Dropify performs a case-insensitive contains match over the
  /// entry's effective search text.
  final bool Function(DropifyEntry<T> entry, String query)? matcher;

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

  /// Optional search text controller owned by the caller.
  final TextEditingController? searchController;

  /// Whether the panel includes a search field.
  final bool searchable;

  /// Hint text for the search field.
  final String? searchHintText;

  /// Debounce duration passed through to [RawDropify].
  final Duration searchDebounce;

  /// Whether a clear button is shown when a value is selected.
  final bool showClearButton;

  /// Whether the panel width matches the anchor width.
  final bool matchAnchorWidth;

  /// Additional constraints for the dropdown panel.
  final BoxConstraints? panelConstraints;

  /// Whether the dropdown accepts user interaction.
  final bool enabled;

  /// Validates the current Dropify value when used inside a [Form].
  final FormFieldValidator<DropifyValue<T>>? validator;

  /// Controls when validation runs.
  final AutovalidateMode? autovalidateMode;

  /// Builds validation error text.
  final Widget Function(BuildContext, String error)? errorTextBuilder;

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

  /// Builds the state shown when filtering produces no entries.
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
