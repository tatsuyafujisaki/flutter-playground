import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/ui/example/future_builder_and_stream_builder/future_builder/create_void_future_builder.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a void [FutureBuilder] example.
@Preview()
Widget preview() => _MyStatelessWidget();

class _MyStatelessWidget extends StatelessWidget {
  new();

  final _future = Future<void>.delayed(const Duration(seconds: 5), () {});

  @override
  Widget build(BuildContext context) => createVoidFutureBuilder(
    future: _future,
    onData: () => const Center(child: FlutterLogo()),
  );
}
