import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

import '../core/dropify_cancel_token.dart';
import '../core/dropify_controller.dart';
import '../core/dropify_menu_body_mode.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/_debouncer.dart';
import '../internal/_dropify_menu_scroll_shell.dart';
import '../theme/dropify_theme.dart';

/// Fetches async Dropify items for [query].
///
/// The [cancel] token is cancelled when a replacement request starts or when
/// the widget is disposed. Fetchers should avoid committing expensive work after
/// cancellation.
typedef DropifyAsyncFetcher<T> =
    Future<List<T>> Function(
      String query, {
      required DropifyCancelToken cancel,
    });

/// Builds async Dropify items.
///
/// The [onTap] callback selects or toggles the item according to the active
/// selection mode.
typedef DropifyAsyncItemBuilder<T> =
    Widget Function(
      BuildContext context,
      T item,
      bool selected,
      VoidCallback onTap,
    );

/// The loading state for an async Dropify dropdown.
sealed class DropifyAsyncState<T> {
  const DropifyAsyncState();
}

/// No async request has started.
final class DropifyAsyncIdle<T> extends DropifyAsyncState<T> {
  const DropifyAsyncIdle();
}

/// Initial async request is loading.
final class DropifyAsyncLoading<T> extends DropifyAsyncState<T> {
  const DropifyAsyncLoading();
}

/// A refresh is loading while [staleItems] remain visible.
final class DropifyAsyncRefreshing<T> extends DropifyAsyncState<T> {
  /// Creates a refreshing state with stale visible items.
  const DropifyAsyncRefreshing(this.staleItems);

  /// Items from the previous successful request.
  final List<T> staleItems;
}

/// Async data loaded successfully.
final class DropifyAsyncData<T> extends DropifyAsyncState<T> {
  /// Creates a successful async data state.
  const DropifyAsyncData(this.items);

  /// The items returned by the latest successful request.
  final List<T> items;
}

/// Async data loaded with no items.
final class DropifyAsyncEmpty<T> extends DropifyAsyncState<T> {
  /// Creates an empty async state.
  ///
  /// The [hasQuery] argument is true when the empty result came from a non-empty
  /// search query.
  const DropifyAsyncEmpty({required this.hasQuery});

  /// Whether the empty result belongs to a non-empty search query.
  final bool hasQuery;
}

/// Async data failed to load.
final class DropifyAsyncError<T> extends DropifyAsyncState<T> {
  /// Creates an async error state.
  const DropifyAsyncError(this.error, this.stackTrace);

  /// The error thrown by the latest request.
  final Object error;

  /// The stack trace associated with [error], if available.
  final StackTrace? stackTrace;
}

/// A raw dropdown backed by an async search fetcher.
///
/// This widget adds debounced fetching, cancellation, stale-result protection,
/// retry, per-instance caching, and async state-slot builders to [RawDropify].
/// It does not provide a Material-styled anchor; callers provide
/// [anchorBuilder].
class RawAsyncDropify<T> extends StatefulWidget {
  /// Creates a single-selection async dropdown.
  ///
  /// The [fetcher], [anchorBuilder], and [itemBuilder] arguments are required.
  const RawAsyncDropify({
    super.key,
    required this.fetcher,
    required this.anchorBuilder,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.searchController,
    this.searchable = true,
    this.searchHintText,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.showClearButton = false,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.keyOf,
    this.equals,
    this.loadOnOpen = true,
    this.cacheItems = true,
    this.menuBodyMode = DropifyMenuBodyMode.automatic,
    this.scrollToSelectedOnOpen = true,
  }) : selectionMode = DropifySelectionMode.single,
       initialValues = null,
       onChangedMulti = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

  /// Creates a multi-selection async dropdown.
  ///
  /// When [confirmable] is false, toggles are emitted immediately. When
  /// [confirmable] is true, toggles are staged until the user applies them.
  const RawAsyncDropify.multi({
    super.key,
    required this.fetcher,
    required this.anchorBuilder,
    required this.itemBuilder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.controller,
    this.initialValues,
    ValueChanged<Set<T>>? onChanged,
    this.searchController,
    this.searchable = true,
    this.searchHintText,
    this.searchDebounce = const Duration(milliseconds: 300),
    this.showClearButton = false,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.keyOf,
    this.equals,
    this.loadOnOpen = true,
    this.cacheItems = true,
    this.menuBodyMode = DropifyMenuBodyMode.automatic,
    this.scrollToSelectedOnOpen = true,
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null,
       onChangedMulti = onChanged;

  /// Fetches items for the current search query.
  final DropifyAsyncFetcher<T> fetcher;

  /// Builds the closed anchor.
  final AnchorBuilder<T> anchorBuilder;

  /// Builds each loaded item row.
  final DropifyAsyncItemBuilder<T> itemBuilder;

  /// Builds the initial loading state.
  final WidgetBuilder? loadingBuilder;

  /// Builds an error state with a retry callback.
  final Widget Function(BuildContext, Object error, VoidCallback retry)?
  errorBuilder;

  /// Builds the empty state.
  ///
  /// The boolean argument is true when the current query is not empty.
  final Widget Function(BuildContext, bool hasQuery)? emptyBuilder;

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
  ///
  /// Defaults to true.
  final bool searchable;

  /// Hint text for the search field.
  final String? searchHintText;

  /// The debounce duration before running [fetcher].
  ///
  /// Defaults to 300 milliseconds.
  final Duration searchDebounce;

  /// Whether a clear button is shown when a value is selected.
  final bool showClearButton;

  /// Whether the dropdown accepts user interaction.
  final bool enabled;

  /// Validates the current Dropify value when used inside a [Form].
  final FormFieldValidator<DropifyValue<T>>? validator;

  /// Controls when validation runs.
  final AutovalidateMode? autovalidateMode;

  /// Returns a stable identity key for a value.
  final Object Function(T item)? keyOf;

  /// Compares two values for selection identity.
  final bool Function(T a, T b)? equals;

  /// Whether the first request starts when the panel opens.
  ///
  /// Defaults to true.
  final bool loadOnOpen;

  /// Whether fetched items are cached for this widget instance.
  ///
  /// Defaults to true.
  final bool cacheItems;

  /// Controls whether loaded row bodies are eager or lazy.
  ///
  /// Defaults to [DropifyMenuBodyMode.automatic], which uses lazy indexed rows
  /// for async loaded and refreshing data. Paginated dropdowns do not use this
  /// setting.
  final DropifyMenuBodyMode menuBodyMode;

  /// Whether opening the menu should jump to the selected visible row.
  ///
  /// Defaults to true. Async dropdowns only inspect currently rendered loaded or
  /// refreshing rows and never fetch extra items to find a selection.
  final bool scrollToSelectedOnOpen;

  /// Whether multi-selection changes are staged until applied.
  final bool confirmable;

  /// The label for the confirm button in confirmable multi-selection.
  final String? confirmLabel;

  /// The label for the cancel button in confirmable multi-selection.
  final String? cancelLabel;

  @override
  State<RawAsyncDropify<T>> createState() => _RawAsyncDropifyState<T>();
}

class _RawAsyncDropifyState<T> extends State<RawAsyncDropify<T>> {
  final Map<String, List<T>> _cache = <String, List<T>>{};

  @override
  void dispose() {
    _cache.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget panelBuilder(BuildContext context, DropifyPanelState<T> state) {
      return _AsyncDropifyBody<T>(
        query: state.searchQuery,
        fetcher: widget.fetcher,
        itemBuilder: widget.itemBuilder,
        state: state,
        loadingBuilder: widget.loadingBuilder,
        errorBuilder: widget.errorBuilder,
        emptyBuilder: widget.emptyBuilder,
        cache: _cache,
        cacheItems: widget.cacheItems,
        loadOnOpen: widget.loadOnOpen,
        debounce: widget.searchDebounce,
        menuBodyMode: widget.menuBodyMode,
        scrollToSelectedOnOpen: widget.scrollToSelectedOnOpen,
        keyOf: widget.keyOf,
        equals: widget.equals,
      );
    }

    if (widget.selectionMode == DropifySelectionMode.single) {
      return RawDropify<T>(
        panelBuilder: panelBuilder,
        anchorBuilder: widget.anchorBuilder,
        controller: widget.controller,
        initialValue: widget.initialValue,
        onChanged: widget.onChanged,
        searchController: widget.searchController,
        searchable: widget.searchable,
        searchHintText: widget.searchHintText,
        searchDebounce: widget.searchDebounce,
        showClearButton: widget.showClearButton,
        enabled: widget.enabled,
        validator: widget.validator,
        autovalidateMode: widget.autovalidateMode,
        keyOf: widget.keyOf,
        equals: widget.equals,
      );
    }
    return RawDropify<T>.multi(
      panelBuilder: panelBuilder,
      anchorBuilder: widget.anchorBuilder,
      controller: widget.controller,
      initialValues: widget.initialValues,
      onChanged: widget.onChangedMulti,
      searchController: widget.searchController,
      searchable: widget.searchable,
      searchHintText: widget.searchHintText,
      searchDebounce: widget.searchDebounce,
      showClearButton: widget.showClearButton,
      enabled: widget.enabled,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      keyOf: widget.keyOf,
      equals: widget.equals,
      confirmable: widget.confirmable,
      confirmLabel: widget.confirmLabel,
      cancelLabel: widget.cancelLabel,
    );
  }
}

class _AsyncDropifyBody<T> extends StatefulWidget {
  const _AsyncDropifyBody({
    required this.query,
    required this.fetcher,
    required this.itemBuilder,
    required this.state,
    required this.cache,
    required this.cacheItems,
    required this.loadOnOpen,
    required this.debounce,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.menuBodyMode = DropifyMenuBodyMode.automatic,
    this.scrollToSelectedOnOpen = true,
    this.keyOf,
    this.equals,
  });

  final String query;
  final DropifyAsyncFetcher<T> fetcher;
  final DropifyAsyncItemBuilder<T> itemBuilder;
  final DropifyPanelState<T> state;
  final Map<String, List<T>> cache;
  final bool cacheItems;
  final bool loadOnOpen;
  final Duration debounce;
  final DropifyMenuBodyMode menuBodyMode;
  final bool scrollToSelectedOnOpen;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)? errorBuilder;
  final Widget Function(BuildContext, bool)? emptyBuilder;

  @override
  State<_AsyncDropifyBody<T>> createState() => _AsyncDropifyBodyState<T>();
}

class _AsyncDropifyBodyState<T> extends State<_AsyncDropifyBody<T>> {
  late DropifyDebouncer _debouncer;
  DropifyAsyncState<T> _asyncState = DropifyAsyncIdle<T>();
  DropifyCancelToken? _token;
  int _generation = 0;
  int _renderedRowsGeneration = 0;

  @override
  void initState() {
    super.initState();
    _debouncer = DropifyDebouncer(widget.debounce);
    if (widget.loadOnOpen) {
      _load(widget.query, immediate: true);
    }
  }

  @override
  void didUpdateWidget(covariant _AsyncDropifyBody<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.debounce != widget.debounce) {
      _debouncer.dispose();
      _debouncer = DropifyDebouncer(widget.debounce);
    }
    if (oldWidget.query != widget.query) {
      _load(widget.query);
    }
  }

  @override
  void dispose() {
    _token?.cancel();
    _debouncer.dispose();
    super.dispose();
  }

  void _load(String query, {bool immediate = false}) {
    void run() {
      final cached = widget.cacheItems ? widget.cache[query] : null;
      if (cached != null) {
        setState(() {
          _renderedRowsGeneration += 1;
          _asyncState = DropifyAsyncData<T>(cached);
        });
        return;
      }
      unawaited(_fetch(query));
    }

    if (immediate) {
      run();
    } else {
      _debouncer(run);
    }
  }

  Future<void> _fetch(String query) async {
    final generation = ++_generation;
    _token?.cancel();
    final token = DropifyCancelToken();
    _token = token;
    final staleItems = switch (_asyncState) {
      DropifyAsyncData<T>(:final items) => items,
      DropifyAsyncRefreshing<T>(:final staleItems) => staleItems,
      _ => null,
    };
    setState(() {
      if (staleItems == null) {
        _asyncState = DropifyAsyncLoading<T>();
      } else {
        _renderedRowsGeneration += 1;
        _asyncState = DropifyAsyncRefreshing<T>(staleItems);
      }
    });
    try {
      final items = await widget.fetcher(query, cancel: token);
      if (!mounted || token.isCancelled || generation != _generation) {
        return;
      }
      if (widget.cacheItems) {
        widget.cache[query] = List<T>.unmodifiable(items);
      }
      setState(() {
        if (items.isEmpty) {
          _asyncState = DropifyAsyncEmpty<T>(hasQuery: query.trim().isNotEmpty);
        } else {
          _renderedRowsGeneration += 1;
          _asyncState = DropifyAsyncData<T>(items);
        }
      });
    } catch (error, stackTrace) {
      if (!mounted || token.isCancelled || generation != _generation) {
        return;
      }
      setState(() => _asyncState = DropifyAsyncError<T>(error, stackTrace));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DropifyTheme.of(context);
    return switch (_asyncState) {
      DropifyAsyncIdle<T>() => const SizedBox.shrink(),
      DropifyAsyncLoading<T>() =>
        (widget.loadingBuilder ?? theme.loadingBuilder)?.call(context) ??
            const Center(child: CircularProgressIndicator()),
      DropifyAsyncRefreshing<T>(:final staleItems) => Stack(
        children: [
          _ItemsList<T>(
            items: staleItems,
            state: widget.state,
            itemBuilder: widget.itemBuilder,
            menuBodyMode: widget.menuBodyMode,
            scrollToSelectedOnOpen: widget.scrollToSelectedOnOpen,
            keyOf: widget.keyOf,
            equals: widget.equals,
            rowsGeneration: _renderedRowsGeneration,
          ),
          const Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox.square(
                key: ValueKey<String>('dropify.async.refreshing'),
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ],
      ),
      DropifyAsyncData<T>(:final items) => _ItemsList<T>(
        items: items,
        state: widget.state,
        itemBuilder: widget.itemBuilder,
        menuBodyMode: widget.menuBodyMode,
        scrollToSelectedOnOpen: widget.scrollToSelectedOnOpen,
        keyOf: widget.keyOf,
        equals: widget.equals,
        rowsGeneration: _renderedRowsGeneration,
      ),
      DropifyAsyncEmpty<T>(:final hasQuery) =>
        (widget.emptyBuilder ?? theme.emptyBuilder)?.call(context, hasQuery) ??
            const Center(child: Text('No results found')),
      DropifyAsyncError<T>(:final error) =>
        (widget.errorBuilder ?? theme.errorBuilder)?.call(
              context,
              error,
              () => _load(widget.query, immediate: true),
            ) ??
            Center(child: Text(error.toString())),
    };
  }
}

class _ItemsList<T> extends StatelessWidget {
  const _ItemsList({
    required this.items,
    required this.state,
    required this.itemBuilder,
    required this.menuBodyMode,
    required this.scrollToSelectedOnOpen,
    required this.rowsGeneration,
    this.keyOf,
    this.equals,
  });

  final List<T> items;
  final DropifyPanelState<T> state;
  final DropifyAsyncItemBuilder<T> itemBuilder;
  final DropifyMenuBodyMode menuBodyMode;
  final bool scrollToSelectedOnOpen;
  final int rowsGeneration;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;

  @override
  Widget build(BuildContext context) {
    final useLazyRows = switch (menuBodyMode) {
      DropifyMenuBodyMode.automatic || DropifyMenuBodyMode.lazyIndexed => true,
      DropifyMenuBodyMode.eagerColumn => false,
    };

    if (useLazyRows) {
      return DropifyMenuScrollShell.indexed(
        indexedBuilder: (context, controller, listController) {
          return _AsyncLazyRowsView<T>(
            items: items,
            panelState: state,
            itemBuilder: itemBuilder,
            keyOf: keyOf,
            equals: equals,
            scrollController: controller,
            listController: listController,
            scrollToSelectedOnOpen: scrollToSelectedOnOpen,
            rowsGeneration: rowsGeneration,
          );
        },
      );
    }

    return DropifyMenuScrollShell(
      builder: (context, controller) => _AsyncEagerRowsView<T>(
        items: items,
        panelState: state,
        itemBuilder: itemBuilder,
        keyOf: keyOf,
        equals: equals,
        scrollController: controller,
        scrollToSelectedOnOpen: scrollToSelectedOnOpen,
        rowsGeneration: rowsGeneration,
      ),
    );
  }
}

class _AsyncEagerRowsView<T> extends StatefulWidget {
  const _AsyncEagerRowsView({
    required this.items,
    required this.panelState,
    required this.itemBuilder,
    required this.scrollController,
    required this.scrollToSelectedOnOpen,
    required this.rowsGeneration,
    this.keyOf,
    this.equals,
  });

  final List<T> items;
  final DropifyPanelState<T> panelState;
  final DropifyAsyncItemBuilder<T> itemBuilder;
  final ScrollController scrollController;
  final bool scrollToSelectedOnOpen;
  final int rowsGeneration;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;

  @override
  State<_AsyncEagerRowsView<T>> createState() => _AsyncEagerRowsViewState<T>();
}

class _AsyncEagerRowsViewState<T> extends State<_AsyncEagerRowsView<T>> {
  final List<GlobalKey> _rowKeys = <GlobalKey>[];
  int _scheduledGeneration = 0;
  int? _lastScheduledTarget;
  int? _lastScheduledRowsGeneration;

  @override
  void initState() {
    super.initState();
    _scheduleSelectedJump();
  }

  @override
  void didUpdateWidget(covariant _AsyncEagerRowsView<T> oldWidget) {
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
          for (var index = 0; index < widget.items.length; index++)
            KeyedSubtree(
              key: _rowKeys[index],
              child: _buildAsyncItem<T>(
                context,
                item: widget.items[index],
                panelState: widget.panelState,
                itemBuilder: widget.itemBuilder,
              ),
            ),
        ],
      ),
    );
  }

  void _syncRowKeys() {
    if (_rowKeys.length == widget.items.length) {
      return;
    }
    if (_rowKeys.length > widget.items.length) {
      _rowKeys.removeRange(widget.items.length, _rowKeys.length);
      return;
    }
    _rowKeys.addAll(
      List<GlobalKey>.generate(
        widget.items.length - _rowKeys.length,
        (_) => GlobalKey(),
      ),
    );
  }

  void _scheduleSelectedJump() {
    if (!widget.scrollToSelectedOnOpen) {
      return;
    }
    final targetIndex = _selectedAsyncIndex<T>(
      items: widget.items,
      panelState: widget.panelState,
      keyOf: widget.keyOf,
      equals: widget.equals,
    );
    if (targetIndex == null ||
        (targetIndex == _lastScheduledTarget &&
            widget.rowsGeneration == _lastScheduledRowsGeneration)) {
      return;
    }
    _lastScheduledTarget = targetIndex;
    _lastScheduledRowsGeneration = widget.rowsGeneration;
    final generation = ++_scheduledGeneration;
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _jumpToSelected(generation, targetIndex, canRetry: true),
      debugLabel: 'Dropify.asyncEagerScrollToSelected',
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
    if (targetIndex < 0 || targetIndex >= widget.items.length) {
      return;
    }
    final currentTargetIndex = _selectedAsyncIndex<T>(
      items: widget.items,
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
          debugLabel: 'Dropify.asyncEagerScrollToSelected.retry',
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

class _AsyncLazyRowsView<T> extends StatefulWidget {
  const _AsyncLazyRowsView({
    required this.items,
    required this.panelState,
    required this.itemBuilder,
    required this.scrollController,
    required this.listController,
    required this.scrollToSelectedOnOpen,
    required this.rowsGeneration,
    this.keyOf,
    this.equals,
  });

  final List<T> items;
  final DropifyPanelState<T> panelState;
  final DropifyAsyncItemBuilder<T> itemBuilder;
  final ScrollController scrollController;
  final ListController listController;
  final bool scrollToSelectedOnOpen;
  final int rowsGeneration;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;

  @override
  State<_AsyncLazyRowsView<T>> createState() => _AsyncLazyRowsViewState<T>();
}

class _AsyncLazyRowsViewState<T> extends State<_AsyncLazyRowsView<T>> {
  int _scheduledGeneration = 0;
  int? _lastScheduledTarget;
  int? _lastScheduledRowsGeneration;

  @override
  void initState() {
    super.initState();
    _scheduleSelectedJump();
  }

  @override
  void didUpdateWidget(covariant _AsyncLazyRowsView<T> oldWidget) {
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
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _buildAsyncItem<T>(
          context,
          item: widget.items[index],
          panelState: widget.panelState,
          itemBuilder: widget.itemBuilder,
        );
      },
    );
  }

  void _scheduleSelectedJump() {
    if (!widget.scrollToSelectedOnOpen) {
      return;
    }
    final targetIndex = _selectedAsyncIndex<T>(
      items: widget.items,
      panelState: widget.panelState,
      keyOf: widget.keyOf,
      equals: widget.equals,
    );
    if (targetIndex == null ||
        (targetIndex == _lastScheduledTarget &&
            widget.rowsGeneration == _lastScheduledRowsGeneration)) {
      return;
    }
    _lastScheduledTarget = targetIndex;
    _lastScheduledRowsGeneration = widget.rowsGeneration;
    final generation = ++_scheduledGeneration;
    SchedulerBinding.instance.addPostFrameCallback(
      (_) => _jumpToSelected(generation, targetIndex, canRetry: true),
      debugLabel: 'Dropify.asyncScrollToSelected',
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
    if (targetIndex < 0 || targetIndex >= widget.items.length) {
      return;
    }
    final currentTargetIndex = _selectedAsyncIndex<T>(
      items: widget.items,
      panelState: widget.panelState,
      keyOf: widget.keyOf,
      equals: widget.equals,
    );
    if (currentTargetIndex != targetIndex) {
      return;
    }
    if (!widget.scrollController.hasClients ||
        !widget.listController.isAttached) {
      if (canRetry) {
        SchedulerBinding.instance.addPostFrameCallback(
          (_) => _jumpToSelected(generation, targetIndex, canRetry: false),
          debugLabel: 'Dropify.asyncScrollToSelected.retry',
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
}

Widget _buildAsyncItem<T>(
  BuildContext context, {
  required T item,
  required DropifyPanelState<T> panelState,
  required DropifyAsyncItemBuilder<T> itemBuilder,
}) {
  return itemBuilder(context, item, panelState.isSelected(item), () {
    if (panelState.mode == DropifySelectionMode.single) {
      panelState.select(item);
    } else {
      panelState.toggle(item);
    }
  });
}

int? _selectedAsyncIndex<T>({
  required List<T> items,
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
      for (var index = 0; index < items.length; index++) {
        if (identity.same(selected, items[index])) {
          return index;
        }
      }
    case DropifySelectionMode.multi:
      if (panelState.values.isEmpty) {
        return null;
      }
      for (var index = 0; index < items.length; index++) {
        if (identity.contains(panelState.values, items[index])) {
          return index;
        }
      }
  }
  return null;
}
