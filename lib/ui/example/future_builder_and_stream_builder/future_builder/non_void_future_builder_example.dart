import 'package:flutter/material.dart';
import 'package:flutter_playground/ui/example/future_builder_and_stream_builder/future_builder/create_non_void_future_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(
  ProviderScope(
    child: MaterialApp(home: Scaffold(body: _MyStatelessWidget())),
  ),
);

class _MyStatelessWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) => createNonVoidFutureBuilder<String>(
    future: Future<String>.delayed(const Duration(seconds: 5), () => '🍎'),
    onData: (data) => Center(child: Text(data)),
  );
}
