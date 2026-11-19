import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Creates a timestamp-based file path in [directory] with [extension].
Future<String> createTemporaryFilePath({
  String directory = '',
  String extension = '',
}) async => p.join(
  directory.isNotEmpty ? directory : (await getTemporaryDirectory()).path,
  p.setExtension(DateTime.now().microsecondsSinceEpoch.toString(), extension),
);
