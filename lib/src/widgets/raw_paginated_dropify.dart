import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/_debouncer.dart';
import '../theme/dropify_theme.dart';

/// Builds a paginated item row.
typedef DropifyPaginatedItemBuilder<T> =
    Widget Function(
      BuildContext context,
      T item,
      int index,
      bool selected,
      VoidCallback onTap,
    );

/// A raw dropdown that consumes caller-owned paging state.
class RawPaginatedDropify<PageKey, T> extends StatefulWidget {
  const RawPaginatedDropify({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.anchorBuilder,
    required this.itemBuilder,
    this.firstPageProgressBuilder,
    this.newPageProgressBuilder,
    this.firstPageErrorBuilder,
    this.newPageErrorBuilder,
    this.noItemsFoundBuilder,
    this.noMoreItemsBuilder,
    this.invisibleItemsThreshold = 3,
    this.onSearchChanged,
    this.loadOnOpen = true,
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

  const RawPaginatedDropify.multi({
    super.key,
    required this.state,
    required this.fetchNextPage,
    required this.anchorBuilder,
    required this.itemBuilder,
    this.firstPageProgressBuilder,
    this.newPageProgressBuilder,
    this.firstPageErrorBuilder,
    this.newPageErrorBuilder,
    this.noItemsFoundBuilder,
    this.noMoreItemsBuilder,
    this.invisibleItemsThreshold = 3,
    this.onSearchChanged,
    this.loadOnOpen = true,
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

  final PagingState<PageKey, T> state;
  final FutureOr<void> Function() fetchNextPage;
  final AnchorBuilder<T> anchorBuilder;
  final DropifyPaginatedItemBuilder<T> itemBuilder;
  final WidgetBuilder? firstPageProgressBuilder;
  final WidgetBuilder? newPageProgressBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)?
  firstPageErrorBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)?
  newPageErrorBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final WidgetBuilder? noMoreItemsBuilder;
  final int invisibleItemsThreshold;
  final ValueChanged<String>? onSearchChanged;
  final bool loadOnOpen;
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
  State<RawPaginatedDropify<PageKey, T>> createState() =>
      _RawPaginatedDropifyState<PageKey, T>();
}

class _RawPaginatedDropifyState<PageKey, T>
    extends State<RawPaginatedDropify<PageKey, T>> {
  DropifyDebouncer? _debouncer;
  String _lastSearch = '';

  @override
  void initState() {
    super.initState();
    _debouncer = DropifyDebouncer(widget.searchDebounce);
  }

  @override
  void didUpdateWidget(covariant RawPaginatedDropify<PageKey, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchDebounce != widget.searchDebounce) {
      _debouncer?.dispose();
      _debouncer = DropifyDebouncer(widget.searchDebounce);
    }
  }

  @override
  void dispose() {
    _debouncer?.dispose();
    super.dispose();
  }

  void _handleOpen() {
    if (widget.loadOnOpen && widget.state.pages == null) {
      widget.fetchNextPage();
    }
  }

  void _handleSearch(String query) {
    if (query.isEmpty && _lastSearch.isEmpty) {
      return;
    }
    _lastSearch = query;
    _debouncer?.call(() => widget.onSearchChanged?.call(query));
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
            onOpen: _handleOpen,
            validator: widget.validator,
            autovalidateMode: widget.autovalidateMode,
            errorTextBuilder: widget.errorTextBuilder,
            keyOf: widget.keyOf,
            equals: widget.equals,
            onSearchChanged: _handleSearch,
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
            onOpen: _handleOpen,
            validator: widget.validator,
            autovalidateMode: widget.autovalidateMode,
            errorTextBuilder: widget.errorTextBuilder,
            keyOf: widget.keyOf,
            equals: widget.equals,
            confirmable: widget.confirmable,
            confirmLabel: widget.confirmLabel,
            cancelLabel: widget.cancelLabel,
            onSearchChanged: _handleSearch,
          );
    return raw;
  }

  Widget _panelBuilder(BuildContext context, DropifyPanelState<T> state) {
    final theme = DropifyTheme.of(context);
    Widget defaultProgress(String key) =>
        Center(child: CircularProgressIndicator(key: ValueKey<String>(key)));
    Widget defaultError(String key, Object error, VoidCallback retry) => Center(
      child: TextButton(
        key: ValueKey<String>(key),
        onPressed: retry,
        child: Text(theme.retryText ?? 'Retry'),
      ),
    );
    return PagedListView<PageKey, T>(
      state: widget.state,
      fetchNextPage: widget.fetchNextPage,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      builderDelegate: PagedChildBuilderDelegate<T>(
        invisibleItemsThreshold: widget.invisibleItemsThreshold,
        itemBuilder: (context, item, index) {
          return widget.itemBuilder(
            context,
            item,
            index,
            state.isSelected(item),
            () {
              if (state.mode == DropifySelectionMode.single) {
                state.select(item);
              } else {
                state.toggle(item);
              }
            },
          );
        },
        firstPageProgressIndicatorBuilder:
            widget.firstPageProgressBuilder ??
            theme.firstPageProgressBuilder ??
            (_) => defaultProgress('dropify.paging.firstPageProgress'),
        newPageProgressIndicatorBuilder:
            widget.newPageProgressBuilder ??
            theme.newPageProgressBuilder ??
            (_) => defaultProgress('dropify.paging.newPageProgress'),
        firstPageErrorIndicatorBuilder: (context) =>
            (widget.firstPageErrorBuilder ?? theme.firstPageErrorBuilder)?.call(
              context,
              widget.state.error ?? 'Failed to load items',
              widget.fetchNextPage,
            ) ??
            defaultError(
              'dropify.paging.firstPageError',
              widget.state.error ?? 'Failed to load items',
              widget.fetchNextPage,
            ),
        newPageErrorIndicatorBuilder: (context) =>
            (widget.newPageErrorBuilder ?? theme.newPageErrorBuilder)?.call(
              context,
              widget.state.error ?? 'Failed to load more items',
              widget.fetchNextPage,
            ) ??
            defaultError(
              'dropify.paging.newPageError',
              widget.state.error ?? 'Failed to load more items',
              widget.fetchNextPage,
            ),
        noItemsFoundIndicatorBuilder:
            widget.noItemsFoundBuilder ??
            theme.noResultsBuilder ??
            (_) => Center(
              key: const ValueKey<String>('dropify.paging.noItems'),
              child: Text(theme.emptyText ?? 'No items'),
            ),
        noMoreItemsIndicatorBuilder:
            widget.noMoreItemsBuilder ??
            theme.noMoreItemsBuilder ??
            (_) => Center(
              key: const ValueKey<String>('dropify.paging.noMoreItems'),
              child: Text(theme.noMoreItemsText ?? 'No more items'),
            ),
      ),
    );
  }
}
