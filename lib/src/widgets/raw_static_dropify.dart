import 'package:flutter/material.dart';

import '../core/dropify_entry.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_controller.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/dropify_anchor_state.dart';
import '../internal/dropify_panel_state.dart';
import '../internal/_default_matcher.dart';

/// An unstyled static dropdown backed by an in-memory list of
/// [DropifyEntry] values.
class RawStaticDropify<T> extends StatelessWidget {
  /// Creates a single-selection static dropdown.
  const RawStaticDropify({
    super.key,
    required this.entries,
    required this.anchorBuilder,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.entryBuilder,
    this.matcher,
    this.searchController,
    this.searchable = false,
    this.searchHintText,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.showClearButton = false,
    this.matchAnchorWidth = true,
    this.panelConstraints,
    this.alignmentOffset = const Offset(0, 4),
    this.useRootOverlay = false,
    this.consumeOutsideTaps = false,
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
  }) : onChangedMulti = null,
       initialValues = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

  /// Creates a multi-selection static dropdown.
  const RawStaticDropify.multi({
    super.key,
    required this.entries,
    required this.anchorBuilder,
    this.controller,
    this.onChangedMulti,
    this.initialValues,
    this.entryBuilder,
    this.matcher,
    this.searchController,
    this.searchable = false,
    this.searchHintText,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.showClearButton = false,
    this.matchAnchorWidth = true,
    this.panelConstraints,
    this.alignmentOffset = const Offset(0, 4),
    this.useRootOverlay = false,
    this.consumeOutsideTaps = false,
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
  }) : initialValue = null,
       onChanged = null;

  final List<DropifyEntry<T>> entries;
  final Widget Function(
    BuildContext context,
    DropifyEntry<T> entry,
    bool selected,
  )?
  entryBuilder;
  final bool Function(DropifyEntry<T> entry, String query)? matcher;

  final DropifyController<T>? controller;
  final T? initialValue;
  final Set<T>? initialValues;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<Set<T>>? onChangedMulti;
  final AnchorBuilder<T> anchorBuilder;
  final TextEditingController? searchController;
  final bool searchable;
  final String? searchHintText;
  final Duration searchDebounce;
  final bool showClearButton;
  final bool matchAnchorWidth;
  final BoxConstraints? panelConstraints;
  final Offset alignmentOffset;
  final bool useRootOverlay;
  final bool consumeOutsideTaps;
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

  bool get _isMulti =>
      onChangedMulti != null || initialValues != null || confirmable;

  Widget _buildPanel(BuildContext context, DropifyPanelState<T> state) {
    final effectiveMatcher = matcher ?? defaultMatcher;
    final query = state.searchQuery;
    final filtered = query.isEmpty
        ? entries
        : entries.where((e) => effectiveMatcher(e, query)).toList();

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No results')),
      );
    }

    final effectiveEntryBuilder = entryBuilder ?? _defaultEntryBuilder;

    if (filtered.length > 50) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final entry = filtered[index];
          return _EntryTile<T>(
            entry: entry,
            selected: state.isSelected(entry.value),
            builder: effectiveEntryBuilder,
            onTap: () {
              if (!entry.enabled) {
                return;
              }
              if (state.mode == DropifySelectionMode.single) {
                state.select(entry.value);
              } else {
                state.toggle(entry.value);
              }
            },
          );
        },
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: filtered
            .map(
              (entry) => _EntryTile<T>(
                entry: entry,
                selected: state.isSelected(entry.value),
                builder: effectiveEntryBuilder,
                onTap: () {
                  if (!entry.enabled) {
                    return;
                  }
                  if (state.mode == DropifySelectionMode.single) {
                    state.select(entry.value);
                  } else {
                    state.toggle(entry.value);
                  }
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _defaultEntryBuilder(
    BuildContext context,
    DropifyEntry<T> entry,
    bool selected,
  ) {
    return InkWell(
      onTap: null,
      child: Opacity(
        opacity: entry.enabled ? 1.0 : 0.38,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              if (entry.leading != null) ...[
                entry.leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  entry.label ?? entry.value.toString(),
                  style: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check, size: 18),
                ),
              if (entry.trailing != null) ...[
                const SizedBox(width: 12),
                entry.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isMulti) {
      return RawDropify<T>.multi(
        panelBuilder: _buildPanel,
        anchorBuilder: anchorBuilder,
        controller: controller,
        initialValues: initialValues,
        onChangedMulti: onChangedMulti,
        searchController: searchController,
        searchable: searchable,
        searchHintText: searchHintText,
        searchDebounce: searchDebounce,
        showClearButton: showClearButton,
        matchAnchorWidth: matchAnchorWidth,
        panelConstraints: panelConstraints,
        alignmentOffset: alignmentOffset,
        useRootOverlay: useRootOverlay,
        consumeOutsideTaps: consumeOutsideTaps,
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

    return RawDropify<T>(
      panelBuilder: _buildPanel,
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
      alignmentOffset: alignmentOffset,
      useRootOverlay: useRootOverlay,
      consumeOutsideTaps: consumeOutsideTaps,
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
}

class _EntryTile<T> extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.selected,
    required this.builder,
    required this.onTap,
  });

  final DropifyEntry<T> entry;
  final bool selected;
  final Widget Function(BuildContext, DropifyEntry<T>, bool) builder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: Key('dropify.item.${entry.value}'),
      button: true,
      selected: selected,
      enabled: entry.enabled,
      label: entry.label ?? entry.value.toString(),
      child: IgnorePointer(
        ignoring: !entry.enabled,
        child: GestureDetector(
          onTap: onTap,
          child: builder(context, entry, selected),
        ),
      ),
    );
  }
}
