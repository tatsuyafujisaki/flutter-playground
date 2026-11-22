import 'package:flutter/widget_previews.dart';
import 'package:flutter_playground/ui/view_model/album_view_model.dart';
import 'package:material_ui/material_ui.dart';

/// Previews a [StatefulWidget] that displays albums from [AlbumViewModel].
@Preview()
Widget preview() => const _MyStatefulWidget();

class _MyStatefulWidget extends StatefulWidget {
  const new();

  @override
  State<_MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<_MyStatefulWidget> {
  final albumViewModel = AlbumViewModel();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => albumViewModel.fetchAlbums(),
    );
  }

  @override
  void dispose() {
    albumViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: ListenableBuilder(
        listenable: albumViewModel,
        builder: (context, child) => ListView.separated(
          separatorBuilder: (context, index) => const Divider(),
          itemCount: albumViewModel.albums.length,
          itemBuilder: (context, index) =>
              Text(albumViewModel.albums[index].title ?? ''),
        ),
      ),
    ),
  );
}
