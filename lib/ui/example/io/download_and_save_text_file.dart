import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/ui/example/io/download_file_example.dart';
import 'package:flutter_playground/ui/example/io/external_storage_action_preview.dart';
import 'package:flutter_playground/ui/example/io/save_file_example.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

const _sampleUrl = 'https://www.w3.org/robots.txt';

/// Previews downloading and saving a text file to external storage.
@Preview(group: 'Packages', name: 'Download & Save Text File')
Widget preview() => ExternalStorageActionPreview(
  idleLabel: 'Download & Save Text File',
  runningLabel: 'Downloading...',
  failureMessage: 'Failed to download and save text file',
  onSave: () => _downloadAndSaveTextFile(_sampleUrl),
);

Future<String?> _downloadAndSaveTextFile(String url) async {
  final uri = Uri.parse(url);
  final contents = await downloadTextFile(uri);
  return await saveTextFileToExternalStorageDirectory(
    contents,
    p.basename(uri.path),
  );
}
