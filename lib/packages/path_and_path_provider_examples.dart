import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/packages/io/save_file_example.dart';
import 'package:material_ui/material_ui.dart';

/// Previews saving a text file using `path` and `path_provider`.
@Preview()
Widget preview() => const _MyStatefulWidget();

class _MyStatefulWidget extends StatefulWidget {
  const new();

  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      const contents = '🍎';
      final path = await saveTextFileToExternalStorageDirectory(contents);
      if (path != null) {
        showHowtoPullSavedFile(path);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const FlutterLogo();
}
