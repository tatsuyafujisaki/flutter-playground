import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews widgets aligned to the left, center, and right in a [Stack].
@Preview()
Widget preview() => const _MyStatelessWidget();

class const _MyStatelessWidget() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Column(
    mainAxisAlignment: .center,
    children: <Widget>[
      _LeftCenterRightWidgetStack(
        leftWidget: FlutterLogo(),
        centerWidget: FlutterLogo(),
      ),
      _LeftCenterRightWidgetStack(
        centerWidget: FlutterLogo(),
        rightWidget: FlutterLogo(),
      ),
      _LeftCenterRightWidgetStack(
        leftWidget: FlutterLogo(),
        centerWidget: FlutterLogo(),
        rightWidget: FlutterLogo(),
      ),
    ],
  );
}

class const _LeftCenterRightWidgetStack({
  final Widget? leftWidget,
  final Widget? centerWidget,
  final Widget? rightWidget,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(
    alignment: .center,
    children: <Widget>[
      if (leftWidget != null) Align(alignment: .centerLeft, child: leftWidget),
      ?centerWidget,
      if (rightWidget != null)
        Align(alignment: .centerRight, child: rightWidget),
    ],
  );
}
