import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_selection.dart';
import '../core/dropify_value.dart';
import '../core/raw_dropify.dart';
import '../internal/dropify_anchor_state.dart';
import '../internal/dropify_panel_state.dart';

/// A paginated dropdown that consumes caller-owned [PagingState] and
/// [fetchNextPage], rendering paginated results inside a [PagedListView].
///
/// The caller manages paging state and search resets. [RawPaginatedDropify]
/// is a pure consumer.
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

  final PagingState<PageKey, T> state;
  final FutureOr<void> Function() fetchNextPage;
  final AnchorBuilder<T> anchorBuilder;
  final Widget Function(BuildContext, T, int, bool, VoidCallback) itemBuilder;
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
  State<RawPaginatedDropify<PageKey, T>> createState() =>
      _RawPaginatedDropifyState<PageKey, T>();
}

class _RawPaginatedDropifyState<PageKey, T>
    extends State<RawPaginatedDropify<PageKey, T>> {
  @override
  Widget build(BuildContext context) {
    final isMulti =
        widget.onChangedMulti != null ||
        widget.initialValues != null ||
        widget.confirmable;

    final panelBuilder = (BuildContext ctx, DropifyPanelState<T> panelState) {
      return PagedListView<PageKey, T>(
        state: widget.state,
        fetchNextPage: widget.fetchNextPage,
        builderDelegate: PagedChildBuilderDelegate<T>(
          invisibleItemsThreshold: widget.invisibleItemsThreshold,
          itemBuilder: (ctx, item, index) {
            return widget.itemBuilder(
              ctx,
              item,
              index,
              panelState.isSelected(item),
              () {
                if (panelState.mode == DropifySelectionMode.single) {
                  panelState.select(item);
                } else {
                  panelState.toggle(item);
                }
              },
            );
          },
          firstPageProgressIndicatorBuilder:
              widget.firstPageProgressBuilder ??
              (_) => const Center(child: CircularProgressIndicator()),
          newPageProgressIndicatorBuilder:
              widget.newPageProgressBuilder ??
              (_) => const Padding(
                padding: EdgeInsets.all(8),
                child: Center(child: CircularProgressIndicator()),
              ),
          firstPageErrorIndicatorBuilder: (ctx) =>
              widget.firstPageErrorBuilder?.call(
                ctx,
                widget.state.error!,
                widget.fetchNextPage,
              ) ??
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: TextButton(
                    onPressed: () => widget.fetchNextPage(),
                    child: const Text('Retry'),
                  ),
                ),
              ),
          newPageErrorIndicatorBuilder: (ctx) =>
              widget.newPageErrorBuilder?.call(
                ctx,
                widget.state.error!,
                widget.fetchNextPage,
              ) ??
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: TextButton(
                    onPressed: () => widget.fetchNextPage(),
                    child: const Text('Retry'),
                  ),
                ),
              ),
          noItemsFoundIndicatorBuilder:
              widget.noItemsFoundBuilder ??
              (_) => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No items found')),
              ),
          noMoreItemsIndicatorBuilder:
              widget.noMoreItemsBuilder ??
              (_) => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('No more items')),
              ),
        ),
      );
    };

    if (isMulti) {
      return RawDropify<T>.multi(
        panelBuilder: panelBuilder,
        anchorBuilder: widget.anchorBuilder,
        controller: widget.controller,
        initialValues: widget.initialValues,
        onChangedMulti: widget.onChangedMulti,
        searchController: widget.searchController,
        searchable: true,
        searchHintText: widget.searchHintText,
        searchDebounce: widget.searchDebounce,
        showClearButton: widget.showClearButton,
        matchAnchorWidth: widget.matchAnchorWidth,
        panelConstraints: widget.panelConstraints,
        alignmentOffset: widget.alignmentOffset,
        useRootOverlay: widget.useRootOverlay,
        consumeOutsideTaps: widget.consumeOutsideTaps,
        enabled: widget.enabled,
        autofocus: widget.autofocus,
        focusNode: widget.focusNode,
        onOpen: widget.onOpen,
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
      panelBuilder: panelBuilder,
      anchorBuilder: widget.anchorBuilder,
      controller: widget.controller,
      initialValue: widget.initialValue,
      onChanged: widget.onChanged,
      searchController: widget.searchController,
      searchable: true,
      searchHintText: widget.searchHintText,
      searchDebounce: widget.searchDebounce,
      showClearButton: widget.showClearButton,
      matchAnchorWidth: widget.matchAnchorWidth,
      panelConstraints: widget.panelConstraints,
      alignmentOffset: widget.alignmentOffset,
      useRootOverlay: widget.useRootOverlay,
      consumeOutsideTaps: widget.consumeOutsideTaps,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      focusNode: widget.focusNode,
      onOpen: widget.onOpen,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      errorTextBuilder: widget.errorTextBuilder,
      keyOf: widget.keyOf,
      equals: widget.equals,
    );
  }
}
