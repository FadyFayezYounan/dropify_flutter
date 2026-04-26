import 'dart:async';

class DropifyDebouncer {
  DropifyDebouncer(this.delay);

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
