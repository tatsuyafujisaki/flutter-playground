import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';

void main() {
  final stream1 = Stream<String>.periodic(
    const Duration(seconds: 1),
    (count) => ['🍎', '🍊', '🍏'][count],
  ).take(3);

  final stream2 = Stream<String>.periodic(
    const Duration(seconds: 1),
    (count) => ['🐶', '🐱', '🦊'][count],
  ).take(3);

  StreamGroup.merge<String>([stream1, stream2])
      .listen((event) => stdout.writeln('onData: $event'));
}
