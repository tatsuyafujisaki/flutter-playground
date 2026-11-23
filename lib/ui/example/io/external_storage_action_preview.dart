import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_playground/data/utils/save_file_utils.dart';
import 'package:material_ui/material_ui.dart';

/// A preview widget that runs an Android external-storage file action and
/// displays the saved path or any error.
class const ExternalStorageActionPreview({
  /// The button label shown while idle.
  required final String idleLabel,

  /// The button label shown while [onSave] is running.
  required final String runningLabel,

  /// The log message used if [onSave] throws an [Exception].
  required final String failureMessage,

  /// The asynchronous action that writes a file and returns its saved path.
  required final Future<String?> Function() onSave,
  super.key,
}) extends StatefulWidget {
  /// Creates an [ExternalStorageActionPreview].
  this;

  @override
  State<ExternalStorageActionPreview> createState() =>
      _ExternalStorageActionPreviewState();
}

class _ExternalStorageActionPreviewState
    extends State<ExternalStorageActionPreview> {
  bool _isRunning = false;
  String? _status;

  Future<void> _run() async {
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
      final path = await widget.onSave();
      if (path != null) {
        showHowToPullSavedFile(path);
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
        widget.failureMessage,
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
            onPressed: _isRunning ? null : () => unawaited(_run()),
            child: Text(_isRunning ? widget.runningLabel : widget.idleLabel),
          ),
          if (_status case final status?) Text(status, textAlign: .center),
        ],
      ),
    ),
  );
}
