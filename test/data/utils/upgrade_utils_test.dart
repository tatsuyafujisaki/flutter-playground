import 'package:flutter_playground/data/utils/upgrade_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('tryParse', () {
    test('parses valid semantic versions', () {
      expect(tryParse('1.2.3'), Version(1, 2, 3));
      expect(tryParse('2.0.0-beta.1'), Version.parse('2.0.0-beta.1'));
    });

    test('returns null for empty or invalid version strings', () {
      expect(tryParse(''), isNull);
      expect(tryParse('not-a-version'), isNull);
    });
  });
}
