import 'dropify_entry.dart';

/// Loads async Dropify entries for [query].
typedef DropifyAsyncFetcher<T> =
    Future<List<DropifyEntry<T>>> Function(String query);

/// Loads one page of Dropify entries for [pageKey] and [query].
typedef DropifyPageFetcher<T> =
    Future<DropifyPage<T>> Function(int pageKey, String query);

/// Describes a page returned by a paginated Dropify data source.
class DropifyPage<T> {
  /// Creates a page of entries.
  const DropifyPage({required this.entries, this.nextPageKey});

  /// Entries returned for this page.
  final List<DropifyEntry<T>> entries;

  /// The next page key, or null when there are no more pages.
  final int? nextPageKey;
}

/// The source of entries consumed by a Dropify widget.
sealed class DropifyDataSource<T> {
  const DropifyDataSource();
}

/// A fixed list of entries filtered locally.
class StaticDropifyDataSource<T> extends DropifyDataSource<T> {
  /// Creates a static data source.
  const StaticDropifyDataSource({required this.entries});

  /// Entries available to the dropdown.
  final List<DropifyEntry<T>> entries;
}

/// A query-driven async source of entries.
class AsyncDropifyDataSource<T> extends DropifyDataSource<T> {
  /// Creates an async data source.
  const AsyncDropifyDataSource({required this.fetch, this.fetchOnOpen = true});

  /// Fetches entries for a query.
  final DropifyAsyncFetcher<T> fetch;

  /// Whether the first fetch should happen when the dropdown opens.
  final bool fetchOnOpen;
}

/// A paginated source of entries.
class PaginatedDropifyDataSource<T> extends DropifyDataSource<T> {
  /// Creates a paginated data source.
  const PaginatedDropifyDataSource({
    required this.fetchPage,
    this.firstPageKey = 0,
    this.pageSize = 20,
  });

  /// Fetches a page of entries for a query.
  final DropifyPageFetcher<T> fetchPage;

  /// The first page key supplied to [fetchPage].
  final int firstPageKey;

  /// The requested page size.
  final int pageSize;
}
