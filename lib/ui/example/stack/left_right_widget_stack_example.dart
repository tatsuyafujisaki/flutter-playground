import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

/// Previews widgets aligned to the left and right in a [Row].
@Preview()
Widget preview() => const _MyStatelessWidget();

class _MyStatelessWidget extends StatelessWidget {
  const _MyStatelessWidget();

  @override
  Widget build(BuildContext context) => const MaterialApp(
    home: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[FlutterLogo(), FlutterLogo()],
    ),
  );
}
