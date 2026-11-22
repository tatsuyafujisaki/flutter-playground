import 'dart:async';
import 'dart:io';

Future<void> main() async {
  await _showBlockingLoopExample1();
  await _showBlockingLoopExample2();
  _showNonBlockingLoopExample1();
  _showNonBlockingLoopExample2();
}

Stream<int> get _stream =>
    Stream.periodic(const Duration(seconds: 1), (count) => count).take(3);

void _showNonBlockingLoopExample1() {
  Timer.periodic(const Duration(seconds: 1), (timer) {
    stdout.writeln('Timer.tick: ${timer.tick}');
    if (timer.tick == 3) {
      timer.cancel();
    }
  });
}

void _showNonBlockingLoopExample2() {
  _stream.listen((value) {
    stdout.writeln('Stream.value in a non-blocking loop: $value');
  });
}

Future<void> _showBlockingLoopExample1() async {
  final stream = _stream;
  await for (final value in stream) {
    stdout.writeln('Stream.value in a blocking loop: $value');
  }
}

Future<void> _showBlockingLoopExample2() async {
  var count = 0;
  while (true) {
    stdout.writeln('While.count: $count');
    count++;
    if (count == 3) {
      break;
    }
    await Future<void>.delayed(const Duration(seconds: 1));
  }
}
