import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a modal bottom sheet containing a [ListView].
@Preview()
Widget preview() => const _MyStatelessWidget();

class _MyStatelessWidget extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: IconButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          builder: (_) => _BottomSheetContent(),
        ),
        icon: const Icon(Icons.open_in_new),
      ),
    ),
  );
}

class _BottomSheetContent extends StatelessWidget {
  new();

  final List<int> indices = List<int>.generate(100, (index) => index).toList();

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      for (final i in indices)
        ListTile(title: Text('Item $i'), tileColor: Colors.amber),
    ],
  );
}
