import 'dart:async';
import 'dart:io';

Future<void> main() async {
  final stream = Stream<String>.fromIterable(['a', 'b', 'c']);
  final list = await stream.map((e) => e.toUpperCase()).toList();
  stdout.writeln(list); // [A, B, C]
}
