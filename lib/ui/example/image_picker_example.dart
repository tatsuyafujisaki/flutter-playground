import 'dart:developer' as developer;

import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/packages/permission_handler_example.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

/// Previews selecting multiple images with [ImagePicker].
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
      if (!await isPhotoGranted) {
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
    });
  }

  @override
  Widget build(BuildContext context) => const FlutterLogo();
}
