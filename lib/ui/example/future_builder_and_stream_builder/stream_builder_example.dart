import 'dart:developer' as developer;

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a [StreamBuilder] displaying periodic counter events.
@Preview()
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
        if (snapshot.hasData) {
          return Text(snapshot.data!);
        }
        if (snapshot.hasError) {
          developer.log(snapshot.error.toString());
          developer.log(snapshot.stackTrace.toString());
          return const Icon(Icons.error);
        }
        return const CircularProgressIndicator();
      },
    ),
  );
}
