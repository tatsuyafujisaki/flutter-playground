import 'package:flutter_playground/data/enum/fruit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fruit.of', () {
    test('returns matching enum value for known emojis', () {
      expect(Fruit.of('🍎'), Fruit.apple);
      expect(Fruit.of('🍊'), Fruit.orange);
    });

    test('returns unknown for unrecognized values', () {
      expect(Fruit.of('🍇'), Fruit.unknown);
      expect(Fruit.of(''), Fruit.unknown);
    });
  });
}
