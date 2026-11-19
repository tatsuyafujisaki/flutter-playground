import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews widgets aligned to the left and right in a [Row].
@Preview()
Widget preview() => const _MyStatelessWidget();

class _MyStatelessWidget extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[FlutterLogo(), FlutterLogo()],
    ),
  );
}
