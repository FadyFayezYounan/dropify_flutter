import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_entry.dart';
import '../core/dropify_menu_body_mode.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/_default_matcher.dart';
import '../internal/_dropify_menu_item_button.dart';
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
    this.menuBodyMode = DropifyMenuBodyMode.automatic,
    this.scrollToSelectedOnOpen = true,
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
    this.menuBodyMode = DropifyMenuBodyMode.automatic,
    this.scrollToSelectedOnOpen = true,
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

  /// Controls whether non-empty row bodies are eager or lazy.
  ///
  /// Defaults to [DropifyMenuBodyMode.automatic]. Paginated dropdowns do not use
  /// this setting.
  final DropifyMenuBodyMode menuBodyMode;

  /// Whether opening the menu should jump to the selected visible row.
  ///
  /// Defaults to true. If the selected value is not present in the current
  /// visible rows, opening preserves normal initial scroll offset behavior.
  final bool scrollToSelectedOnOpen;

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
      final useLazyRows = switch (menuBodyMode) {
        DropifyMenuBodyMode.automatic => filtered.length > 50,
        DropifyMenuBodyMode.eagerColumn => false,
        DropifyMenuBodyMode.lazyIndexed => true,
      };

      if (useLazyRows) {
        return DropifyMenuScrollShell.indexed(
          indexedBuilder: (context, controller, listController) {
            return _StaticLazyRowsView<T>(
              entries: filtered,
              panelState: state,
              entryBuilder: entryBuilder,
              keyOf: keyOf,
              equals: equals,
              scrollController: controller,
              listController: listController,
              scrollToSelectedOnOpen: scrollToSelectedOnOpen,
            );
          },
        );
      }
      return DropifyMenuScrollShell(
        builder: (context, controller) => _StaticEagerRowsView<T>(
          entries: filtered,
          panelState: state,
          entryBuilder: entryBuilder,
          keyOf: keyOf,
          equals: equals,
          scrollController: controller,
          scrollToSelectedOnOpen: scrollToSelectedOnOpen,
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

class _StaticEagerRowsView<T> extends StatefulWidget {
  const _StaticEagerRowsView({
    required this.entries,
    required this.panelState,
    required this.scrollController,
    required this.scrollToSelectedOnOpen,
    this.entryBuilder,
    this.keyOf,
    this.equals,
  });

  final List<DropifyEntry<T>> entries;
  final DropifyPanelState<T> panelState;
  final ScrollController scrollController;
  final bool scrollToSelectedOnOpen;
  final DropifyEntryBuilder<T>? entryBuilder;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;

  @override
  State<_StaticEagerRowsView<T>> createState() =>
      _StaticEagerRowsViewState<T>();
}

class _StaticEagerRowsViewState<T> extends State<_StaticEagerRowsView<T>> {
  final List<GlobalKey> _rowKeys = <GlobalKey>[];
  int _scheduledGeneration = 0;
  int? _lastScheduledTarget;

  @override
  void initState() {
    super.initState();
    _scheduleSelectedJump();
  }

  @override
  void didUpdateWidget(covariant _StaticEagerRowsView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncRowKeys();
    _scheduleSelectedJump();
  }

  @override
  Widget build(BuildContext context) {
    _syncRowKeys();
    return SingleChildScrollView(
      controller: widget.scrollController,
      primary: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < widget.entries.length; index++)
            KeyedSubtree(
              key: _rowKeys[index],
              child: _buildStaticEntry<T>(
                context,
                entry: widget.entries[index],
                state: widget.panelState,
                entryBuilder: widget.entryBuilder,
                keyOf: widget.keyOf,
              ),
            ),
        ],
      ),
    );
  }

  void _syncRowKeys() {
    if (_rowKeys.length == widget.entries.length) {
      return;
    }
    if (_rowKeys.length > widget.entries.length) {
      _rowKeys.removeRange(widget.entries.length, _rowKeys.length);
      return;
    }
    _rowKeys.addAll(
      List<GlobalKey>.generate(
        widget.entries.length - _rowKeys.length,
        (_) => GlobalKey(),
      ),
    );
  }

  void _scheduleSelectedJump() {
    if (!widget.scrollToSelectedOnOpen) {
      return;
    }
    final targetIndex = _selectedStaticIndex<T>(
      entries: widget.entries,
      panelState: widget.panelState,
      keyOf: widget.keyOf,
      equals: widget.equals,
    );
    if (targetIndex == null || targetIndex == _lastScheduledTarget) {
      return;
    }
    _lastScheduledTarget = targetIndex;
    final generation = ++_scheduledGeneration;
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _jumpToSelected(generation, targetIndex, canRetry: true),
      debugLabel: 'Dropify.staticEagerScrollToSelected',
    );
  }

  void _jumpToSelected(
    int generation,
    int targetIndex, {
    required bool canRetry,
  }) {
    if (!mounted || generation != _scheduledGeneration) {
      return;
    }
    if (targetIndex < 0 || targetIndex >= widget.entries.length) {
      return;
    }
    final currentTargetIndex = _selectedStaticIndex<T>(
      entries: widget.entries,
      panelState: widget.panelState,
      keyOf: widget.keyOf,
      equals: widget.equals,
    );
    if (currentTargetIndex != targetIndex) {
      return;
    }
    final rowContext = _rowKeys[targetIndex].currentContext;
    if (rowContext == null || !widget.scrollController.hasClients) {
      if (canRetry) {
        SchedulerBinding.instance.addPostFrameCallback(
          (_) => _jumpToSelected(generation, targetIndex, canRetry: false),
          debugLabel: 'Dropify.staticEagerScrollToSelected.retry',
        );
      }
      return;
    }
    unawaited(
      Scrollable.ensureVisible(
        rowContext,
        duration: Duration.zero,
        alignment: 0.1,
      ),
    );
  }
}

class _StaticLazyRowsView<T> extends StatefulWidget {
  const _StaticLazyRowsView({
    required this.entries,
    required this.panelState,
    required this.scrollController,
    required this.listController,
    required this.scrollToSelectedOnOpen,
    this.entryBuilder,
    this.keyOf,
    this.equals,
  });

  final List<DropifyEntry<T>> entries;
  final DropifyPanelState<T> panelState;
  final ScrollController scrollController;
  final ListController listController;
  final bool scrollToSelectedOnOpen;
  final DropifyEntryBuilder<T>? entryBuilder;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;

  @override
  State<_StaticLazyRowsView<T>> createState() => _StaticLazyRowsViewState<T>();
}

class _StaticLazyRowsViewState<T> extends State<_StaticLazyRowsView<T>> {
  int _scheduledGeneration = 0;
  int? _lastScheduledTarget;

  @override
  void initState() {
    super.initState();
    _scheduleSelectedJump();
  }

  @override
  void didUpdateWidget(covariant _StaticLazyRowsView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _scheduleSelectedJump();
  }

  @override
  Widget build(BuildContext context) {
    return SuperListView.builder(
      controller: widget.scrollController,
      listController: widget.listController,
      primary: false,
      padding: EdgeInsets.zero,
      shrinkWrap: false,
      itemCount: widget.entries.length,
      itemBuilder: (context, index) {
        return _buildStaticEntry<T>(
          context,
          entry: widget.entries[index],
          state: widget.panelState,
          entryBuilder: widget.entryBuilder,
          keyOf: widget.keyOf,
        );
      },
    );
  }

  void _scheduleSelectedJump() {
    if (!widget.scrollToSelectedOnOpen) {
      return;
    }
    final targetIndex = _selectedIndex();
    if (targetIndex == null || targetIndex == _lastScheduledTarget) {
      return;
    }
    _lastScheduledTarget = targetIndex;
    final generation = ++_scheduledGeneration;
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _jumpToSelected(generation, targetIndex, canRetry: true),
      debugLabel: 'Dropify.staticScrollToSelected',
    );
  }

  void _jumpToSelected(
    int generation,
    int targetIndex, {
    required bool canRetry,
  }) {
    if (!mounted || generation != _scheduledGeneration) {
      return;
    }
    if (targetIndex < 0 || targetIndex >= widget.entries.length) {
      return;
    }
    if (_selectedIndex() != targetIndex) {
      return;
    }
    if (!widget.scrollController.hasClients ||
        !widget.listController.isAttached) {
      if (canRetry) {
        SchedulerBinding.instance.addPostFrameCallback(
          (_) => _jumpToSelected(generation, targetIndex, canRetry: false),
          debugLabel: 'Dropify.staticScrollToSelected.retry',
        );
      }
      return;
    }
    final visibleRange = widget.listController.visibleRange;
    if (visibleRange != null &&
        targetIndex >= visibleRange.$1 &&
        targetIndex <= visibleRange.$2) {
      return;
    }
    widget.listController.jumpToItem(
      index: targetIndex,
      scrollController: widget.scrollController,
      alignment: 0.1,
    );
  }

  int? _selectedIndex() {
    return _selectedStaticIndex<T>(
      entries: widget.entries,
      panelState: widget.panelState,
      keyOf: widget.keyOf,
      equals: widget.equals,
    );
  }
}

int? _selectedStaticIndex<T>({
  required List<DropifyEntry<T>> entries,
  required DropifyPanelState<T> panelState,
  required Object Function(T item)? keyOf,
  required bool Function(T a, T b)? equals,
}) {
  final identity = DropifySelectionIdentity<T>(keyOf: keyOf, equals: equals);
  switch (panelState.mode) {
    case DropifySelectionMode.single:
      final selected = panelState.value;
      if (selected == null) {
        return null;
      }
      for (var index = 0; index < entries.length; index++) {
        if (identity.same(selected, entries[index].value)) {
          return index;
        }
      }
    case DropifySelectionMode.multi:
      if (panelState.values.isEmpty) {
        return null;
      }
      for (var index = 0; index < entries.length; index++) {
        if (identity.contains(panelState.values, entries[index].value)) {
          return index;
        }
      }
  }
  return null;
}

Widget _buildStaticEntry<T>(
  BuildContext context, {
  required DropifyEntry<T> entry,
  required DropifyPanelState<T> state,
  required DropifyEntryBuilder<T>? entryBuilder,
  required Object Function(T item)? keyOf,
}) {
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
  final builder = entryBuilder;
  if (builder != null) {
    return builder(context, entry, selected, onTap);
  }
  final label = entry.label ?? entry.value.toString();
  return DropifyMenuItemButton(
    itemKey: dropifyMenuItemKey(keyOf?.call(entry.value), entry.value),
    semanticsLabel: label,
    selected: selected,
    leadingIcon: entry.leading,
    trailingIcon: entry.trailing,
    onPressed: onTap,
    child: Text(label),
  );
}
