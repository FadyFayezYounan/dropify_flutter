import 'package:flutter/material.dart';

import '../core/dropify_cancel_token.dart';
import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/dropify_anchor_state.dart';
import '../internal/dropify_panel_state.dart';

// --- Async State ---

sealed class DropifyAsyncState<T> {
  const DropifyAsyncState();
}

class DropifyAsyncIdle<T> extends DropifyAsyncState<T> {
  const DropifyAsyncIdle();
}

class DropifyAsyncLoading<T> extends DropifyAsyncState<T> {
  const DropifyAsyncLoading();
}

class DropifyAsyncRefreshing<T> extends DropifyAsyncState<T> {
  const DropifyAsyncRefreshing(this.staleItems);
  final List<T> staleItems;
}

class DropifyAsyncData<T> extends DropifyAsyncState<T> {
  const DropifyAsyncData(this.items);
  final List<T> items;
}

class DropifyAsyncEmpty<T> extends DropifyAsyncState<T> {
  const DropifyAsyncEmpty({required this.hasQuery});
  final bool hasQuery;
}

class DropifyAsyncError<T> extends DropifyAsyncState<T> {
  const DropifyAsyncError(this.error, this.stackTrace);
  final Object error;
  final StackTrace? stackTrace;
}

typedef DropifyAsyncFetcher<T> =
    Future<List<T>> Function(
      String query, {
      required DropifyCancelToken cancel,
    });

// --- Widget ---

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
    this.keyOf,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.searchController,
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
    this.equals,
  }) : initialValues = null,
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
    this.keyOf,
    this.controller,
    this.onChangedMulti,
    this.initialValues,
    this.searchController,
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
    this.equals,
    this.confirmable = false,
    this.confirmLabel,
    this.cancelLabel,
  }) : initialValue = null,
       onChanged = null;

  final DropifyAsyncFetcher<T> fetcher;
  final AnchorBuilder<T> anchorBuilder;
  final Widget Function(BuildContext, T, bool, VoidCallback) itemBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)? errorBuilder;
  final Widget Function(BuildContext, bool)? emptyBuilder;
  final bool loadOnOpen;
  final bool cacheItems;
  final Object Function(T item)? keyOf;

  final DropifyController<T>? controller;
  final T? initialValue;
  final Set<T>? initialValues;
  final ValueChanged<T?>? onChanged;
  final ValueChanged<Set<T>>? onChangedMulti;

  final TextEditingController? searchController;
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
  final bool Function(T a, T b)? equals;
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  State<RawAsyncDropify<T>> createState() => _RawAsyncDropifyState<T>();
}

class _RawAsyncDropifyState<T> extends State<RawAsyncDropify<T>> {
  DropifyAsyncState<T> _state = DropifyAsyncIdle<T>();
  final Map<String, List<T>> _cache = <String, List<T>>{};
  DropifyCancelToken? _activeToken;
  String _currentQuery = '';

  @override
  void dispose() {
    _activeToken?.cancel();
    super.dispose();
  }

  void _fetch(String query) {
    _activeToken?.cancel();
    final token = DropifyCancelToken();
    _activeToken = token;
    _currentQuery = query;

    final cached = widget.cacheItems ? _cache[query] : null;
    if (cached != null) {
      if (cached.isEmpty) {
        setState(
          () => _state = DropifyAsyncEmpty<T>(hasQuery: query.isNotEmpty),
        );
      } else {
        setState(() => _state = DropifyAsyncData<T>(cached));
      }
      return;
    }

    final isRefreshing = _state is DropifyAsyncData<T>;
    final staleItems = isRefreshing
        ? (_state as DropifyAsyncData<T>).items
        : <T>[];

    setState(() {
      _state = isRefreshing
          ? DropifyAsyncRefreshing<T>(staleItems)
          : DropifyAsyncLoading<T>();
    });

    widget
        .fetcher(query, cancel: token)
        .then((items) {
          if (!token.isCancelled && mounted) {
            if (widget.cacheItems) {
              _cache[query] = items;
            }
            setState(() {
              if (items.isEmpty) {
                _state = DropifyAsyncEmpty<T>(hasQuery: query.isNotEmpty);
              } else {
                _state = DropifyAsyncData<T>(items);
              }
            });
          }
        })
        .catchError((error, stack) {
          if (!token.isCancelled && mounted) {
            setState(() {
              _state = DropifyAsyncError<T>(error, stack);
            });
          }
        });
  }

  void _retry() {
    _fetch(_currentQuery);
  }

  // ignore: use_build_context_synchronously
  Widget _buildPanel(BuildContext context, DropifyPanelState<T> state) {
    return switch (_state) {
      DropifyAsyncLoading<T>() =>
        widget.loadingBuilder?.call(context) ??
            const Center(child: CircularProgressIndicator()),
      DropifyAsyncRefreshing<T>(staleItems: final items) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...items.map(
            (item) =>
                widget.itemBuilder(context, item, state.isSelected(item), () {
                  if (state.mode == DropifySelectionMode.single) {
                    state.select(item);
                  } else {
                    state.toggle(item);
                  }
                }),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(),
          ),
        ],
      ),
      DropifyAsyncData<T>(items: final items) => ListView.builder(
        shrinkWrap: true,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return widget.itemBuilder(context, item, state.isSelected(item), () {
            if (state.mode == DropifySelectionMode.single) {
              state.select(item);
            } else {
              state.toggle(item);
            }
          });
        },
      ),
      DropifyAsyncEmpty<T>(hasQuery: final hasQuery) =>
        widget.emptyBuilder?.call(context, hasQuery) ??
            Center(child: Text(hasQuery ? 'No results' : 'No data')),
      DropifyAsyncError<T>(error: final error) =>
        widget.errorBuilder?.call(context, error, _retry) ??
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Something went wrong'),
                  TextButton(onPressed: _retry, child: const Text('Retry')),
                ],
              ),
            ),
      DropifyAsyncIdle<T>() => const SizedBox.shrink(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final isMulti =
        widget.onChangedMulti != null ||
        widget.initialValues != null ||
        widget.confirmable;

    if (isMulti) {
      return RawDropify<T>.multi(
        panelBuilder: _buildPanel,
        anchorBuilder: widget.anchorBuilder,
        controller: widget.controller,
        initialValues: widget.initialValues,
        onChangedMulti: widget.onChangedMulti,
        searchController: widget.searchController,
        searchable: true,
        searchHintText: widget.searchHintText,
        searchDebounce: widget.searchDebounce,
        onSearchChanged: _fetch,
        showClearButton: widget.showClearButton,
        matchAnchorWidth: widget.matchAnchorWidth,
        panelConstraints: widget.panelConstraints,
        alignmentOffset: widget.alignmentOffset,
        useRootOverlay: widget.useRootOverlay,
        consumeOutsideTaps: widget.consumeOutsideTaps,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        onOpen: () {
          widget.onOpen?.call();
          if (widget.loadOnOpen && _state is DropifyAsyncIdle<T>) {
            _fetch('');
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
      );
    }

    return RawDropify<T>(
      panelBuilder: _buildPanel,
      anchorBuilder: widget.anchorBuilder,
      controller: widget.controller,
      initialValue: widget.initialValue,
      onChanged: widget.onChanged,
      searchController: widget.searchController,
      searchable: true,
      searchHintText: widget.searchHintText,
      searchDebounce: widget.searchDebounce,
      onSearchChanged: _fetch,
      showClearButton: widget.showClearButton,
      matchAnchorWidth: widget.matchAnchorWidth,
      panelConstraints: widget.panelConstraints,
      alignmentOffset: widget.alignmentOffset,
      useRootOverlay: widget.useRootOverlay,
      consumeOutsideTaps: widget.consumeOutsideTaps,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onOpen: () {
        widget.onOpen?.call();
        if (widget.loadOnOpen && _state is DropifyAsyncIdle<T>) {
          _fetch('');
        }
      },
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      errorTextBuilder: widget.errorTextBuilder,
      keyOf: widget.keyOf,
      equals: widget.equals,
    );
  }
}
