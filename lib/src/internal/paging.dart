import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../core/dropify_controller.dart';
import '../core/dropify_data_source.dart';
import '../core/dropify_entry.dart';
import '../core/dropify_state.dart';

/// Bridges paginated Dropify data into the package controller state.
@internal
class DropifyPagingAdapter<T> {
  /// Creates a paging adapter for [controller] and [dataSource].
  DropifyPagingAdapter({required this.controller, required this.dataSource})
    : _nextPageKey = dataSource.firstPageKey {
    _pagingController = PagingController<int, DropifyEntry<T>>(
      getNextPageKey: _getNextPageKey,
      fetchPage: _fetchPage,
    )..addListener(_mirrorPagingState);
    _mirrorPagingState();
  }

  /// The Dropify controller receiving mirrored paging state.
  final DropifyController<T> controller;

  /// The data source used to request pages.
  final PaginatedDropifyDataSource<T> dataSource;

  /// Backing controller from `infinite_scroll_pagination` v5.
  late final PagingController<int, DropifyEntry<T>> _pagingController;

  /// Exposes the package paging controller for advanced paged widgets.
  PagingController<int, DropifyEntry<T>> get pagingController =>
      _pagingController;

  int? _nextPageKey;
  int _requestToken = 0;
  final Set<T> _seenValues = <T>{};
  bool _disposed = false;

  int? _getNextPageKey(PagingState<int, DropifyEntry<T>> state) {
    if (state.keys == null) {
      return dataSource.firstPageKey;
    }
    return _nextPageKey;
  }

  Future<List<DropifyEntry<T>>> _fetchPage(int pageKey) async {
    final int requestToken = _requestToken;
    final DropifyPage<T> page = await dataSource.fetchPage(
      pageKey,
      controller.query,
    );
    if (_disposed || requestToken != _requestToken) {
      return List<DropifyEntry<T>>.empty(growable: false);
    }
    final List<DropifyEntry<T>> entries = <DropifyEntry<T>>[];
    for (final DropifyEntry<T> entry in page.entries) {
      if (_seenValues.add(entry.value)) {
        entries.add(entry);
      }
    }
    _nextPageKey = page.nextPageKey;
    if (page.nextPageKey == null) {
      _pagingController.value = _pagingController.value.copyWith(
        hasNextPage: false,
      );
    }
    return entries;
  }

  /// Loads the next page when one is available.
  void loadMore() {
    if (_disposed) {
      return;
    }
    _pagingController.fetchNextPage();
  }

  /// Clears current pages and loads the first page for the current query.
  void refresh() {
    if (_disposed) {
      return;
    }
    _seenValues.clear();
    _requestToken += 1;
    _nextPageKey = dataSource.firstPageKey;
    _pagingController.refresh();
    _mirrorPagingState();
    _pagingController.fetchNextPage();
  }

  /// Retries the failed page or starts the first page again.
  void retry() {
    if (_disposed) {
      return;
    }
    _pagingController.fetchNextPage();
  }

  void _mirrorPagingState() {
    if (_disposed) {
      return;
    }
    final PagingState<int, DropifyEntry<T>> state = _pagingController.value;
    final List<DropifyEntry<T>> entries =
        state.items ?? List<DropifyEntry<T>>.empty(growable: false);
    final bool hasEntries = entries.isNotEmpty;
    final Object? error = state.error;
    final DropifyStatus status;
    if (state.isLoading && !hasEntries) {
      status = DropifyStatus.loading;
    } else if (error != null && !hasEntries) {
      status = DropifyStatus.error;
    } else if (state.pages != null && !hasEntries) {
      status = DropifyStatus.empty;
    } else if (hasEntries) {
      status = DropifyStatus.data;
    } else {
      status = DropifyStatus.idle;
    }
    controller.setEntries(
      entries,
      status: status,
      error: hasEntries ? null : error,
      pageError: hasEntries ? error : null,
      hasMore: state.hasNextPage,
      isLoadingMore: hasEntries && state.isLoading,
    );
  }

  /// Releases the owned paging controller.
  void dispose() {
    _disposed = true;
    _pagingController
      ..removeListener(_mirrorPagingState)
      ..dispose();
  }
}
