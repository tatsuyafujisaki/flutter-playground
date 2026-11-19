import 'package:flutter/material.dart';
import 'package:flutter_playground/ui/example/future_builder_and_stream_builder/future_builder/create_void_future_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(
  ProviderScope(
    child: MaterialApp(home: Scaffold(body: _MyStatelessWidget())),
  ),
);

class _MyStatelessWidget extends StatelessWidget {
  final _future = Future<void>.delayed(const Duration(seconds: 5), () {});

  @override
  Widget build(BuildContext context) => createVoidFutureBuilder(
    future: _future,
    onData: () => const Center(child: FlutterLogo()),
  );
}
