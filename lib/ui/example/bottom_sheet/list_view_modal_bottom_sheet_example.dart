import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a modal bottom sheet containing a [ListView].
@Preview(group: 'Bottom Sheet', name: 'ListView Modal Bottom Sheet')
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
  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: 100,
    itemBuilder: (context, index) =>
        ListTile(title: Text('Item $index'), tileColor: Colors.amber),
  );
}
