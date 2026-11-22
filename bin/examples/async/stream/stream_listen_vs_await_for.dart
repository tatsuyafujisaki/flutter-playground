import 'dart:io';

Future<void> main() async {
  stdout.writeln('-- Example of "Stream.listen(...)" --');
  await showListenExample();
  stdout.writeln('-- Example of "await for" --');
  await showAwaitForExample();
}

Stream<String> _createStream() => Stream<String>.periodic(
  const Duration(milliseconds: 100),
  (count) => '$count!',
).take(3);

/// Demonstrates consuming a stream using [Stream.listen].
Future<void> showListenExample() async {
  stdout.writeln('👀Starts consuming a stream.');
  final subscription = _createStream().listen(
    (data) => stdout.writeln('👀$data'),
  );
  // Unlike "await for", listen() does not wait until the stream is done.
  // Without "await subscription.asFuture(...)",
  // the app will not wait for the stream to finish.
  final result = await subscription.asFuture<String>(
    '👀Finishes consuming a stream.',
  );
  stdout.writeln(result);

  await subscription.cancel();
}

/// Demonstrates consuming a stream using an `await for` loop.
Future<void> showAwaitForExample() async {
  stdout.writeln('👀Starts consuming a stream.');
  // Unlike listen(), "await for" waits until the stream is done.
  //
  // > When reading events using an await for loop, the loops stops when the
  // > stream is done.
  // https://dart.dev/libraries/async/using-streams#error-events
  await for (final data in _createStream()) {
    stdout.writeln('👀$data');
  }
  stdout.writeln('👀Finishes consuming a stream.');
}
