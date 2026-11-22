import 'package:flutter_playground/domain/extension/date_time_extension.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeExtension', () {
    final earlier = DateTime(2026, 5, 10, 8, 30);
    final same = DateTime(2026, 5, 10, 8, 30);
    final later = DateTime(2026, 5, 10, 9);

    test('isBeforeOrEqualTo compares timestamps inclusively', () {
      expect(earlier.isBeforeOrEqualTo(later), isTrue);
      expect(earlier.isBeforeOrEqualTo(same), isTrue);
      expect(later.isBeforeOrEqualTo(earlier), isFalse);
    });

    test('isAfterOrEqualTo compares timestamps inclusively', () {
      expect(later.isAfterOrEqualTo(earlier), isTrue);
      expect(later.isAfterOrEqualTo(later), isTrue);
      expect(earlier.isAfterOrEqualTo(later), isFalse);
    });

    test('dateOnly strips time while preserving local/UTC timezone', () {
      final local = DateTime(2026, 5, 10, 14, 45, 30);
      expect(local.dateOnly, DateTime(2026, 5, 10));
      expect(local.dateOnly.isUtc, isFalse);

      final utc = DateTime.utc(2026, 5, 10, 14, 45, 30);
      expect(utc.dateOnly, DateTime.utc(2026, 5, 10));
      expect(utc.dateOnly.isUtc, isTrue);
    });

    test('isToday matches current local calendar day', () {
      final now = DateTime.now();
      expect(now.isToday, isTrue);
      expect(now.subtract(const Duration(days: 1)).isToday, isFalse);
      expect(now.add(const Duration(days: 1)).isToday, isFalse);
    });
  });
}
