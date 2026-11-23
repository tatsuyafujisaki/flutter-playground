import 'dart:math' as math;

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
const _metersPerDegreeLatitude = 111320.0;

// Pro-tier Text Search fields only, keeping payload size and billing minimal.
const _chainCafeFields =
    'places.id,places.displayName,places.formattedAddress,places.location';

/// Default list of major cafe chains searched by
/// [PlacesRepository.searchNearbyChainCafes].
const defaultChainCafeNames = [
  'Starbucks',
  'Doutor Coffee',
  "Tully's Coffee",
  "Komeda's Coffee",
  'St. Marc Cafe',
  'Excelsior Caffe',
  'Caffe Veloce',
  'Pronto',
];

String get _platformApiKey => switch (defaultTargetPlatform) {
  .android => _androidApiKey,
  .iOS => _iosApiKey,
  .fuchsia || .linux || .macOS || .windows => '',
};

Future<Map<String, String>> _defaultAppRestrictionHeaders() async {
  final packageInfo = await PackageInfo.fromPlatform();
  switch (defaultTargetPlatform) {
    case .android:
      final certSha1 = await _signingChannel.invokeMethod<String>(
        'getSigningCertSha1',
      );
      return {
        'X-Android-Package': packageInfo.packageName,
        if (certSha1 != null && certSha1.isNotEmpty) 'X-Android-Cert': certSha1,
      };
    case .iOS:
      return {'X-Ios-Bundle-Identifier': packageInfo.packageName};
    case .fuchsia || .linux || .macOS || .windows:
      return const {};
  }
}

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
class const PlacesRepository(
  final Dio _dio,
  final bool _hasApiKey, {

  /// Provides platform-specific app restriction headers for Places API
  /// requests.
  final Future<Map<String, String>> Function() appRestrictionHeaders =
      _defaultAppRestrictionHeaders,
}) {
  /// Creates a [PlacesRepository] backed by [_dio].
  this;

  /// Searches for chain cafes in [chainNames] within [radius] meters of
  /// ([latitude], [longitude]) using Places API (New) Text Search.
  Future<List<GoogleMapsPlacesV1Place>> searchNearbyChainCafes({
    required double latitude,
    required double longitude,
    double radius = 500,
    List<String> chainNames = defaultChainCafeNames,
    int pageSize = 20,
    String? languageCode,
  }) async {
    if (!_hasApiKey) {
      throw StateError(
        'Google Maps API key is not set for $defaultTargetPlatform. '
        'Pass --dart-define-from-file=dart_defines.json.',
      );
    }

    if (chainNames.isEmpty) {
      return const [];
    }

    final headers = await appRestrictionHeaders();
    final locationRestriction = _buildLocationRestriction(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );

    final responses = await Future.wait(
      chainNames.map(
        (chainName) => _searchChainCafe(
          chainName: chainName,
          locationRestriction: locationRestriction,
          pageSize: pageSize,
          languageCode: languageCode,
          appRestrictionHeaders: headers,
        ),
      ),
    );

    final deduplicated = <String, GoogleMapsPlacesV1Place>{};
    for (final places in responses) {
      for (final place in places) {
        final key =
            place.id ??
            '${place.location?.latitude}_${place.location?.longitude}';
        deduplicated.putIfAbsent(key, () => place);
      }
    }
    return deduplicated.values.toList();
  }

  Future<List<GoogleMapsPlacesV1Place>> _searchChainCafe({
    required String chainName,
    required GoogleMapsPlacesV1SearchTextRequestLocationRestriction
    locationRestriction,
    required int pageSize,
    required Map<String, String> appRestrictionHeaders,
    String? languageCode,
  }) async {
    final request = GoogleMapsPlacesV1SearchTextRequest(
      textQuery: chainName,
      includedType: 'cafe',
      strictTypeFiltering: true,
      pageSize: pageSize,
      languageCode: languageCode,
      locationRestriction: locationRestriction,
    );

    final response = await _dio.post<Map<String, dynamic>>(
      '/v1/places:searchText',
      data: request.toJson(),
      options: Options(
        headers: {
          'X-Goog-FieldMask': _chainCafeFields,
          ...appRestrictionHeaders,
        },
      ),
    );

    final data = response.data;
    if (data == null) {
      return const [];
    }
    return GoogleMapsPlacesV1SearchTextResponse.fromJson(data).places ??
        const [];
  }

  GoogleMapsPlacesV1SearchTextRequestLocationRestriction
  _buildLocationRestriction({
    required double latitude,
    required double longitude,
    required double radius,
  }) {
    final latDelta = radius / _metersPerDegreeLatitude;
    final cosLat = math.cos(latitude * math.pi / 180.0).abs().clamp(1e-6, 1.0);
    final lngDelta = radius / (_metersPerDegreeLatitude * cosLat);

    return GoogleMapsPlacesV1SearchTextRequestLocationRestriction(
      rectangle: GoogleGeoTypeViewport(
        low: GoogleTypeLatLng(
          latitude: (latitude - latDelta).clamp(-90.0, 90.0),
          longitude: (longitude - lngDelta).clamp(-180.0, 180.0),
        ),
        high: GoogleTypeLatLng(
          latitude: (latitude + latDelta).clamp(-90.0, 90.0),
          longitude: (longitude + lngDelta).clamp(-180.0, 180.0),
        ),
      ),
    );
  }
}
