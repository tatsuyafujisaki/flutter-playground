import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/data/utils/download_utils.dart';
import 'package:flutter_playground/data/utils/save_file_utils.dart';
import 'package:flutter_playground/ui/example/io/external_storage_action_preview.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

const _sampleUrl =
    'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif';

/// Previews downloading and saving a binary file to external storage.
@Preview(group: 'Packages', name: 'Download & Save Binary File')
Widget preview() => ExternalStorageActionPreview(
  idleLabel: 'Download & Save Binary File',
  runningLabel: 'Downloading...',
  failureMessage: 'Failed to download and save binary file',
  onSave: () => downloadAndSaveBinaryFile(_sampleUrl),
);

/// Downloads binary data from [url] and saves it to external storage.
Future<String?> downloadAndSaveBinaryFile(String url) async {
  final bytes = await downloadBinaryFile(url);
  return await saveBinaryFileToExternalStorageDirectory(bytes, p.basename(url));
}
