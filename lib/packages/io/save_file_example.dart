import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_playground/packages/io/directories.dart';

/// Writes [bytes] to [filename] in external storage and returns the path.
Future<String?> saveBinaryFileToExternalStorageDirectory(
  List<int> bytes, [
  String filename = 'deleteme',
]) async {
  final path = await joinExternalStorageDirectory(filename);
  if (path == null) {
    return null;
  }
  File(path).writeAsBytesSync(bytes, mode: FileMode.writeOnly);
  return _getDeviceFileExplorerFriendlyExternalStorageDirectory(path);
}

/// Writes [contents] to [filename] in external storage and returns the path.
Future<String?> saveTextFileToExternalStorageDirectory(
  String contents, [
  String filename = 'deleteme.txt',
]) async {
  final path = await joinExternalStorageDirectory(filename);
  if (path == null) {
    return null;
  }
  File(path).writeAsStringSync(contents, mode: FileMode.writeOnly);
  return _getDeviceFileExplorerFriendlyExternalStorageDirectory(path);
}

/// Logs an `adb pull` command to retrieve the file saved at [path].
void showHowtoPullSavedFile(String path) =>
    developer.log('👉 adb pull $path ~/Desktop');

String _getDeviceFileExplorerFriendlyExternalStorageDirectory(
  String externalStorageDirectoryPath,
) => externalStorageDirectoryPath
    .replaceFirst('/data/user/0', '/data/data')
    .replaceFirst('/storage/emulated/0', '/sdcard');
