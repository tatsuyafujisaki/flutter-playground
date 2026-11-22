import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a template widget that logs post-frame, microtask, and delayed
/// callbacks.
@Preview()
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  @override
  void initState() {
    super.initState();
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
  }

  @override
  Widget build(BuildContext context) => const FlutterLogo();
}
