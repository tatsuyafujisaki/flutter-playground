import 'dart:developer' as developer;

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a [StreamBuilder] displaying periodic counter events.
@Preview(group: 'Async', name: 'StreamBuilder')
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  late final Stream<String> _countStream;

  @override
  void initState() {
    super.initState();
    _countStream = Stream<String>.periodic(
      const Duration(seconds: 1),
      (count) => '$count!',
    );
  }

  @override
  Widget build(BuildContext context) => Center(
    child: StreamBuilder<String>(
      stream: _countStream,
      builder: (context, snapshot) {
        switch (snapshot) {
          case AsyncSnapshot(:final data?):
            return Text(data);
          case AsyncSnapshot(:final error?, :final stackTrace):
            developer.log(
              'StreamBuilder error',
              error: error,
              stackTrace: stackTrace,
            );
            return const Icon(Icons.error);
          case AsyncSnapshot():
            return const CircularProgressIndicator();
        }
      },
    ),
  );
}
