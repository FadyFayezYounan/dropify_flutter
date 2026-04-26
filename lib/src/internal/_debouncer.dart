import 'dart:async';

/// A simple Timer-backed debouncer that coalesces multiple calls to [run]
/// within [duration] into a single callback invocation.
class Debouncer {
  Debouncer({required this.duration});

  final Duration duration;
  Timer? _timer;

  /// Schedules [callback] to run after [duration] has elapsed since the last
  /// call to [run].
  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(duration, () {
      callback();
    });
  }

  /// Cancels any pending callback.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Cancels the pending callback and frees resources.
  void dispose() {
    cancel();
  }
}
