import 'dart:developer' as developer;
import 'dart:io';

// > Though the path library was designed to be imported with a prefix,
// > you don't have to if you don't want to.
// https://pub.dev/packages/path
import 'package:path/path.dart' as p;

/// Returns whether a file exists at [path].
bool exists(String path) {
  try {
    return File(path).existsSync();
  } on Exception catch (error, stackTrace) {
    developer.log(
      'Failed to check whether file exists: $path',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

/// Replaces the file extension of [path] with [extension].
String replaceExtension(String path, String extension) => p.setExtension(
  path,
  extension.isEmpty || extension.startsWith('.') ? extension : '.$extension',
);

/// Deletes the file at [path] if it exists.
Future<void> deleteIfExists(String path) async {
  try {
    await File(path).delete(recursive: true);
  } on PathNotFoundException {
    return;
  } on Exception catch (error, stackTrace) {
    developer.log(
      'Failed to delete file: $path',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
