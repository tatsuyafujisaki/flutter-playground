import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/ui/example/io/download_file_example.dart';
import 'package:material_ui/material_ui.dart';

/// Previews an [Image.memory] widget with offline sample bytes and an optional
/// remote download action.
@Preview(group: 'Widgets', name: 'Image.memory')
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  static const _remoteImageUrl = 'https://media1.tenor.com/m/NVP2kRD7CHsAAAAC';

  // 2x2 PNG checkerboard sample so the preview renders offline without network.
  static final _samplePngBytes = Uint8List.fromList(const [
    137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, //
    0, 0, 0, 2, 0, 0, 0, 2, 8, 6, 0, 0, 0, 114, 182, 13,
    36, 0, 0, 0, 22, 73, 68, 65, 84, 120, 218, 99, 96, 10, 155, 253,
    95, 120, 231, 223, 255, 12, 32, 2, 196, 1, 0, 78, 226, 9, 117, 162,
    112, 223, 71, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
  ]);

  Uint8List _imageBytes = _samplePngBytes;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _downloadImage() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final bytes = await downloadBinaryFile(_remoteImageUrl);
      if (!mounted) {
        return;
      }
      setState(() {
        _imageBytes = bytes;
        _isLoading = false;
      });
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to download image',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to download image: $error';
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
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Image.memory(
              _imageBytes,
              width: 120,
              height: 120,
              fit: .cover,
              filterQuality: .none,
            ),
          FilledButton(
            onPressed: _isLoading ? null : () => unawaited(_downloadImage()),
            child: const Text('Download Remote Image'),
          ),
          if (_errorMessage case final errorMessage?)
            Text(errorMessage, textAlign: .center),
        ],
      ),
    ),
  );
}
