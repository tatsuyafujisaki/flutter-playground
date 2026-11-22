import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a modal bottom sheet containing a [ListView].
@Preview()
Widget preview() => const _MyStatelessWidget();

class const _MyStatelessWidget() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: IconButton(
        onPressed: () => showModalBottomSheet<void>(
          context: context,
          builder: (_) => const _BottomSheetContent(),
        ),
        icon: const Icon(Icons.open_in_new),
      ),
    ),
  );
}

class const _BottomSheetContent() extends StatelessWidget {
  static final List<int> _indices = List<int>.generate(100, (index) => index);

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      for (final i in _indices)
        ListTile(title: Text('Item $i'), tileColor: Colors.amber),
    ],
  );
}
