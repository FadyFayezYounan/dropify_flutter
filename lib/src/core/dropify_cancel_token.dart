import 'dart:async';

/// A lightweight cancel token passed to async/paginated fetch callbacks.
///
/// Callers can check [isCancelled] after awaiting and call [cancel] to reject
/// a pending result. [whenCancelled] completes when the token is cancelled.
///
/// See also:
///   - [DropifyCancelledException], thrown by [throwIfCancelled].
class DropifyCancelToken {
  DropifyCancelToken();

  bool _cancelled = false;
  final Completer<void> _completer = Completer<void>();

  /// Whether this token has been cancelled.
  bool get isCancelled => _cancelled;

  /// A future that completes when [cancel] is called.
  Future<void> get whenCancelled => _completer.future;

  /// Cancels this token. Idempotent.
  void cancel() {
    if (_cancelled) {
      return;
    }
    _cancelled = true;
    _completer.complete();
  }

  /// Throws [DropifyCancelledException] if [isCancelled] is true.
  void throwIfCancelled() {
    if (_cancelled) {
      throw const DropifyCancelledException();
    }
  }
}

/// Exception thrown by [DropifyCancelToken.throwIfCancelled] when the
/// associated operation has been cancelled.
class DropifyCancelledException implements Exception {
  const DropifyCancelledException();

  @override
  String toString() => 'DropifyCancelledException: operation cancelled';
}
