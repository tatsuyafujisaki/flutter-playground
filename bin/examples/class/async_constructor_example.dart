import 'dart:io';

class const _MyAsyncConstructorClass._(final String data) {
  static Future<_MyAsyncConstructorClass> create(String emoji) async {
    final data = await Future<String>.value(emoji);
    return _MyAsyncConstructorClass._(data);
  }
}

Future<void> main() async {
  final myClass = await _MyAsyncConstructorClass.create('🍎');
  stdout.writeln(myClass.data); // 🍎
}
