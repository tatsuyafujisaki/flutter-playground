import 'package:flutter_playground/extension/string_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringExtension', () {
    test('isNullOrEmpty returns true for null and empty strings', () {
      const String? nullString = null;
      expect(nullString.isNullOrEmpty, isTrue);
      expect(''.isNullOrEmpty, isTrue);
      expect('hello'.isNullOrEmpty, isFalse);
    });

    test('isNeitherNullNorEmpty returns true only for non-empty strings', () {
      const String? nullString = null;
      expect(nullString.isNeitherNullNorEmpty, isFalse);
      expect(''.isNeitherNullNorEmpty, isFalse);
      expect('hello'.isNeitherNullNorEmpty, isTrue);
    });
  });
}
