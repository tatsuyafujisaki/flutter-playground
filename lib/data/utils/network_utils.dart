import 'dart:developer' as developer;
import 'dart:io';

import 'package:dio/dio.dart';

/// Whether the device can resolve a host over the network.
Future<bool> get isOnline async {
  try {
    final internetAddresses = await InternetAddress.lookup('example.com');
    return internetAddresses.firstOrNull?.rawAddress.isNotEmpty ?? false;
  } on Exception catch (error, stackTrace) {
    developer.log(
      'Failed to check online connectivity',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

/// Checks with [dio] whether [url] responds with a 2xx HTTP status code.
Future<bool> isUrlAccessible(Dio dio, String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return false;
  }

  final options = Options(validateStatus: (_) => true);
  try {
    final response = await dio.headUri<void>(uri, options: options);
    return switch (response.statusCode) {
      final statusCode when _isSuccessful(statusCode) => true,
      405 => _isSuccessful(
        (await dio.getUri<void>(uri, options: options)).statusCode,
      ),
      _ => false,
    };
  } on Exception catch (error, stackTrace) {
    developer.log(
      'Failed to check URL accessibility: $url',
      error: error,
      stackTrace: stackTrace,
    );
    return false;
  }
}

bool _isSuccessful(int? statusCode) =>
    statusCode != null && statusCode >= 200 && statusCode < 300;
