import 'dart:async';
import 'dart:developer' as developer;

/// A periodic timer that can be restarted and canceled.
class PeriodicRestartableTimer {
  /// Creates and starts a [PeriodicRestartableTimer].
  PeriodicRestartableTimer(this.duration, this.callback) {
    _timer = _createTimer();
  }

  /// The interval between timer ticks.
  Duration duration;

  /// The callback invoked on each timer tick.
  void Function()? callback;

  /// Cancels the active timer and starts a new periodic timer.
  void restart() {
    _timer?.cancel();
    _timer = _createTimer();
  }

  /// Cancels the active timer.
  void cancel() => _timer?.cancel();

  Timer _createTimer() => .periodic(duration, (_) => callback?.call());

  Timer? _timer;
}

void main() {
  final timer = PeriodicRestartableTimer(
    const Duration(seconds: 1),
    () => developer.log(DateTime.now().toString()),
  );

  Future<void>.delayed(const Duration(seconds: 3), timer.restart);

  Future<void>.delayed(const Duration(seconds: 6), timer.cancel);
}
