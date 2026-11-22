import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a [DraggableScrollableSheet] example.
@Preview(group: 'Bottom Sheet', name: 'Draggable Scrollable Sheet')
Widget preview() => DraggableScrollableSheet(
  initialChildSize: 0.7,
  builder: (context, scrollController) => ColoredBox(
    color: Colors.cyan,
    child: ListView.builder(
      controller: scrollController,
      itemCount: 25,
      itemBuilder: (context, index) => ListTile(
        title: Text('Item $index', style: const TextStyle(color: Colors.white)),
      ),
    ),
  ),
);
