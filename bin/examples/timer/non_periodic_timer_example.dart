import 'dart:async';
import 'dart:io';

Timer _createAndStartNonPeriodicTimer([void Function()? callback]) =>
    Timer(const Duration(seconds: 3), () => callback?.call());

void main() {
  stdout.writeln('Timer started at ${DateTime.now()}');
  _createAndStartNonPeriodicTimer(
    () => stdout.writeln('Timer callback is called at ${DateTime.now()}'),
  );
}
