import 'dart:async';

import 'package:flutter/material.dart';

import '../core/dropify_cancel_token.dart';
import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/_debouncer.dart';
import '../internal/_dropify_menu_scroll_shell.dart';
import '../theme/dropify_theme.dart';

/// Fetches async Dropify items for [query].
typedef DropifyAsyncFetcher<T> =
    Future<List<T>> Function(
      String query, {
      required DropifyCancelToken cancel,
    });

/// Builds async Dropify items.
typedef DropifyAsyncItemBuilder<T> =
    Widget Function(
      BuildContext context,
      T item,
      bool selected,
      VoidCallback onTap,
    );

/// Async dropdown state.
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
  const DropifyAsyncRefreshing(this.staleItems);

  final List<T> staleItems;
}

/// Async data loaded successfully.
final class DropifyAsyncData<T> extends DropifyAsyncState<T> {
  const DropifyAsyncData(this.items);

  final List<T> items;
}

/// Async data loaded with no items.
final class DropifyAsyncEmpty<T> extends DropifyAsyncState<T> {
  const DropifyAsyncEmpty({required this.hasQuery});

  final bool hasQuery;
}

/// Async data failed to load.
final class DropifyAsyncError<T> extends DropifyAsyncState<T> {
  const DropifyAsyncError(this.error, this.stackTrace);

  final Object error;
  final StackTrace? stackTrace;
}

/// A raw dropdown backed by an async search fetcher.
class RawAsyncDropify<T> extends StatefulWidget {
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
  }) : selectionMode = DropifySelectionMode.single,
       initialValues = null,
       onChangedMulti = null,
       confirmable = false,
       confirmLabel = null,
       cancelLabel = null;

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
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
  }) : selectionMode = DropifySelectionMode.multi,
       initialValue = null,
       onChanged = null,
       onChangedMulti = onChanged;

  final DropifyAsyncFetcher<T> fetcher;
  final AnchorBuilder<T> anchorBuilder;
  final DropifyAsyncItemBuilder<T> itemBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, Object error, VoidCallback retry)?
  errorBuilder;
  final Widget Function(BuildContext, bool hasQuery)? emptyBuilder;
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
  final FormFieldValidator<DropifyValue<T>>? validator;
  final AutovalidateMode? autovalidateMode;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;
  final bool loadOnOpen;
  final bool cacheItems;
  final bool confirmable;
  final String? confirmLabel;
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
  });

  final String query;
  final DropifyAsyncFetcher<T> fetcher;
  final DropifyAsyncItemBuilder<T> itemBuilder;
  final DropifyPanelState<T> state;
  final Map<String, List<T>> cache;
  final bool cacheItems;
  final bool loadOnOpen;
  final Duration debounce;
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
        setState(() => _asyncState = DropifyAsyncData<T>(cached));
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
      _asyncState = staleItems == null
          ? DropifyAsyncLoading<T>()
          : DropifyAsyncRefreshing<T>(staleItems);
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
        _asyncState = items.isEmpty
            ? DropifyAsyncEmpty<T>(hasQuery: query.trim().isNotEmpty)
            : DropifyAsyncData<T>(items);
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
  });

  final List<T> items;
  final DropifyPanelState<T> state;
  final DropifyAsyncItemBuilder<T> itemBuilder;

  @override
  Widget build(BuildContext context) {
    return DropifyMenuScrollShell(
      builder: (context, controller) => ListView.builder(
        controller: controller,
        primary: false,
        padding: EdgeInsets.zero,
        shrinkWrap: false,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return itemBuilder(context, item, state.isSelected(item), () {
            if (state.mode == DropifySelectionMode.single) {
              state.select(item);
            } else {
              state.toggle(item);
            }
          });
        },
      ),
    );
  }
}
