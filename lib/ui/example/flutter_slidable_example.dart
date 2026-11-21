import 'package:flutter/widget_previews.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a [Slidable] list example with swipe-to-delete actions.
@Preview()
Widget preview() => const _MyStatelessWidget();

class _MyStatelessWidget extends StatefulWidget {
  const new();

  @override
  State<_MyStatelessWidget> createState() => _MyStatelessWidgetState();
}

class _MyStatelessWidgetState extends State<_MyStatelessWidget> {
  final List<_MyData> _list = List<_MyData>.generate(
    20,
    (index) => _MyData(id: index, text: index.toString()),
  ).toList();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _slidableListView<_MyData, int>(
      context: context,
      list: _list,
      getKey: (item) => item.id,
      getString: (item) => item.text,
      onPressed: (item) =>
          setState(() => _list.removeWhere((element) => element == item)),
    ),
  );
}

ListView _slidableListView<T, K>({
  required BuildContext context,
  required List<T> list,
  required K Function(T item) getKey,
  required String Function(T item) getString,
  required void Function(T item) onPressed,
}) => ListView(
  children: [
    for (final (index, item) in list.indexed)
      _slidable<int>(
        key: index,
        text: getString(item),
        onPressed: (context) {
          onPressed(item);
        },
      ),
  ],
);

Slidable _slidable<T>({
  required T key,
  required String text,
  required SlidableActionCallback onPressed,
}) => Slidable(
  key: ValueKey(key),
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

class _MyData({required final int id, required final String text});
