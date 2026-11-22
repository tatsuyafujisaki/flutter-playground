import 'package:flutter_playground/data/utils/date_time_converter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeConverter', () {
    const converter = DateTimeConverter();

    test('fromJson parses valid yyyy-MM-dd HH:mm:ss strings', () {
      expect(
        converter.fromJson('2026-11-22 19:58:17'),
        DateTime(2026, 11, 22, 19, 58, 17),
      );
    });

    test('fromJson returns null for empty or invalid strings', () {
      expect(converter.fromJson(''), isNull);
      expect(converter.fromJson('not-a-date'), isNull);
    });

    test('toJson formats DateTime and returns empty string for null', () {
      expect(
        converter.toJson(DateTime(2026, 11, 22, 9, 5, 3)),
        '2026-11-22 09:05:03',
      );
      expect(converter.toJson(null), '');
    });
  });
}
