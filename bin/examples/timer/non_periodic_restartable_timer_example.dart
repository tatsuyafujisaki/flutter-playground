import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';

/// Creates and starts a one-second [RestartableTimer] that invokes [callback].
RestartableTimer createAndStartNonPeriodicRestartableTimer([
  void Function()? callback,
]) => RestartableTimer(const Duration(seconds: 1), () => callback?.call());

void main() {
  final nonPeriodicRestartableTimer = createAndStartNonPeriodicRestartableTimer(
    () {
      stdout
        ..writeln('The given duration has elapsed.')
        ..writeln(DateTime.now());
    },
  );

  Future<void>.delayed(
    const Duration(seconds: 3),
    nonPeriodicRestartableTimer.reset,
  );
}
