import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/packages/io/external_storage_action_preview.dart';
import 'package:flutter_playground/packages/io/save_file_example.dart';
import 'package:material_ui/material_ui.dart';

/// Previews saving a text file using `path` and `path_provider`.
@Preview(group: 'Packages', name: 'Path Provider Save File')
Widget preview() => ExternalStorageActionPreview(
  idleLabel: 'Save Sample Text File',
  runningLabel: 'Saving...',
  failureMessage: 'Failed to save text file',
  onSave: () => saveTextFileToExternalStorageDirectory('🍎'),
);
