import 'package:flutter/widget_previews.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a [Slidable] list example with swipe-to-delete actions.
@Preview(group: 'Widgets', name: 'Slidable List')
Widget preview() => const _MyStatefulWidget();

class const _MyStatefulWidget() extends StatefulWidget {
  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  final List<_MyData> _list = List<_MyData>.generate(
    20,
    (index) => (id: index, text: index.toString()),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _SlidableListView<_MyData, int>(
      list: _list,
      getKey: (item) => item.id,
      getString: (item) => item.text,
      onPressed: (item) => setState(() => _list.remove(item)),
    ),
  );
}

class const _SlidableListView<T, K>({
  required final List<T> list,
  required final K Function(T item) getKey,
  required final String Function(T item) getString,
  required final void Function(T item) onPressed,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListView.builder(
    itemCount: list.length,
    itemBuilder: (context, index) {
      final item = list[index];
      return _SlidableTile(
        key: ValueKey(getKey(item)),
        text: getString(item),
        onPressed: (_) => onPressed(item),
      );
    },
  );
}

class const _SlidableTile({
  required final String text,
  required final SlidableActionCallback onPressed,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Slidable(
    endActionPane: ActionPane(
      extentRatio: 0.2,
      motion: const ScrollMotion(),
      children: <SlidableAction>[
        SlidableAction(
          backgroundColor: Colors.red,
          onPressed: onPressed,
          label: 'Delete',
          // According to my experiment, when null is passed,
          // non-trivial padding appears.
          padding: .zero,
        ),
      ],
    ),
    child: ListTile(title: Text(text)),
  );
}

typedef _MyData = ({int id, String text});
