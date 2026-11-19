import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews an [OutlinedButton] with a rounded rectangular shape.
@Preview()
Widget ovalOutlinedButtonExample() => OutlinedButton(
  onPressed: () {},
  style: OutlinedButton.styleFrom(
    backgroundColor: Colors.yellow,
    side: const BorderSide(color: Colors.red),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  child: const Text('Click me!', style: TextStyle(color: Colors.red)),
);
