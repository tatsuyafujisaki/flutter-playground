import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/packages/permission_handler_example.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Previews selecting multiple images with [ImagePicker].
@Preview(group: 'Widgets', name: 'Image Picker')
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  bool _isPicking = false;
  String? _status;

  Future<void> _pickImages() async {
    setState(() {
      _isPicking = true;
      _status = null;
    });
    try {
      if (!kIsWeb && !await isPhotoGranted) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isPicking = false;
          _status = 'Photo permission was not granted.';
        });
        return;
      }
      final images = await ImagePicker().pickMultiImage(limit: 3);
      for (final image in images) {
        developer.log('👀XFile > path: ${image.path}');
        developer.log('👀XFile > name: ${image.name}');

        // Always null, except for the web platform.
        // https://github.com/flutter/flutter/issues/144900#issuecomment-1987332347
        developer.log('👀XFile > mimeType: ${image.mimeType}');
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _isPicking = false;
        _status = images.isEmpty
            ? 'No images selected.'
            : 'Selected ${images.length} image(s): '
                  '${images.map((image) => image.name).join(', ')}';
      });
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to pick images',
        error: error,
        stackTrace: stackTrace,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _isPicking = false;
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
            onPressed: _isPicking ? null : () => unawaited(_pickImages()),
            child: Text(_isPicking ? 'Picking...' : 'Pick Images'),
          ),
          if (_status case final status?) Text(status, textAlign: .center),
        ],
      ),
    ),
  );
}
