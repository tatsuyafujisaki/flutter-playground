import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dio.g.dart';

const _timeout = Duration(seconds: 10);

/// Provides the [Dio] client shared by all HTTP requests in this app.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final dio = Dio(
    BaseOptions(
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
      sendTimeout: _timeout,
    ),
  );
  ref.onDispose(dio.close);
  return dio;
}
