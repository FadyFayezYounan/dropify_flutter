import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/_debouncer.dart';
import '../theme/dropify_theme.dart';

/// Builds paginated Dropify items.
typedef DropifyPaginatedItemBuilder<T> =
    Widget Function(
      BuildContext context,
      T item,
      int index,
      bool selected,
      VoidCallback onTap,
    );

/// A raw dropdown backed by caller-owned paging state.
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
  final void Function(String query)? onSearchChanged;
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
  final bool confirmable;
  final String? confirmLabel;
  final String? cancelLabel;

  @override
  State<RawPaginatedDropify<PageKey, T>> createState() =>
      _RawPaginatedDropifyState<PageKey, T>();
}

class _RawPaginatedDropifyState<PageKey, T>
    extends State<RawPaginatedDropify<PageKey, T>> {
  late DropifyDebouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _debouncer = DropifyDebouncer(widget.searchDebounce);
  }

  @override
  void didUpdateWidget(covariant RawPaginatedDropify<PageKey, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchDebounce != widget.searchDebounce) {
      _debouncer.dispose();
      _debouncer = DropifyDebouncer(widget.searchDebounce);
    }
  }

  @override
  void dispose() {
    _debouncer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget panelBuilder(BuildContext context, DropifyPanelState<T> panelState) {
      return _PaginatedBody<PageKey, T>(
        state: widget.state,
        fetchNextPage: widget.fetchNextPage,
        panelState: panelState,
        itemBuilder: widget.itemBuilder,
        firstPageProgressBuilder: widget.firstPageProgressBuilder,
        newPageProgressBuilder: widget.newPageProgressBuilder,
        firstPageErrorBuilder: widget.firstPageErrorBuilder,
        newPageErrorBuilder: widget.newPageErrorBuilder,
        noItemsFoundBuilder: widget.noItemsFoundBuilder,
        noMoreItemsBuilder: widget.noMoreItemsBuilder,
        invisibleItemsThreshold: widget.invisibleItemsThreshold,
        loadOnOpen: widget.loadOnOpen,
      );
    }

    void handleSearch(String query) {
      _debouncer(() => widget.onSearchChanged?.call(query));
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
        onSearchChanged: handleSearch,
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
      onSearchChanged: handleSearch,
    );
  }
}

class _PaginatedBody<PageKey, T> extends StatefulWidget {
  const _PaginatedBody({
    required this.state,
    required this.fetchNextPage,
    required this.panelState,
    required this.itemBuilder,
    required this.invisibleItemsThreshold,
    required this.loadOnOpen,
    this.firstPageProgressBuilder,
    this.newPageProgressBuilder,
    this.firstPageErrorBuilder,
    this.newPageErrorBuilder,
    this.noItemsFoundBuilder,
    this.noMoreItemsBuilder,
  });

  final PagingState<PageKey, T> state;
  final FutureOr<void> Function() fetchNextPage;
  final DropifyPanelState<T> panelState;
  final DropifyPaginatedItemBuilder<T> itemBuilder;
  final int invisibleItemsThreshold;
  final bool loadOnOpen;
  final WidgetBuilder? firstPageProgressBuilder;
  final WidgetBuilder? newPageProgressBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)?
  firstPageErrorBuilder;
  final Widget Function(BuildContext, Object, VoidCallback)?
  newPageErrorBuilder;
  final WidgetBuilder? noItemsFoundBuilder;
  final WidgetBuilder? noMoreItemsBuilder;

  @override
  State<_PaginatedBody<PageKey, T>> createState() =>
      _PaginatedBodyState<PageKey, T>();
}

class _PaginatedBodyState<PageKey, T>
    extends State<_PaginatedBody<PageKey, T>> {
  @override
  void initState() {
    super.initState();
    if (widget.loadOnOpen && widget.state.pages == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.state.pages == null) {
          unawaited(Future<void>.sync(widget.fetchNextPage));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = DropifyTheme.of(context);
    return PagedListView<PageKey, T>(
      shrinkWrap: true,
      state: widget.state,
      fetchNextPage: () => unawaited(Future<void>.sync(widget.fetchNextPage)),
      builderDelegate: PagedChildBuilderDelegate<T>(
        invisibleItemsThreshold: widget.invisibleItemsThreshold,
        itemBuilder: (context, item, index) {
          return widget.itemBuilder(
            context,
            item,
            index,
            widget.panelState.isSelected(item),
            () {
              if (widget.panelState.mode == DropifySelectionMode.single) {
                widget.panelState.select(item);
              } else {
                widget.panelState.toggle(item);
              }
            },
          );
        },
        firstPageProgressIndicatorBuilder:
            widget.firstPageProgressBuilder ?? theme.firstPageProgressBuilder,
        newPageProgressIndicatorBuilder:
            widget.newPageProgressBuilder ?? theme.newPageProgressBuilder,
        firstPageErrorIndicatorBuilder: (context) {
          final error = widget.state.error ?? 'Unknown error';
          return (widget.firstPageErrorBuilder ?? theme.firstPageErrorBuilder)
                  ?.call(context, error, widget.fetchNextPage) ??
              Center(child: Text(error.toString()));
        },
        newPageErrorIndicatorBuilder: (context) {
          final error = widget.state.error ?? 'Unknown error';
          return (widget.newPageErrorBuilder ?? theme.newPageErrorBuilder)
                  ?.call(context, error, widget.fetchNextPage) ??
              Center(child: Text(error.toString()));
        },
        noItemsFoundIndicatorBuilder:
            widget.noItemsFoundBuilder ?? theme.noResultsBuilder,
        noMoreItemsIndicatorBuilder:
            widget.noMoreItemsBuilder ?? theme.noMoreItemsBuilder,
      ),
    );
  }
}
