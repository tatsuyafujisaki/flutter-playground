import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a full-height modal bottom sheet using [showModalBottomSheet].
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
          // stretches the bottom sheet to full height.
          isScrollControlled: true,
          // avoids the bottom sheet of full height
          // from overlapping the status bar.
          useSafeArea: true,
        ),
        icon: const Icon(Icons.flutter_dash),
      ),
    ),
  );
}

class const _BottomSheetContent() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close),
      ),
      title: const Text('My title'),
    ),
    body: const Center(child: FlutterLogo()),
  );
}
