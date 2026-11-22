import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews [Tooltip] widgets displayed programmatically.
@Preview()
Widget preview() => const _MyStatefulWidget();

class _MyStatefulWidget extends StatefulWidget {
  const new();

  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  final _firstTooltipKey = GlobalKey<TooltipState>();
  final _secondTooltipKey = GlobalKey<TooltipState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _firstTooltipKey.currentState?.ensureTooltipVisible();
      _secondTooltipKey.currentState?.ensureTooltipVisible();
    });
  }

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: .center,
      children: [
        Tooltip(
          key: _firstTooltipKey,
          message: 'Tooltip!',
          decoration: const BoxDecoration(color: Colors.white),
          textStyle: const TextStyle(color: Colors.black),
          child: const FlutterLogo(),
        ),
        Tooltip(
          key: _secondTooltipKey,
          message: 'Tooltip!',
          decoration: const BoxDecoration(color: Colors.white),
          textStyle: const TextStyle(color: Colors.black),
          child: const FlutterLogo(),
        ),
      ],
    ),
  );
}
