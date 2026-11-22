import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews [Text] wrapping, truncation, and ellipsis behavior.
@Preview(group: 'Text', name: 'Text Wrapping & Overflow')
Widget preview() => const _MyStatelessWidget();

/// Note of the Text widget:
/// - The [Text.softWrap] is true.
/// - If [TextOverflow.ellipsis] is NOT set, the default [Text.maxLines] is
///   infinite.
/// - If [TextOverflow.ellipsis] is set, the default [Text.maxLines] is 1.
class const _MyStatelessWidget() extends StatelessWidget {
  static final String _data = '⭐' * 100;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: .spaceEvenly,
    children: <Widget>[
      const Text('↓Displays all the text.'),
      Text(_data),
      const Text(
        '''↓Truncates text if it does not fit on a single line because of `softWrap: false`.''',
      ),
      Text(_data, softWrap: false),
      const Text(
        '''↓Truncates text if it does not fit on a single line because of `softWrap: false`. `maxLines: 2` is ignored.''',
      ),
      Text(_data, softWrap: false, maxLines: 2),
      const Text(
        '''↓Ellipsizes text if it does not fit on a single line because of `TextOverflow.ellipsis`.''',
      ),
      Text(_data, overflow: .ellipsis),
      const Text(
        '''↓Ellipsizes text if it does not fit on a single line because of `TextOverflow.ellipsis` again.''',
      ),
      Text(_data, softWrap: false, overflow: .ellipsis),
      const Text(
        '''↓Ellipsizes text if it does not fit on `maxLines` lines. `softWrap: false` is ignored.''',
      ),
      Text(_data, softWrap: false, overflow: .ellipsis, maxLines: 2),
    ],
  );
}
