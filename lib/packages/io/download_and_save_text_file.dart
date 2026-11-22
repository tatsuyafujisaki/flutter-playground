import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/packages/io/download_file_example.dart';
import 'package:flutter_playground/packages/io/save_file_example.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

/// Previews downloading and saving a text file to external storage.
@Preview(group: 'Packages', name: 'Download & Save Text File')
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  static const _url = 'https://www.w3.org/robots.txt';

  bool _isRunning = false;
  String? _status;

  Future<void> _downloadAndSave() async {
    if (kIsWeb || defaultTargetPlatform != .android) {
      setState(
        () => _status =
            'External storage directory is only available on Android.',
      );
      return;
    }
    setState(() {
      _isRunning = true;
      _status = null;
    });
    try {
      final path = await _downloadAndSaveTextFile(_url);
      if (path != null) {
        showHowtoPullSavedFile(path);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isRunning = false;
        _status = path != null
            ? 'Saved to: $path'
            : 'External storage directory is unavailable on this platform.';
      });
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to download and save text file',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isRunning = false;
        _status = 'Error: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const .all(16),
      child: Column(
        mainAxisSize: .min,
        spacing: 12,
        children: [
          FilledButton(
            onPressed: _isRunning ? null : () => unawaited(_downloadAndSave()),
            child: Text(
              _isRunning ? 'Downloading...' : 'Download & Save Text File',
            ),
          ),
          if (_status case final status?) Text(status, textAlign: .center),
        ],
      ),
    ),
  );
}

Future<String?> _downloadAndSaveTextFile(String url) async {
  final uri = Uri.parse(url);
  final contents = await downloadTextFile(uri);
  return await saveTextFileToExternalStorageDirectory(
    contents,
    p.basename(uri.path),
  );
}
