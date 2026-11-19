import 'dart:developer' as developer;

/// Constants representing fruit emojis.
abstract interface class Fruit {
  /// The apple emoji.
  static const apple = '🍎';

  /// The orange emoji.
  static const orange = '🍊';
}

void main() {
  const apple = Fruit.apple; // 🍎
  const orange = Fruit.orange; // 🍊
  developer.log(apple);
  developer.log(orange);
}
