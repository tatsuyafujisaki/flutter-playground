import 'dart:async';
import 'dart:io';

void main() {
  final stopwatch = Stopwatch();
  stdout
    ..writeln(stopwatch.elapsed.toString()) // 0
    ..writeln(stopwatch.isRunning.toString()); // false
  stopwatch.start();
  stdout.writeln(stopwatch.isRunning.toString()); // true
  Future<void>.delayed(const Duration(seconds: 3), () {
    stopwatch.stop();
    stdout
      ..writeln(stopwatch.elapsed.toString()) // 3 seconds
      ..writeln(stopwatch.isRunning.toString()); // false
  });
}
