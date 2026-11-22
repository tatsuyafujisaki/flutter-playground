import 'package:flutter_playground/data/utils/upgrade_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pub_semver/pub_semver.dart';

void main() {
  group('tryParseVersion', () {
    test('parses valid semantic versions', () {
      expect(tryParseVersion('1.2.3'), Version(1, 2, 3));
      expect(tryParseVersion('2.0.0-beta.1'), Version(2, 0, 0, pre: 'beta.1'));
    });

    test('returns null for empty or invalid version strings', () {
      expect(tryParseVersion(''), isNull);
      expect(tryParseVersion('not-a-version'), isNull);
    });
  });
}
