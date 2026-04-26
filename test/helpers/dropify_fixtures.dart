import 'dart:async';

/// Shared test values, data generators, and fake helper classes.
class DropifyFixtures {
  DropifyFixtures._();

  /// A simple list of country names used across static, async, and paginated
  /// tests and examples.
  static const List<String> countries = [
    'Australia',
    'Brazil',
    'Canada',
    'Denmark',
    'Egypt',
    'France',
    'Germany',
    'India',
    'Japan',
    'Kenya',
  ];

  /// Returns [count] test strings of the form "Item $i".
  static List<String> numberedItems(int count) {
    return List.generate(count, (i) => 'Item $i');
  }

  /// Returns a [List] of [T] where each element is produced by [builder] with
  /// index `0..count-1`.
  static List<T> generate<T>(int count, T Function(int i) builder) {
    return List.generate(count, builder);
  }
}

/// A [Completer]-backed async fetcher that can be explicitly resolved,
/// rejected, or delayed, letting tests control the exact order of async
/// state transitions.
class FakeAsyncFetcher<T> {
  FakeAsyncFetcher();

  Completer<List<T>>? _completer;
  int _callCount = 0;
  String? _lastQuery;

  int get callCount => _callCount;
  String? get lastQuery => _lastQuery;
  Completer<List<T>>? get pendingCompleter => _completer;

  Future<List<T>> call(String query) async {
    _callCount++;
    _lastQuery = query;
    _completer = Completer<List<T>>();
    return _completer!.future;
  }

  /// Resolves the most recent (pending) request with [items].
  void resolve(List<T> items) {
    _completer?.complete(items);
    _completer = null;
  }

  /// Rejects the most recent (pending) request with [error].
  void reject(Object error) {
    _completer?.completeError(error);
    _completer = null;
  }
}

/// A [Completer]-backed paging fetcher that controls page-by-page responses
/// and tracks call order.
class FakePagingFetcher<T> {
  FakePagingFetcher();

  Completer<List<T>>? _completer;
  int _callCount = 0;
  int? _lastPageKey;

  int get callCount => _callCount;
  int? get lastPageKey => _lastPageKey;
  Completer<List<T>>? get pendingCompleter => _completer;

  Future<List<T>> call(int pageKey) async {
    _callCount++;
    _lastPageKey = pageKey;
    _completer = Completer<List<T>>();
    return _completer!.future;
  }

  void resolve(List<T> items) {
    _completer?.complete(items);
    _completer = null;
  }

  void reject(Object error) {
    _completer?.completeError(error);
    _completer = null;
  }
}
