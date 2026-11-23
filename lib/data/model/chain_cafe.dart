import 'package:freezed_annotation/freezed_annotation.dart';

part 'chain_cafe.freezed.dart';
part 'chain_cafe.g.dart';

/// A chain cafe returned by the `searchNearbyChainCafes` Cloud Function.
@freezed
sealed class ChainCafe with _$ChainCafe {
  /// Creates a [ChainCafe].
  const factory({
    /// The Google Maps place ID.
    required String id,

    /// The localized display name.
    required String name,

    /// The latitude in degrees.
    required double latitude,

    /// The longitude in degrees.
    required double longitude,

    /// The cafe's page on the official website of its chain.
    required String websiteUri,

    /// The Google Maps URL of the cafe.
    String? googleMapsUri,
  }) = _ChainCafe;

  /// Creates a [ChainCafe] from a JSON map.
  factory fromJson(Map<String, dynamic> json) => _$ChainCafeFromJson(json);
}
