import 'package:flutter_playground/data/utils/directories.dart';
import 'package:flutter_playground/data/utils/path_utils.dart';
import 'package:path/path.dart' as p;

/// Creates a timestamp-based file path in [directory] with [extension].
Future<String> createTemporaryFilePath({
  String directory = '',
  String extension = '',
}) async => p.join(
  directory.isNotEmpty ? directory : await temporaryDirectory,
  replaceExtension(DateTime.now().microsecondsSinceEpoch.toString(), extension),
);
