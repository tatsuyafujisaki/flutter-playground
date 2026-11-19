import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';

/// Whether the device can resolve a host over the network.
Future<bool> get isOnline async {
  try {
    final internetAddresses = await InternetAddress.lookup('example.com');
    return internetAddresses.firstOrNull?.rawAddress.isNotEmpty ?? false;
  } on Exception catch (error, stackTrace) {
    developer.log('', error: error, stackTrace: stackTrace);
    return false;
  }
}

/// Checks whether [url] responds with a 2xx HTTP status code.
Future<bool> isUrlAccessible(String url, {Dio? dio}) async {
  final client =
      dio ??
      Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
  try {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return false;
    }

    final response = await client.headUri<void>(
      uri,
      options: Options(validateStatus: (_) => true),
    );
    switch (response.statusCode) {
      case final int statusCode when statusCode >= 200 && statusCode < 300:
        return true;
      case 405:
        final response2 = await client.getUri<void>(
          uri,
          options: Options(validateStatus: (_) => true),
        );
        final statusCode = response2.statusCode;
        return statusCode != null && statusCode >= 200 && statusCode < 300;
    }
  } on Exception catch (error, stackTrace) {
    developer.log('', error: error, stackTrace: stackTrace);
  } finally {
    if (dio == null) {
      client.close();
    }
  }
  return false;
}
