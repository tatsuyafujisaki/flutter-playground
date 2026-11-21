import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews [Tooltip] widgets displayed programmatically.
@Preview()
Widget preview() => const _MyStatelessWidget();

class _MyStatelessWidget extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final key = GlobalKey<TooltipState>();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => key.currentState?.ensureTooltipVisible(),
    );

    return Center(
      child: Column(
        mainAxisAlignment: .center,
        children: [
          Tooltip(
            key: key,
            message: 'Tooltip!',
            decoration: const BoxDecoration(color: Colors.white),
            textStyle: const TextStyle(color: Colors.black),
            child: const FlutterLogo(),
          ),
          Tooltip(
            key: key,
            message: 'Tooltip!',
            decoration: const BoxDecoration(color: Colors.white),
            textStyle: const TextStyle(color: Colors.black),
            child: const FlutterLogo(),
          ),
        ],
      ),
    );
  }
}
