import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a template widget that logs post-frame, microtask, and delayed
/// callbacks.
@Preview()
Widget preview() => const _MyStatelessWidget();

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
      Future.delayed(.zero, () {
        developer.log('🍇');
      }),
    );
    return const FlutterLogo();
  }
}
