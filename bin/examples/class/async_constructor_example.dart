import 'dart:developer' as developer;

class _MyAsyncConstructorClass._(final String data) {
  static Future<_MyAsyncConstructorClass> create(String emoji) async {
    final data = await Future<String>.value(emoji);
    return _MyAsyncConstructorClass._(data);
  }
}

void main() async {
  final myClass = await _MyAsyncConstructorClass.create('🍎');
  developer.log(myClass.data); // 🍎
}
