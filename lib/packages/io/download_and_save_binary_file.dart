import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/packages/io/download_file_example.dart';
import 'package:flutter_playground/packages/io/save_file_example.dart';
import 'package:material_ui/material_ui.dart';
import 'package:path/path.dart' as p;

/// Previews downloading and saving a binary file to external storage.
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
      final path = await downloadAndSaveBinaryFile(
        'https://docs.flutter.dev/assets/images/dash/dash-fainting.gif',
      );
      if (path != null) {
        showHowtoPullSavedFile(path);
      }
    });
  }

  @override
  Widget build(BuildContext context) => const FlutterLogo();
}

/// Downloads binary data from [url] and saves it to external storage.
Future<String?> downloadAndSaveBinaryFile(String url) async {
  final bytes = await downloadBinaryFile(url);
  return await saveBinaryFileToExternalStorageDirectory(bytes, p.basename(url));
}
