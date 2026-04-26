import 'dart:async';

/// A lightweight cancellation token for Dropify async work.
class DropifyCancelToken {
  /// Creates a cancellation token.
  DropifyCancelToken();

  bool _cancelled = false;
  final Completer<void> _completer = Completer<void>();

  /// Whether [cancel] has been called.
  bool get isCancelled => _cancelled;

  /// Completes when [cancel] is called for the first time.
  Future<void> get whenCancelled => _completer.future;

  /// Cancels the operation represented by this token.
  void cancel() {
    if (_cancelled) {
      return;
    }
    _cancelled = true;
    _completer.complete();
  }

  /// Throws [DropifyCancelledException] when this token has been cancelled.
  void throwIfCancelled() {
    if (_cancelled) {
      throw const DropifyCancelledException();
    }
  }
}

/// Exception thrown when Dropify work observes a cancelled token.
class DropifyCancelledException implements Exception {
  /// Creates a cancelled exception.
  const DropifyCancelledException();

  @override
  String toString() => 'DropifyCancelledException: operation cancelled';
}
