import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/packages/io/save_file_example.dart';
import 'package:material_ui/material_ui.dart';

/// Previews saving a text file using `path` and `path_provider`.
@Preview(group: 'Packages', name: 'Path Provider Save File')
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  bool _isSaving = false;
  String? _status;

  Future<void> _saveFile() async {
    if (kIsWeb || defaultTargetPlatform != .android) {
      setState(
        () => _status =
            'External storage directory is only available on Android.',
      );
      return;
    }
    setState(() {
      _isSaving = true;
      _status = null;
    });
    try {
      const contents = '🍎';
      final path = await saveTextFileToExternalStorageDirectory(contents);
      if (path != null) {
        showHowtoPullSavedFile(path);
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
        _status = path != null
            ? 'Saved to: $path'
            : 'External storage directory is unavailable on this platform.';
      });
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to save text file',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
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
            onPressed: _isSaving ? null : () => unawaited(_saveFile()),
            child: Text(_isSaving ? 'Saving...' : 'Save Sample Text File'),
          ),
          if (_status case final status?) Text(status, textAlign: .center),
        ],
      ),
    ),
  );
}
