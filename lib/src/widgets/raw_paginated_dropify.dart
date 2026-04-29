import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/_debouncer.dart';
import '../internal/_dropify_menu_scroll_shell.dart';
import '../theme/dropify_theme.dart';

/// Builds paginated Dropify items.
///
/// The [index] is the flattened index across loaded pages. The [onTap] callback
/// selects or toggles the item according to the active selection mode.
typedef DropifyPaginatedItemBuilder<T> =
    Widget Function(
      BuildContext context,
      T item,
      int index,
      bool selected,
      VoidCallback onTap,
    );

/// A raw dropdown backed by caller-owned paging state.
///
/// This widget consumes [PagingState] and requests pages through
/// [fetchNextPage]. It never mutates the supplied state; callers remain
/// responsible for storing pages, errors, loading flags, search, and
/// cancellation metadata.
class RawPaginatedDropify<PageKey, T> extends StatefulWidget {
  /// Creates a single-selection paginated dropdown.
  ///
  /// The [state], [fetchNextPage], [anchorBuilder], and [itemBuilder] arguments
  /// are required.
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

  /// Creates a multi-selection paginated dropdown.
  ///
  /// When [confirmable] is false, toggles are emitted immediately. When
  /// [confirmable] is true, toggles are staged until the user applies them.
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

  /// The caller-owned paging state to render.
  final PagingState<PageKey, T> state;

  /// Requests the next page from the caller.
  final FutureOr<void> Function() fetchNextPage;

  /// Builds the closed anchor.
  final AnchorBuilder<T> anchorBuilder;

  /// Builds each loaded item row.
  final DropifyPaginatedItemBuilder<T> itemBuilder;

  /// Builds the first-page loading state.
  final WidgetBuilder? firstPageProgressBuilder;

  /// Builds the next-page loading footer.
  final WidgetBuilder? newPageProgressBuilder;

  /// Builds the first-page error state with retry.
  final Widget Function(BuildContext, Object, VoidCallback)?
  firstPageErrorBuilder;

  /// Builds the next-page error footer with retry.
  final Widget Function(BuildContext, Object, VoidCallback)?
  newPageErrorBuilder;

  /// Builds the state shown when loaded pages contain no items.
  final WidgetBuilder? noItemsFoundBuilder;

  /// Builds the footer shown when there are no more pages.
  final WidgetBuilder? noMoreItemsBuilder;

  /// Number of invisible trailing items that trigger [fetchNextPage].
  ///
  /// Defaults to 3.
  final int invisibleItemsThreshold;

  /// Called with the debounced search query.
  final void Function(String query)? onSearchChanged;

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

  /// Debounce duration before [onSearchChanged] is called.
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

  /// Whether the first page is requested when the panel opens.
  final bool loadOnOpen;

  /// Whether multi-selection changes are staged until applied.
  final bool confirmable;

  /// The label for the confirm button in confirmable multi-selection.
  final String? confirmLabel;

  /// The label for the cancel button in confirmable multi-selection.
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
    return DropifyMenuScrollShell(
      builder: (context, controller) => PagedListView<PageKey, T>(
        scrollController: controller,
        primary: false,
        shrinkWrap: false,
        padding: EdgeInsets.zero,
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
      ),
    );
  }
}
