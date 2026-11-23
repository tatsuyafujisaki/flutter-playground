import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

/// A reusable [Fake] implementation of [Dio] for unit tests.
class FakeDio({
  /// Handler invoked by [get].
  var Future<Response<dynamic>> Function(String path, Options? options)? onGet,

  /// Handler invoked by [getUri].
  var Future<Response<dynamic>> Function(Uri uri, Options? options)? onGetUri,

  /// Handler invoked by [headUri].
  var Future<Response<dynamic>> Function(Uri uri, Options? options)? onHeadUri,

  /// Handler invoked by [post].
  var Future<Response<dynamic>> Function(String path, Object? data)? onPost,

  /// Handler invoked by [put].
  var Future<Response<dynamic>> Function(String path, Object? data)? onPut,

  /// Handler invoked by [delete].
  var Future<Response<dynamic>> Function(String path)? onDelete,
}) extends Fake implements Dio {
  /// Creates a [FakeDio] with optional method handlers.
  this;

  /// Whether [close] has been called on this instance.
  bool isClosed = false;

  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async => _castResponse<T>(await onGet!(path, options));

  @override
  Future<Response<T>> getUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async => _castResponse<T>(await onGetUri!(uri, options));

  @override
  Future<Response<T>> headUri<T>(
    Uri uri, {
    Object? data,
    Options? options,
    CancelToken? cancelToken,
  }) async => _castResponse<T>(await onHeadUri!(uri, options));

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => _castResponse<T>(await onPost!(path, data));

  @override
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async => _castResponse<T>(await onPut!(path, data));

  @override
  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async => _castResponse<T>(await onDelete!(path));

  @override
  void close({bool force = false}) {
    isClosed = true;
  }

  Response<T> _castResponse<T>(Response<dynamic> response) => Response<T>(
    requestOptions: response.requestOptions,
    data: response.data as T?,
    statusCode: response.statusCode,
    statusMessage: response.statusMessage,
  );
}
