import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews widgets aligned to the left, center, and right in a [Stack].
@Preview()
Widget preview() => const _MyStatelessWidget();

class _MyStatelessWidget extends StatelessWidget {
  const _MyStatelessWidget();

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _leftCenterRightWidgetStack(
          leftWidget: const FlutterLogo(),
          centerWidget: const FlutterLogo(),
        ),
        _leftCenterRightWidgetStack(
          centerWidget: const FlutterLogo(),
          rightWidget: const FlutterLogo(),
        ),
        _leftCenterRightWidgetStack(
          leftWidget: const FlutterLogo(),
          centerWidget: const FlutterLogo(),
          rightWidget: const FlutterLogo(),
        ),
      ],
    ),
  );
}

Stack _leftCenterRightWidgetStack({
  Widget? leftWidget,
  Widget? centerWidget,
  Widget? rightWidget,
}) => Stack(
  alignment: Alignment.center,
  children: <Widget>[
    if (leftWidget != null)
      Align(alignment: Alignment.centerLeft, child: leftWidget),
    ?centerWidget,
    if (rightWidget != null)
      Align(alignment: Alignment.centerRight, child: rightWidget),
  ],
);
