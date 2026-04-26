import 'dart:async';

import 'package:flutter/foundation.dart';

/// Timer-backed debouncer used by search-driven widgets.
final class DropifyDebouncer {
  /// Creates a debouncer.
  DropifyDebouncer(this.delay);

  /// The debounce delay.
  final Duration delay;

  Timer? _timer;
  bool _disposed = false;

  /// Schedules [callback], replacing any pending callback.
  void call(VoidCallback callback) {
    if (_disposed) {
      return;
    }
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  /// Cancels any pending callback.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Disposes this debouncer.
  void dispose() {
    _disposed = true;
    cancel();
  }
}
