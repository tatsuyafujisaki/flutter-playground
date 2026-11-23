import 'package:flutter_playground/data/model/album.dart';
import 'package:flutter_playground/data/repository/album_repository.dart';
import 'package:flutter_playground/ui/view_model/album_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeAlbumRepository() extends Fake implements AlbumRepository {
  List<Album> albums = const [
    Album(userId: 1, id: 1, title: 'Initial 1'),
    Album(userId: 1, id: 2, title: 'Initial 2'),
  ];
  bool shouldThrow = false;

  @override
  Future<List<Album>> getAlbums() async {
    if (shouldThrow) {
      throw Exception('Failed to get albums.');
    }
    return albums;
  }

  @override
  Future<Album> getAlbum({required int id}) async {
    if (shouldThrow) {
      throw Exception('Failed to get an album.');
    }
    return albums.firstWhere((album) => album.id == id);
  }

  @override
  Future<Album> postAlbum({required Map<String, dynamic> body}) async {
    if (shouldThrow) {
      throw Exception('Failed to post an album.');
    }
    return Album(
      userId: body['userId'] as int? ?? 1,
      id: 3,
      title: body['title'] as String?,
    );
  }

  @override
  Future<Album> updateAlbum({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    if (shouldThrow) {
      throw Exception('Failed to update an album.');
    }
    return Album(
      userId: body['userId'] as int? ?? 1,
      id: id,
      title: body['title'] as String?,
    );
  }

  @override
  Future<void> deleteAlbum({required int id}) async {
    if (shouldThrow) {
      throw Exception('Failed to delete an album.');
    }
  }
}

void main() {
  group('AlbumViewModel & albumProvider', () {
    late _FakeAlbumRepository repository;
    late ProviderContainer container;

    setUp(() {
      repository = _FakeAlbumRepository();
      container = ProviderContainer(
        overrides: [albumRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);
    });

    test('albumProvider fetches a single album by id', () async {
      final result = await container.read(albumProvider(id: 2).future);
      expect(result, const Album(userId: 1, id: 2, title: 'Initial 2'));
    });

    test('build loads initial albums and fetchAlbums refreshes list', () async {
      final initial = await container.read(albumViewModelProvider.future);
      expect(initial, hasLength(2));

      repository.albums = const [Album(userId: 1, id: 10, title: 'Refreshed')];
      await container.read(albumViewModelProvider.notifier).fetchAlbums();

      expect(container.read(albumViewModelProvider).value, const [
        Album(userId: 1, id: 10, title: 'Refreshed'),
      ]);
    });

    test('postAlbum, updateAlbum, and deleteAlbum mutate state', () async {
      await container.read(albumViewModelProvider.future);
      final notifier = container.read(albumViewModelProvider.notifier);

      await notifier.postAlbum(body: {'title': 'Added'});
      expect(container.read(albumViewModelProvider).value, const [
        Album(userId: 1, id: 1, title: 'Initial 1'),
        Album(userId: 1, id: 2, title: 'Initial 2'),
        Album(userId: 1, id: 3, title: 'Added'),
      ]);

      await notifier.updateAlbum(id: 2, body: {'title': 'Edited 2'});
      expect(container.read(albumViewModelProvider).value, const [
        Album(userId: 1, id: 1, title: 'Initial 1'),
        Album(userId: 1, id: 2, title: 'Edited 2'),
        Album(userId: 1, id: 3, title: 'Added'),
      ]);

      await notifier.deleteAlbum(id: 1);
      expect(container.read(albumViewModelProvider).value, const [
        Album(userId: 1, id: 2, title: 'Edited 2'),
        Album(userId: 1, id: 3, title: 'Added'),
      ]);
    });

    test('sets AsyncError when repository action fails', () async {
      await container.read(albumViewModelProvider.future);
      repository.shouldThrow = true;

      await container.read(albumViewModelProvider.notifier).fetchAlbums();
      expect(container.read(albumViewModelProvider).hasError, isTrue);
    });
  });
}
