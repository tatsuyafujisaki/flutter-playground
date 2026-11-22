import 'dart:async';
import 'dart:io';

Future<void> main() async {
  final streamController = StreamController<String>.broadcast()
    ..stream.listen((event) => stdout.writeln('Listener 1: $event'))
    ..stream.listen((event) => stdout.writeln('Listener 2: $event'))
    ..add('🍎')
    ..add('🍊');

  await streamController.close();
}
