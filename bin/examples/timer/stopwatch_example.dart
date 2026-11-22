import 'dart:async';
import 'dart:io';

void main() {
  final stopwatch = Stopwatch();
  stdout
    ..writeln(stopwatch.elapsed) // 0
    ..writeln(stopwatch.isRunning); // false
  stopwatch.start();
  stdout.writeln(stopwatch.isRunning); // true
  Future<void>.delayed(const Duration(seconds: 3), () {
    stopwatch.stop();
    stdout
      ..writeln(stopwatch.elapsed) // 3 seconds
      ..writeln(stopwatch.isRunning); // false
  });
}
