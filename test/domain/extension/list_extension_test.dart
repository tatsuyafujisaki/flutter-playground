import 'package:flutter_playground/domain/extension/list_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListExtension', () {
    test('prepend inserts element at the beginning', () {
      final items = ['b', 'c']..prepend('a');
      expect(items, ['a', 'b', 'c']);
    });

    test('prepend works on an empty list', () {
      final items = <int>[]..prepend(1);
      expect(items, [1]);
    });
  });
}
