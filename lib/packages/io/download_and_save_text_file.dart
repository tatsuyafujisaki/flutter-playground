import 'package:flutter_playground/packages/io/download_file_example.dart';
import 'package:flutter_playground/packages/io/save_file_example.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

void main() => runApp(const ProviderScope(child: _MyStatelessWidget()));

class _MyStatelessWidget extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final path = await _downloadAndSaveTextFile(
        'https://www.w3.org/robots.txt',
      );
      if (path != null) {
        showHowtoPullSavedFile(path);
      }
    });
    return const FlutterLogo();
  }
}

Future<String?> _downloadAndSaveTextFile(String url) async {
  final uri = Uri.parse(url);
  final bytes = await downloadTextFile(uri);
  return await saveTextFileToExternalStorageDirectory(
    bytes,
    p.basename(uri.path),
  );
}
