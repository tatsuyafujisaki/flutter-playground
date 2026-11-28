import 'package:dio/dio.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/data/provider/dio.dart';
import 'package:flutter_playground/data/utils/download_utils.dart';
import 'package:flutter_playground/data/utils/save_file_utils.dart';
import 'package:flutter_playground/ui/example/io/external_storage_action_preview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

const _sampleUrl = 'https://www.w3.org/robots.txt';

/// Previews downloading and saving a text file to external storage.
@Preview(group: 'Packages', name: 'Download & Save Text File')
Widget preview() => ProviderScope(
  child: Consumer(
    builder: (context, ref, _) => ExternalStorageActionPreview(
      idleLabel: 'Download & Save Text File',
      runningLabel: 'Downloading...',
      failureMessage: 'Failed to download and save text file',
      onSave: () => downloadAndSaveTextFile(ref.read(dioProvider), _sampleUrl),
    ),
  ),
);

/// Downloads text content from [url] with [dio] and saves it to external
/// storage.
Future<String?> downloadAndSaveTextFile(Dio dio, String url) async {
  final uri = Uri.parse(url);
  final contents = await downloadTextFile(dio, uri);
  return await saveTextFileToExternalStorageDirectory(
    contents,
    p.basename(uri.path),
  );
}
