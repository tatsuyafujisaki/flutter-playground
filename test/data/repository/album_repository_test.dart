import 'package:dio/dio.dart';
import 'package:flutter_playground/data/model/album.dart';
import 'package:flutter_playground/data/repository/album_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeDio extends Fake implements Dio {
  Future<Response<dynamic>> Function(String path)? onGet;
  Future<Response<dynamic>> Function(String path, Object? data)? onPost;
  Future<Response<dynamic>> Function(String path, Object? data)? onPut;
  Future<Response<dynamic>> Function(String path)? onDelete;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await onGet!(path);
    return Response<T>(
      requestOptions: response.requestOptions,
      data: response.data as T?,
      statusCode: response.statusCode,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await onPost!(path, data);
    return Response<T>(
      requestOptions: response.requestOptions,
      data: response.data as T?,
      statusCode: response.statusCode,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    final response = await onPut!(path, data);
    return Response<T>(
      requestOptions: response.requestOptions,
      data: response.data as T?,
      statusCode: response.statusCode,
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    final response = await onDelete!(path);
    return Response<T>(
      requestOptions: response.requestOptions,
      data: response.data as T?,
      statusCode: response.statusCode,
    );
  }
}

Response<T> _response<T>(String path, T? data, {int statusCode = 200}) =>
    Response<T>(
      requestOptions: RequestOptions(path: path),
      data: data,
      statusCode: statusCode,
    );

void main() {
  group('AlbumRepository', () {
    late _FakeDio dio;
    late AlbumRepository repository;

    setUp(() {
      dio = _FakeDio();
      repository = AlbumRepository(dio);
    });

    test('getAlbums parses album list from response', () async {
      dio.onGet = (path) async {
        expect(path, '/albums');
        return _response<List<dynamic>>(path, const [
          {'userId': 1, 'id': 1, 'title': 'First'},
          {'userId': 1, 'id': 2, 'title': 'Second'},
        ]);
      };

      final albums = await repository.getAlbums();
      expect(albums, const [
        Album(userId: 1, id: 1, title: 'First'),
        Album(userId: 1, id: 2, title: 'Second'),
      ]);
    });

    test('getAlbum parses single album from response', () async {
      dio.onGet = (path) async {
        expect(path, '/albums/5');
        return _response<Map<String, dynamic>>(path, const {
          'userId': 2,
          'id': 5,
          'title': 'Solo',
        });
      };

      final album = await repository.getAlbum(id: 5);
      expect(album, const Album(userId: 2, id: 5, title: 'Solo'));
    });

    test('postAlbum sends body and parses created album', () async {
      dio.onPost = (path, data) async {
        expect(path, '/albums');
        expect(data, {'title': 'Created'});
        return _response<Map<String, dynamic>>(path, const {
          'userId': 1,
          'id': 101,
          'title': 'Created',
        });
      };

      final album = await repository.postAlbum(body: {'title': 'Created'});
      expect(album, const Album(userId: 1, id: 101, title: 'Created'));
    });

    test('updateAlbum sends body and parses updated album', () async {
      dio.onPut = (path, data) async {
        expect(path, '/albums/3');
        expect(data, {'title': 'Updated'});
        return _response<Map<String, dynamic>>(path, const {
          'userId': 1,
          'id': 3,
          'title': 'Updated',
        });
      };

      final album = await repository.updateAlbum(
        id: 3,
        body: {'title': 'Updated'},
      );
      expect(album, const Album(userId: 1, id: 3, title: 'Updated'));
    });

    test('deleteAlbum sends delete request', () async {
      var deletedPath = '';
      dio.onDelete = (path) async {
        deletedPath = path;
        return _response<void>(path, null);
      };

      await repository.deleteAlbum(id: 7);
      expect(deletedPath, '/albums/7');
    });

    test('throws Exception when Dio throws DioException', () async {
      dio.onGet = (path) => Future.error(
        DioException(
          requestOptions: RequestOptions(path: path),
          response: _response<String>(path, 'server error', statusCode: 500),
        ),
      );

      await expectLater(repository.getAlbums(), throwsException);
    });

    test('throws Exception when response data is null', () async {
      dio.onGet = (path) async => _response<Map<String, dynamic>>(path, null);

      await expectLater(repository.getAlbum(id: 1), throwsException);
    });
  });
}
