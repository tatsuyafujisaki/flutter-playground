import 'dart:io';

import 'package:flutter_playground/data/utils/path_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

void main() {
  group('path_utils', () {
    test('replaceExtension handles dotted, undotted, and empty extensions', () {
      expect(replaceExtension('/tmp/file.txt', '.md'), '/tmp/file.md');
      expect(replaceExtension('/tmp/file.txt', 'md'), '/tmp/file.md');
      expect(replaceExtension('/tmp/file.txt', ''), '/tmp/file');
      expect(replaceExtension('/tmp/file', 'json'), '/tmp/file.json');
    });

    test('exists and deleteIfExists manage files cleanly', () async {
      final tempDir = await Directory.systemTemp.createTemp('path_utils_test_');
      addTearDown(() async {
        if (tempDir.existsSync()) {
          await tempDir.delete(recursive: true);
        }
      });

      final filePath = p.join(tempDir.path, 'sample.txt');
      expect(exists(filePath), isFalse);

      // Deleting a non-existent path completes without throwing.
      await deleteIfExists(filePath);

      await File(filePath).writeAsString('hello');
      expect(exists(filePath), isTrue);

      await deleteIfExists(filePath);
      expect(exists(filePath), isFalse);
    });
  });
}
