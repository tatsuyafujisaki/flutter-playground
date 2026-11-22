import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/ui/example/future_builder_and_stream_builder/create_stream_builder.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a [StreamBuilder] displaying periodic counter events.
@Preview(group: 'Async', name: 'StreamBuilder')
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  final _countStream = Stream<String>.periodic(
    const Duration(seconds: 1),
    (count) => '$count!',
  );

  @override
  Widget build(BuildContext context) => createStreamBuilder<String>(
    stream: _countStream,
    onData: (data) => Center(child: Text(data)),
  );
}
