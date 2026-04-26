import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../core/dropify_cancel_token.dart';
import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/_debouncer.dart';
import '../theme/dropify_theme.dart';

/// Fetches async dropdown items for a query.
typedef DropifyAsyncFetcher<T> =
    Future<List<T>> Function(
      String query, {
      required DropifyCancelToken cancel,
    });

/// Builds an async item row.
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

final class DropifyAsyncIdle<T> extends DropifyAsyncState<T> {
  const DropifyAsyncIdle();
}

final class DropifyAsyncLoading<T> extends DropifyAsyncState<T> {
  const DropifyAsyncLoading();
}

final class DropifyAsyncRefreshing<T> extends DropifyAsyncState<T> {
  const DropifyAsyncRefreshing(this.staleItems);
  final List<T> staleItems;
}

final class DropifyAsyncData<T> extends DropifyAsyncState<T> {
  const DropifyAsyncData(this.items);
  final List<T> items;
}

final class DropifyAsyncEmpty<T> extends DropifyAsyncState<T> {
  const DropifyAsyncEmpty({required this.hasQuery});
  final bool hasQuery;
}

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
    this.loadOnOpen = true,
    this.cacheItems = true,
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
    this.errorTextBuilder,
    this.keyOf,
    this.equals,
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
    this.loadOnOpen = true,
    this.cacheItems = true,
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

  final DropifyAsyncFetcher<T> fetcher;
  final AnchorBuilder<T> anchorBuilder;
  final DropifyAsyncItemBuilder<T> itemBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, Object error, VoidCallback retry)?
  errorBuilder;
  final Widget Function(BuildContext, bool hasQuery)? emptyBuilder;
  final bool loadOnOpen;
  final bool cacheItems;
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
  final Widget Function(BuildContext, String error)? errorTextBuilder;
  final Object Function(T item)? keyOf;
  final bool Function(T a, T b)? equals;
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  State<RawAsyncDropify<T>> createState() => _RawAsyncDropifyState<T>();
}

class _RawAsyncDropifyState<T> extends State<RawAsyncDropify<T>> {
  final Map<String, List<T>> _cache = <String, List<T>>{};
  DropifyAsyncState<T> _state = const DropifyAsyncIdle();
  DropifyCancelToken? _token;
  DropifyDebouncer? _debouncer;
  int _generation = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _debouncer = DropifyDebouncer(widget.searchDebounce);
  }

  @override
  void didUpdateWidget(covariant RawAsyncDropify<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchDebounce != widget.searchDebounce) {
      _debouncer?.dispose();
      _debouncer = DropifyDebouncer(widget.searchDebounce);
    }
  }

  @override
  void dispose() {
    _token?.cancel();
    _debouncer?.dispose();
    super.dispose();
  }

  void _load(String query, {bool immediate = false}) {
    void run() => _fetch(query);
    if (immediate) {
      run();
    } else {
      _debouncer?.call(run);
    }
  }

  Future<void> _fetch(String query) async {
    _query = query;
    if (widget.cacheItems && _cache.containsKey(query)) {
      setState(() => _state = DropifyAsyncData<T>(_cache[query]!));
      return;
    }
    _token?.cancel();
    final token = DropifyCancelToken();
    final generation = ++_generation;
    final previous = switch (_state) {
      DropifyAsyncData<T>(items: final items) => items,
      DropifyAsyncRefreshing<T>(staleItems: final items) => items,
      _ => null,
    };
    setState(() {
      _state = previous == null
          ? DropifyAsyncLoading<T>()
          : DropifyAsyncRefreshing<T>(previous);
    });
    _token = token;
    try {
      final items = await widget.fetcher(query, cancel: token);
      if (!mounted || token.isCancelled || generation != _generation) {
        return;
      }
      if (widget.cacheItems) {
        _cache[query] = items;
      }
      setState(() {
        _state = items.isEmpty
            ? DropifyAsyncEmpty<T>(hasQuery: query.trim().isNotEmpty)
            : DropifyAsyncData<T>(items);
      });
    } catch (error, stackTrace) {
      if (!mounted || token.isCancelled || generation != _generation) {
        return;
      }
      setState(() => _state = DropifyAsyncError<T>(error, stackTrace));
    }
  }

  @override
  Widget build(BuildContext context) {
    final raw = widget.selectionMode == DropifySelectionMode.single
        ? RawDropify<T>(
            panelBuilder: _panelBuilder,
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
            onOpen: () {
              if (widget.loadOnOpen) {
                _load(_query, immediate: true);
              }
            },
            validator: widget.validator,
            autovalidateMode: widget.autovalidateMode,
            errorTextBuilder: widget.errorTextBuilder,
            keyOf: widget.keyOf,
            equals: widget.equals,
            onSearchChanged: _load,
          )
        : RawDropify<T>.multi(
            panelBuilder: _panelBuilder,
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
            onOpen: () {
              if (widget.loadOnOpen) {
                _load(_query, immediate: true);
              }
            },
            validator: widget.validator,
            autovalidateMode: widget.autovalidateMode,
            errorTextBuilder: widget.errorTextBuilder,
            keyOf: widget.keyOf,
            equals: widget.equals,
            confirmable: widget.confirmable,
            confirmLabel: widget.confirmLabel,
            cancelLabel: widget.cancelLabel,
            onSearchChanged: _load,
          );
    return raw;
  }

  Widget _panelBuilder(BuildContext context, DropifyPanelState<T> panelState) {
    final theme = DropifyTheme.of(context);
    return switch (_state) {
      DropifyAsyncIdle<T>() => const SizedBox.shrink(),
      DropifyAsyncLoading<T>() => KeyedSubtree(
        key: const ValueKey<String>('dropify.async.loading'),
        child:
            widget.loadingBuilder?.call(context) ??
            theme.loadingBuilder?.call(context) ??
            Center(child: Text(theme.loadingText ?? 'Loading...')),
      ),
      DropifyAsyncRefreshing<T>(staleItems: final items) => Stack(
        children: [
          _items(context, panelState, items),
          const Positioned(
            right: 12,
            top: 12,
            child: CircularProgressIndicator(
              key: ValueKey<String>('dropify.async.refreshing'),
            ),
          ),
        ],
      ),
      DropifyAsyncData<T>(items: final items) => _items(
        context,
        panelState,
        items,
      ),
      DropifyAsyncEmpty<T>(hasQuery: final hasQuery) => KeyedSubtree(
        key: const ValueKey<String>('dropify.async.empty'),
        child:
            widget.emptyBuilder?.call(context, hasQuery) ??
            theme.emptyBuilder?.call(context, hasQuery) ??
            Center(
              child: Text(
                hasQuery
                    ? (theme.noResultsText ?? 'No results')
                    : (theme.emptyText ?? 'No items'),
              ),
            ),
      ),
      DropifyAsyncError<T>(error: final error) => KeyedSubtree(
        key: const ValueKey<String>('dropify.async.error'),
        child:
            widget.errorBuilder?.call(
              context,
              error,
              () => _load(_query, immediate: true),
            ) ??
            theme.errorBuilder?.call(
              context,
              error,
              () => _load(_query, immediate: true),
            ) ??
            Center(
              child: TextButton(
                key: const ValueKey<String>('dropify.async.retry'),
                onPressed: () => _load(_query, immediate: true),
                child: Text(theme.retryText ?? 'Retry'),
              ),
            ),
      ),
    };
  }

  Widget _items(
    BuildContext context,
    DropifyPanelState<T> state,
    List<T> items,
  ) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final selected = state.isSelected(item);
        return widget.itemBuilder(context, item, selected, () {
          if (state.mode == DropifySelectionMode.single) {
            state.select(item);
          } else {
            state.toggle(item);
          }
        });
      },
    );
  }
}
