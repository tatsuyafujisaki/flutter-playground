import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/places/v1.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'places_repository.g.dart';

const _baseUrl = 'https://places.googleapis.com';
const _androidApiKey = String.fromEnvironment('GOOGLE_MAPS_ANDROID_API_KEY');
const _iosApiKey = String.fromEnvironment('GOOGLE_MAPS_IOS_API_KEY');
const _solutionId = 'gmp_git_agentskills_v1';
const _signingChannel = MethodChannel('com.tatsuyafujisaki.poc/signing');

// Pro-tier Nearby Search fields only, keeping payload size and billing minimal.
const _nearbyCafeFields =
    'places.id,places.displayName,places.formattedAddress,places.location';

String get _platformApiKey => switch (defaultTargetPlatform) {
  .android => _androidApiKey,
  .iOS => _iosApiKey,
  .fuchsia || .linux || .macOS || .windows => '',
};

/// Provides the singleton [PlacesRepository] instance.
@Riverpod(keepAlive: true)
PlacesRepository placesRepository(Ref ref) {
  final apiKey = _platformApiKey;
  final dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'X-Goog-Api-Key': apiKey,
        'X-Goog-Maps-Solution-ID': _solutionId,
      },
    ),
  );
  ref.onDispose(dio.close);
  return PlacesRepository(dio, apiKey.isNotEmpty);
}

/// A repository for querying Google Places API (New) via [Dio] and
/// `package:googleapis/places/v1.dart` request/response models.
class const PlacesRepository(final Dio _dio, final bool _hasApiKey) {
  /// Creates a [PlacesRepository] backed by [_dio].
  this;

  /// Searches for cafes within [radius] meters of ([latitude], [longitude]).
  Future<List<GoogleMapsPlacesV1Place>> searchNearbyCafes({
    required double latitude,
    required double longitude,
    double radius = 500,
    int maxResultCount = 20,
    String? languageCode,
  }) async {
    if (!_hasApiKey) {
      throw StateError(
        'Google Maps API key is not set for $defaultTargetPlatform. '
        'Pass --dart-define-from-file=dart_defines.json.',
      );
    }

    final appRestrictionHeaders = await _appRestrictionHeaders();

    final request = GoogleMapsPlacesV1SearchNearbyRequest(
      includedTypes: ['cafe'],
      maxResultCount: maxResultCount,
      languageCode: languageCode,
      locationRestriction:
          GoogleMapsPlacesV1SearchNearbyRequestLocationRestriction(
            circle: GoogleMapsPlacesV1Circle(
              center: GoogleTypeLatLng(
                latitude: latitude,
                longitude: longitude,
              ),
              radius: radius,
            ),
          ),
    );

    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/places:searchNearby',
      data: request.toJson(),
      options: Options(
        headers: {
          'X-Goog-FieldMask': _nearbyCafeFields,
          ...appRestrictionHeaders,
        },
      ),
    );

    final data = response.data;
    if (data == null) {
      return const [];
    }
    return GoogleMapsPlacesV1SearchNearbyResponse.fromJson(data).places ??
        const [];
  }

  Future<Map<String, String>> _appRestrictionHeaders() async {
    final packageInfo = await PackageInfo.fromPlatform();
    switch (defaultTargetPlatform) {
      case .android:
        final certSha1 = await _signingChannel.invokeMethod<String>(
          'getSigningCertSha1',
        );
        return {
          'X-Android-Package': packageInfo.packageName,
          if (certSha1 != null && certSha1.isNotEmpty)
            'X-Android-Cert': certSha1,
        };
      case .iOS:
        return {'X-Ios-Bundle-Identifier': packageInfo.packageName};
      case .fuchsia || .linux || .macOS || .windows:
        return const {};
    }
  }
}
