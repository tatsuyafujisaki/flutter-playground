import 'dart:async';

/// Delays executing a callback until a specified [duration] has elapsed.
class Debouncer {
  /// Creates a [Debouncer] with the given [duration].
  Debouncer(this.duration);

  /// The delay duration before invoking the callback.
  final Duration duration;
  Timer? _timer;

  /// Schedules [callback] to run after [duration], canceling any pending call.
  void run(void Function() callback) {
    _timer?.cancel();
    _timer = Timer(duration, callback);
  }

  /// Cancels any pending callback and releases the timer.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
