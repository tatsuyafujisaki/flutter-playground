import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(
  const ProviderScope(
    child: MaterialApp(
      home: SafeArea(child: Scaffold(body: _MyStatelessWidget())),
    ),
  ),
);

class _MyStatelessWidget extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      developer.log('🍎');
    });
    unawaited(
      Future.microtask(() {
        developer.log('🍊');
      }),
    );
    unawaited(
      Future.delayed(Duration.zero, () {
        developer.log('🍇');
      }),
    );
    return const FlutterLogo();
  }
}
