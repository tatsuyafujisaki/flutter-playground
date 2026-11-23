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

// Includes Enterprise-tier `places.websiteUri` so Text Search results can be
// filtered strictly by official chain domain and opened without an extra Place
// Details request.
const _chainCafeFields =
    'places.id,places.displayName,places.location,places.websiteUri,'
    'places.googleMapsUri';

// Enterprise-tier Place Details field used as a fallback when `websiteUri` was
// not already fetched.
const _placeUriFields = 'websiteUri,googleMapsUri';

/// A cafe chain definition pairing a Text Search [query] with its official
/// website [domains].
class const ChainCafe({
  /// The Text Search query used to discover nearby locations of this chain.
  required final String query,

  /// Official website domains (exact host or subdomain) accepted for this
  /// chain.
  required final List<String> domains,
}) {
  /// Creates a [ChainCafe].
  this;

  /// Returns whether [websiteUri] is an HTTP(S) URL whose host matches one of
  /// [domains] (exact match or subdomain).
  bool matchesWebsiteUri(String? websiteUri) {
    if (websiteUri == null || websiteUri.isEmpty) {
      return false;
    }
    final uri = Uri.tryParse(websiteUri);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return false;
    }
    final host = uri.host.toLowerCase();
    if (host.isEmpty) {
      return false;
    }
    return domains.any((domain) {
      final normalized = domain.toLowerCase();
      return host == normalized || host.endsWith('.$normalized');
    });
  }
}

/// Default list of major cafe chains searched and domain-filtered by
/// [PlacesRepository.searchNearbyChainCafes].
const defaultChainCafes = [
  ChainCafe(query: 'Starbucks', domains: ['starbucks.co.jp', 'starbucks.com']),
  ChainCafe(query: 'Doutor Coffee', domains: ['doutor.co.jp']),
  ChainCafe(query: "Tully's Coffee", domains: ['tullys.co.jp']),
  ChainCafe(query: "Komeda's Coffee", domains: ['komeda.co.jp']),
  ChainCafe(query: 'St. Marc Cafe', domains: ['saint-marc-hd.com']),
  ChainCafe(query: 'Excelsior Caffe', domains: ['doutor.co.jp']),
  ChainCafe(query: 'Caffe Veloce', domains: ['c-united.co.jp']),
  ChainCafe(query: 'Pronto', domains: ['pronto.co.jp']),
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

  /// Searches for chain cafes in [chains] within [radius] meters of
  /// ([latitude], [longitude]) using Places API (New) Text Search, and filters
  /// results to places whose `websiteUri` matches the chain's official domains.
  Future<List<GoogleMapsPlacesV1Place>> searchNearbyChainCafes({
    required double latitude,
    required double longitude,
    double radius = 500,
    List<ChainCafe> chains = defaultChainCafes,
    int pageSize = 20,
    String? languageCode,
  }) async {
    if (!_hasApiKey) {
      throw StateError(
        'Google Maps API key is not set for $defaultTargetPlatform. '
        'Pass --dart-define-from-file=dart_defines.json.',
      );
    }

    if (chains.isEmpty) {
      return const [];
    }

    final headers = await appRestrictionHeaders();
    final locationRestriction = _buildLocationRestriction(
      latitude: latitude,
      longitude: longitude,
      radius: radius,
    );

    final responses = await Future.wait(
      chains.map(
        (chain) => _searchChainCafe(
          chain: chain,
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

  /// Fetches the website URI for [placeId] using Places API (New) Place
  /// Details, falling back to its Google Maps URI when no website is
  /// registered.
  Future<Uri?> getPlaceUri(String placeId) async {
    if (!_hasApiKey) {
      throw StateError(
        'Google Maps API key is not set for $defaultTargetPlatform. '
        'Pass --dart-define-from-file=dart_defines.json.',
      );
    }

    if (placeId.isEmpty) {
      return null;
    }

    final headers = await appRestrictionHeaders();
    final response = await _dio.get<Map<String, dynamic>>(
      '/v1/places/${Uri.encodeComponent(placeId)}',
      options: Options(
        headers: {'X-Goog-FieldMask': _placeUriFields, ...headers},
      ),
    );

    final data = response.data;
    if (data == null) {
      return null;
    }

    final place = GoogleMapsPlacesV1Place.fromJson(data);
    return _parseHttpUri(place.websiteUri) ??
        _parseHttpUri(place.googleMapsUri);
  }

  Uri? _parseHttpUri(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }
    final uri = Uri.tryParse(raw);
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return uri;
  }

  Future<List<GoogleMapsPlacesV1Place>> _searchChainCafe({
    required ChainCafe chain,
    required GoogleMapsPlacesV1SearchTextRequestLocationRestriction
    locationRestriction,
    required int pageSize,
    required Map<String, String> appRestrictionHeaders,
    String? languageCode,
  }) async {
    final request = GoogleMapsPlacesV1SearchTextRequest(
      textQuery: chain.query,
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
    final places =
        GoogleMapsPlacesV1SearchTextResponse.fromJson(data).places ?? const [];
    return places
        .where((place) => chain.matchesWebsiteUri(place.websiteUri))
        .toList();
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
