import 'dart:io';

Future<void> main() async {
  final future1 = Future<String>.value('🍎');
  final future2 = Future<String>.error('☠️');

  await _printFuture(future1);
  stdout.writeln('--');
  await _printFuture(future2);
  stdout.writeln('--');
  await _printFuture(future1, deliberatelyThrowErrorInsideThen: true);
}

Future<void> _printFuture<T>(
  Future<T> future, {
  bool deliberatelyThrowErrorInsideThen = false,
}) async {
  await future
      .then(
        (value) {
          if (deliberatelyThrowErrorInsideThen) {
            throw Exception('This exception originate in `then`.');
          }
          stdout.writeln('👀then.onValue: $value');
        },
        onError: (Object error, StackTrace stackTrace) {
          stderr
            ..writeln('👀then.onError: $error')
            ..writeln(stackTrace);
        },
      )
      .catchError((Object error, StackTrace stackTrace) {
        stderr
          ..writeln('👀catchError: $error')
          ..writeln(stackTrace);
      })
      .whenComplete(() => stdout.writeln('👀whenComplete'));
}
