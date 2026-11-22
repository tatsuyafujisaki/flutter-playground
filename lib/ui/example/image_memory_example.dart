import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/packages/io/download_file_example.dart';
import 'package:material_ui/material_ui.dart';

/// Previews an [Image.memory] widget displaying downloaded binary image bytes.
@Preview()
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  late final Future<Uint8List> _imageBytes;

  @override
  void initState() {
    super.initState();
    _imageBytes = downloadBinaryFile(
      'https://media1.tenor.com/m/NVP2kRD7CHsAAAAC',
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: _imageBytes,
    builder: (context, snapshot) {
      switch (snapshot) {
        case AsyncSnapshot(:final data?):
          return Image.memory(data);
        case AsyncSnapshot(:final error?, :final stackTrace):
          developer.log(
            'Failed to download image',
            error: error,
            stackTrace: stackTrace,
          );
          return const Icon(Icons.broken_image);
        case AsyncSnapshot():
          return const CircularProgressIndicator();
      }
    },
  );
}
