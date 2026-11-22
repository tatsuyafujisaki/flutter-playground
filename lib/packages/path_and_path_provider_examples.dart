import 'package:flutter_playground/packages/io/save_file_example.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() =>
    runApp(const ProviderScope(child: MaterialApp(home: _MyStatefulWidget())));

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
