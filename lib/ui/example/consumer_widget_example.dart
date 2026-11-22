import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/ui/view_model/album_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a [ConsumerWidget] that displays albums from [AlbumViewModel].
@Preview()
Widget preview() => const ProviderScope(child: _MyConsumerWidget());

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
