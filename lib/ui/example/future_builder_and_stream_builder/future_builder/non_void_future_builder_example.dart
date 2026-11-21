import 'package:flutter_playground/ui/example/future_builder_and_stream_builder/future_builder/create_non_void_future_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(
  const ProviderScope(
    child: MaterialApp(home: Scaffold(body: _MyStatelessWidget())),
  ),
);

class _MyStatelessWidget extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => createNonVoidFutureBuilder<String>(
    future: Future<String>.delayed(const Duration(seconds: 5), () => '🍎'),
    onData: (data) => Center(child: Text(data)),
  );
}
