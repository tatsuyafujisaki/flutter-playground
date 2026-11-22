import 'package:flutter/widget_previews.dart';
import 'package:material_ui/material_ui.dart';

/// Previews full-width [Text] layout examples.
@Preview()
Widget preview() => const _MyStatelessWidget();

class const _MyStatelessWidget() extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Column(
      mainAxisAlignment: .center,
      children: [
        Text(
          '🍎',
          style: TextStyle(backgroundColor: Colors.cyan),
          textAlign: .end,
        ),
        SizedBox(
          width: double.infinity,
          child: Text(
            '🍏',
            style: TextStyle(backgroundColor: Colors.cyan),
            textAlign: .end,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(color: Colors.red),
            child: Text(
              '🍊',
              style: TextStyle(backgroundColor: Colors.cyan),
              textAlign: .end,
            ),
          ),
        ),
      ],
    ),
  );
}
