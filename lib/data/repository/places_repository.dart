import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_playground/data/model/chain_cafe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'places_repository.g.dart';

const _region = 'asia-northeast1';
const _searchNearbyChainCafesFunctionName = 'searchNearbyChainCafes';

/// Provides the singleton [PlacesRepository] instance.
@Riverpod(keepAlive: true)
PlacesRepository placesRepository(Ref ref) =>
    PlacesRepository(FirebaseFunctions.instanceFor(region: _region));

/// A repository that searches for places through Cloud Functions for Firebase,
/// which keeps the Places API key on the server.
class const PlacesRepository(final FirebaseFunctions _functions) {
  /// Creates a [PlacesRepository] with the given [FirebaseFunctions] instance.
  this;

  /// Searches for chain cafes around ([latitude], [longitude]).
  ///
  /// The server decides the chains, the search radius, and which results
  /// belong to an official chain website. The user must be signed in.
  Future<List<ChainCafe>> searchNearbyChainCafes({
    required double latitude,
    required double longitude,
    String? languageCode,
  }) async {
    final callable = _functions.httpsCallable(
      _searchNearbyChainCafesFunctionName,
    );
    final result = await callable.call<Map<Object?, Object?>>({
      'latitude': latitude,
      'longitude': longitude,
      'languageCode': ?languageCode,
    });

    final places = result.data['places'];
    if (places is! List) {
      return const [];
    }
    return [
      for (final place in places)
        ChainCafe.fromJson(Map<String, dynamic>.from(place as Map)),
    ];
  }
}
