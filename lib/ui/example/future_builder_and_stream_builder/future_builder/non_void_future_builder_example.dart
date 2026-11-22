import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/ui/example/future_builder_and_stream_builder/future_builder/create_non_void_future_builder.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a non-void [FutureBuilder] example.
@Preview()
Widget preview() => const _MyStatelessWidget();

class _MyStatelessWidget extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => createNonVoidFutureBuilder<String>(
    future: Future<String>.delayed(const Duration(seconds: 5), () => '🍎'),
    onData: (data) => Center(child: Text(data)),
  );
}
