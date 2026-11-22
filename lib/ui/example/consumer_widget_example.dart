import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/data/model/album.dart';
import 'package:flutter_playground/ui/view_model/album_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a [ConsumerWidget] that displays albums from [AlbumViewModel].
@Preview(group: 'Widgets', name: 'Riverpod ConsumerWidget')
Widget preview() => const _PreviewScope(child: _MyConsumerWidget());

class const _PreviewScope({required final Widget child})
    extends StatefulWidget {
  @override
  State<_PreviewScope> createState() => _PreviewScopeState();
}

class _PreviewScopeState extends State<_PreviewScope> {
  late final ProviderContainer _container;

  @override
  void initState() {
    super.initState();
    _container = ProviderContainer(
      overrides: [
        albumViewModelProvider.overrideWithBuild(
          (_, _) => const [
            Album(userId: 1, id: 1, title: 'quidem molestiae enim'),
            Album(userId: 1, id: 2, title: 'sunt qui excepturi placeat culpa'),
            Album(userId: 1, id: 3, title: 'omnis laborum odio'),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _container.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      UncontrolledProviderScope(container: _container, child: widget.child);
}

class const _MyConsumerWidget() extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final albumsAsync = ref.watch(albumViewModelProvider);

    return Scaffold(
      body: switch (albumsAsync) {
        AsyncData(:final value) => ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: value.length,
          itemBuilder: (context, index) => Text(value[index].title ?? ''),
        ),
        AsyncError(:final error) => Center(child: Text('Error: $error')),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}
