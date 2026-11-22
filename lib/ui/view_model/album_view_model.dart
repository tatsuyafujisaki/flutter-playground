import 'package:flutter_playground/data/model/album.dart';
import 'package:flutter_playground/data/repository/album_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'album_view_model.g.dart';

/// Fetches a single [Album] by [id].
@riverpod
Future<Album> album(Ref ref, {required int id}) =>
    ref.read(albumRepositoryProvider).getAlbum(id: id);

/// A Riverpod async notifier that manages the list of [Album] items.
@riverpod
class AlbumViewModel extends _$AlbumViewModel {
  @override
  Future<List<Album>> build() => ref.read(albumRepositoryProvider).getAlbums();

  /// Refreshes the list of albums.
  Future<void> fetchAlbums() async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref.read(albumRepositoryProvider).getAlbums(),
    );
    if (ref.mounted) {
      state = nextState;
    }
  }

  /// Creates an album from [body] and appends it to the current list.
  Future<void> postAlbum({required Map<String, dynamic> body}) async {
    final previousAlbums = state.value ?? const <Album>[];
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      final created = await ref
          .read(albumRepositoryProvider)
          .postAlbum(body: body);
      return [...previousAlbums, created];
    });
    if (ref.mounted) {
      state = nextState;
    }
  }

  /// Updates the album with the given [id] using [body].
  Future<void> updateAlbum({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    final previousAlbums = state.value ?? const <Album>[];
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      final updated = await ref
          .read(albumRepositoryProvider)
          .updateAlbum(id: id, body: body);
      return [
        for (final album in previousAlbums)
          if (album.id == id) updated else album,
      ];
    });
    if (ref.mounted) {
      state = nextState;
    }
  }

  /// Deletes the album with the given [id] and removes it from the list.
  Future<void> deleteAlbum({required int id}) async {
    final previousAlbums = state.value ?? const <Album>[];
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(() async {
      await ref.read(albumRepositoryProvider).deleteAlbum(id: id);
      return previousAlbums.where((album) => album.id != id).toList();
    });
    if (ref.mounted) {
      state = nextState;
    }
  }
}
