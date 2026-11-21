import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews recommended [Text] overflow and line-clamping configurations.
@Preview()
Widget preview() => const _MyStatelessWidget();

/// Note of the Text widget:
/// - The [Text.softWrap] is true.
/// - If [TextOverflow.ellipsis] is NOT set, the default [Text.maxLines] is
///   infinite.
/// - If [TextOverflow.ellipsis] is set, the default [Text.maxLines] is 1.
class _MyStatelessWidget extends StatelessWidget {
  const new();

  static final String _data = '⭐' * 100;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: .spaceEvenly,
    children: <Widget>[
      const Text('''↓Use the following if you want to display all the text.'''),
      Text(_data),
      const Text(
        '''↓Use the following if you want to ellipsize text on a single line.''',
      ),
      Text(_data, overflow: .ellipsis),
      const Text(
        '''↓Use the following if you want to ellipsize text on `maxLines` lines.''',
      ),
      Text(_data, overflow: .ellipsis, maxLines: 2),
    ],
  );
}
