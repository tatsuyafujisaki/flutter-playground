import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The path to the temporary directory.
Future<String> get temporaryDirectory async {
  final directory = await getTemporaryDirectory();
  return directory.path;
}

/// The path to the external storage directory, or `null` if unavailable.
Future<String?> get externalStorageDirectory async {
  final directory = await getExternalStorageDirectory();
  return directory?.path;
}

/// Joins [relativePath] with [externalStorageDirectory], or returns `null`.
Future<String?> joinExternalStorageDirectory(String relativePath) async {
  final directory = await externalStorageDirectory;
  return directory == null ? null : p.join(directory, relativePath);
}
