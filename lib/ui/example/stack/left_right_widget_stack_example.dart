import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews widgets aligned to the left and right in a [Row].
@Preview(group: 'Layout', name: 'Left-Right Row')
Widget preview() => const _MyStatelessWidget();

class const _MyStatelessWidget() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Row(
    mainAxisAlignment: .spaceBetween,
    children: [FlutterLogo(), FlutterLogo()],
  );
}
