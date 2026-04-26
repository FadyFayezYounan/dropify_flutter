import 'dart:async';

/// A lightweight cancellation token passed to async Dropify fetchers.
class DropifyCancelToken {
  /// Creates a cancellation token.
  DropifyCancelToken();

  bool _cancelled = false;
  final Completer<void> _completer = Completer<void>();

  /// Whether cancellation has been requested.
  bool get isCancelled => _cancelled;

  /// Completes when [cancel] is first called.
  Future<void> get whenCancelled => _completer.future;

  /// Requests cancellation.
  void cancel() {
    if (_cancelled) {
      return;
    }
    _cancelled = true;
    _completer.complete();
  }

  /// Throws [DropifyCancelledException] if cancellation was requested.
  void throwIfCancelled() {
    if (_cancelled) {
      throw const DropifyCancelledException();
    }
  }
}

/// Thrown when cancelled Dropify work is explicitly checked.
class DropifyCancelledException implements Exception {
  /// Creates a cancellation exception.
  const DropifyCancelledException();

  @override
  String toString() => 'DropifyCancelledException: operation cancelled';
}
