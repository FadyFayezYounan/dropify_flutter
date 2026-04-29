import 'dart:async';

/// A debouncer that delays the execution of a callback.
final class DropifyDebouncer {
  /// Creates a new debouncer with the specified delay.
  DropifyDebouncer(this.delay);

  /// The delay between calls.
  final Duration delay;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    if (delay == Duration.zero) {
      action();
      return;
    }
    _timer = Timer(delay, action);
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  void dispose() {
    cancel();
  }
}
