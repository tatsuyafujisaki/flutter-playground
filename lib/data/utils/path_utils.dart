import 'dart:developer' as developer;
import 'dart:io';

// > Though the path library was designed to be imported with a prefix,
// > you don't have to if you don't want to.
// https://pub.dev/packages/path
import 'package:path/path.dart' as p;

/// Returns whether a file exists at [path].
Future<bool> exists(String path) async {
  try {
    return await File(path).exists();
  } on Exception catch (error, stackTrace) {
    developer.log('', error: error, stackTrace: stackTrace);
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
  final file = File(path);
  try {
    if (!await file.exists()) {
      return;
    }
    await file.delete(recursive: true);
  } on Exception catch (error, stackTrace) {
    developer.log('', error: error, stackTrace: stackTrace);
  }
}
