import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'dropify_cancel_token.dart';

/// A paging state with Dropify search and cancellation metadata.
///
/// This type extends the `infinite_scroll_pagination` paging state model with
/// optional search and cancellation fields. It is a convenience for callers that
/// want to keep the current query and active cancellation token beside their
/// pages.
@immutable
final class DropifyPagingState<PageKey, T> extends PagingStateBase<PageKey, T> {
  /// Creates a Dropify paging state.
  ///
  /// The paging fields are passed to [PagingStateBase]. The optional [search]
  /// and [cancelToken] fields are owned by the caller.
  DropifyPagingState({
    super.pages,
    super.keys,
    super.error,
    super.hasNextPage,
    super.isLoading,
    this.search,
    this.cancelToken,
  });

  /// The current search query associated with this paging state.
  final String? search;

  /// The active caller-owned cancellation token, if any.
  final DropifyCancelToken? cancelToken;

  /// Returns a copy of this paging state with selected fields replaced.
  ///
  /// Fields wrapped in [Omit] keep their current value.
  @override
  DropifyPagingState<PageKey, T> copyWith({
    Defaulted<List<List<T>>?>? pages = const Omit(),
    Defaulted<List<PageKey>?>? keys = const Omit(),
    Defaulted<Object?>? error = const Omit(),
    Defaulted<bool>? hasNextPage = const Omit(),
    Defaulted<bool>? isLoading = const Omit(),
    Defaulted<String?>? search = const Omit(),
    Defaulted<DropifyCancelToken?>? cancelToken = const Omit(),
  }) {
    return DropifyPagingState<PageKey, T>(
      pages: pages is Omit ? this.pages : pages as List<List<T>>?,
      keys: keys is Omit ? this.keys : keys as List<PageKey>?,
      error: error is Omit ? this.error : error,
      hasNextPage: hasNextPage is Omit ? this.hasNextPage : hasNextPage as bool,
      isLoading: isLoading is Omit ? this.isLoading : isLoading as bool,
      search: search is Omit ? this.search : search as String?,
      cancelToken: cancelToken is Omit
          ? this.cancelToken
          : cancelToken as DropifyCancelToken?,
    );
  }

  /// Returns an empty paging state for the same search query.
  ///
  /// A new [DropifyCancelToken] is created for the reset state.
  @override
  DropifyPagingState<PageKey, T> reset() {
    return DropifyPagingState<PageKey, T>(
      search: search,
      cancelToken: DropifyCancelToken(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DropifyPagingState<PageKey, T> &&
        super == other &&
        other.search == search &&
        other.cancelToken == cancelToken;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, search, cancelToken);
}
