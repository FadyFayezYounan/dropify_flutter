import 'dart:async';

import 'package:flutter/widgets.dart';

/// Runs the latest action after a fixed delay.
class Debouncer {
  /// Creates a debouncer with [delay].
  Debouncer(this.delay);

  /// The debounce delay.
  final Duration delay;

  Timer? _timer;

  /// Schedules [action], replacing any pending action.
  void run(VoidCallback action) {
    _timer?.cancel();
    if (delay == Duration.zero) {
      action();
      return;
    }
    _timer = Timer(delay, action);
  }

  /// Cancels any pending action.
  void dispose() {
    _timer?.cancel();
  }
}
