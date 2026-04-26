import 'package:flutter/foundation.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'dropify_cancel_token.dart';

/// A caller-owned paging state that extends [PagingStateBase] with [search]
/// and [cancelToken] fields needed by paginated dropdown search and
/// cancellation workflows.
///
/// Use [copyWith] to produce a new instance with one or more fields changed
/// while leaving others unchanged. [reset] returns a fresh state that clears
/// all paging fields but preserves the current search query.
///
/// The previous [cancelToken] is **not** cancelled by [reset]. Callers must
/// cancel it separately if a fetch is in-flight before resetting.
@immutable
final class DropifyPagingState<PageKey, T> extends PagingStateBase<PageKey, T> {
  DropifyPagingState({
    super.pages,
    super.keys,
    super.error,
    super.hasNextPage,
    super.isLoading,
    this.search,
    this.cancelToken,
  });

  /// The current search query used to scope fetches.
  final String? search;

  /// An in-flight fetch token that should be cancelled before issuing a
  /// new fetch.
  final DropifyCancelToken? cancelToken;

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

  /// Reset all paging fields to their initial values while preserving [search]
  /// and minting a fresh [cancelToken].
  ///
  /// The previous token is **not** cancelled here — callers should cancel it
  /// before calling [reset] if a fetch is in-flight.
  @override
  DropifyPagingState<PageKey, T> reset() {
    return DropifyPagingState<PageKey, T>(
      pages: null,
      keys: null,
      error: null,
      hasNextPage: true,
      isLoading: false,
      search: search,
      cancelToken: DropifyCancelToken(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DropifyPagingState<PageKey, T> &&
        super == other &&
        search == other.search &&
        cancelToken == other.cancelToken;
  }

  @override
  int get hashCode => Object.hash(super.hashCode, search, cancelToken);
}
