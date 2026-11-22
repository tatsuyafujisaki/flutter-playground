import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_playground/data/model/album.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'album_repository.g.dart';

const _baseUrl = 'https://jsonplaceholder.typicode.com';

/// Provides the singleton [AlbumRepository] instance.
@Riverpod(keepAlive: true)
AlbumRepository albumRepository(Ref ref) {
  final dio = Dio(BaseOptions(baseUrl: _baseUrl));
  ref.onDispose(dio.close);
  return AlbumRepository(dio);
}

/// A repository for performing CRUD operations on [Album] resources.
class const AlbumRepository(final Dio _dio) {
  /// Creates an [AlbumRepository] with the given [Dio] client.
  this;

  /// https://docs.flutter.dev/cookbook/networking/fetch-data#2-make-a-network-request
  Future<List<Album>> getAlbums() async {
    final data = await _fetch(
      'Failed to get albums.',
      () => _dio.get<List<dynamic>>('/albums'),
    );
    return data
        .map((map) => Album.fromJson(map as Map<String, dynamic>))
        .toList();
  }

  /// https://docs.flutter.dev/cookbook/networking/fetch-data#2-make-a-network-request
  Future<Album> getAlbum({required int id}) async => Album.fromJson(
    await _fetch(
      'Failed to get an album.',
      () => _dio.get<Map<String, dynamic>>('/albums/$id'),
    ),
  );

  /// https://docs.flutter.dev/cookbook/networking/send-data#convert-the-http-response-to-an-album
  Future<Album> postAlbum({required Map<String, dynamic> body}) async =>
      Album.fromJson(
        await _fetch(
          'Failed to post an album.',
          () => _dio.post<Map<String, dynamic>>('/albums', data: body),
        ),
      );

  /// https://docs.flutter.dev/cookbook/networking/update-data#2-updating-data-over-the-internet-using-the-http-package
  Future<Album> updateAlbum({
    required int id,
    required Map<String, dynamic> body,
  }) async => Album.fromJson(
    await _fetch(
      'Failed to update an album.',
      () => _dio.put<Map<String, dynamic>>('/albums/$id', data: body),
    ),
  );

  /// https://docs.flutter.dev/cookbook/networking/delete-data#2-delete-data-on-the-server
  Future<void> deleteAlbum({required int id}) => _send(
    'Failed to delete an album.',
    () => _dio.delete<void>('/albums/$id'),
  );

  /// Sends a request with [send], logging the response and throwing an
  /// [Exception] with [failureMessage] if Dio reports an error.
  Future<Response<T>> _send<T>(
    String failureMessage,
    Future<Response<T>> Function() send,
  ) async {
    try {
      return await send();
    } on DioException catch (error) {
      if (error.response case final response?) {
        _log(response);
      }
      throw Exception(failureMessage);
    }
  }

  /// Like [_send], but also throws if the response has no data.
  Future<T> _fetch<T>(
    String failureMessage,
    Future<Response<T>> Function() send,
  ) async {
    final response = await _send(failureMessage, send);
    if (response.data case final data?) {
      return data;
    }
    _log(response);
    throw Exception(failureMessage);
  }

  void _log(Response<dynamic> response) {
    developer.log('👀response.requestOptions: ${response.requestOptions}');
    developer.log('👀response.statusCode: ${response.statusCode}');
    developer.log('👀response.statusMessage: ${response.statusMessage}');
    developer.log('👀response.headers: ${response.headers}');
    developer.log('👀response.data: ${response.data}');
  }
}
