import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/ui/example/future_builder_and_stream_builder/future_builder/create_non_void_future_builder.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a non-void [FutureBuilder] example.
@Preview(group: 'Async', name: 'Non-Void FutureBuilder')
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  final _future = Future<String>.delayed(
    const Duration(seconds: 5),
    () => '🍎',
  );

  @override
  Widget build(BuildContext context) => createNonVoidFutureBuilder<String>(
    future: _future,
    onData: (data) => Center(child: Text(data)),
  );
}
