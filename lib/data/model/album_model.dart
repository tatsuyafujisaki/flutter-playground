import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter_playground/data/model/album.dart';

const _baseUrl = 'https://jsonplaceholder.typicode.com';

/// A client for performing CRUD operations on albums.
class AlbumModel({Dio? dio}) {
  /// Creates an [AlbumModel] with an optional [Dio] client.
  this;

  final Dio _dio = dio ?? Dio(BaseOptions(baseUrl: _baseUrl));

  /// https://docs.flutter.dev/cookbook/networking/fetch-data#2-make-a-network-request
  Future<List<Album>> getAlbums() async {
    try {
      final response = await _dio.get<List<dynamic>>('/albums');
      final data = response.data;
      if (data != null) {
        return data
            .map((map) => Album.fromJson(map as Map<String, dynamic>))
            .toList();
      }
      _log(response);
      throw Exception('Failed to get albums.');
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        _log(response);
      }
      throw Exception('Failed to get albums.');
    }
  }

  /// https://docs.flutter.dev/cookbook/networking/fetch-data#2-make-a-network-request
  Future<Album> getAlbum({required int id}) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/albums/$id');
      final data = response.data;
      if (data != null) {
        return Album.fromJson(data);
      }
      _log(response);
      throw Exception('Failed to get an album.');
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        _log(response);
      }
      throw Exception('Failed to get an album.');
    }
  }

  /// https://docs.flutter.dev/cookbook/networking/send-data#convert-the-http-response-to-an-album
  Future<Album> postAlbum({required Map<String, dynamic> body}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/albums',
        data: body,
      );
      final data = response.data;
      if (data != null) {
        return Album.fromJson(data);
      }
      _log(response);
      throw Exception('Failed to post an album.');
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        _log(response);
      }
      throw Exception('Failed to post an album.');
    }
  }

  /// https://docs.flutter.dev/cookbook/networking/update-data#2-updating-data-over-the-internet-using-the-http-package
  Future<Album> updateAlbum({
    required int id,
    required Map<String, dynamic> body,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        '/albums/$id',
        data: body,
      );
      final data = response.data;
      if (data != null) {
        return Album.fromJson(data);
      }
      _log(response);
      throw Exception('Failed to update an album.');
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        _log(response);
      }
      throw Exception('Failed to update an album.');
    }
  }

  /// https://docs.flutter.dev/cookbook/networking/delete-data#2-delete-data-on-the-server
  Future<void> deleteAlbum({required int id}) async {
    try {
      await _dio.delete<void>('/albums/$id');
    } on DioException catch (error) {
      final response = error.response;
      if (response != null) {
        _log(response);
      }
      throw Exception('Failed to delete an album.');
    }
  }

  void _log(Response<dynamic> response) {
    developer.log('👀response.requestOptions: ${response.requestOptions}');
    developer.log('👀response.statusCode: ${response.statusCode}');
    developer.log('👀response.statusMessage: ${response.statusMessage}');
    developer.log('👀response.headers: ${response.headers}');
    developer.log('👀response.data: ${response.data}');
  }
}

void main() async {
  final albumModel = AlbumModel();

  final albums = await albumModel.getAlbums();
  final album = await albumModel.getAlbum(id: 1);
  final postedAlbum = await albumModel.postAlbum(
    body: <String, dynamic>{'userId': 42, 'title': 'My posted album'},
  );
  final updatedAlbum = await albumModel.updateAlbum(
    id: 1,
    body: <String, dynamic>{'userId': 99, 'title': 'My updated album'},
  );

  developer.log(albums.toString());
  developer.log(album.toString());
  developer.log(postedAlbum.toString());
  developer.log(updatedAlbum.toString());
  await albumModel.deleteAlbum(id: 1);
}
