import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_playground/data/model/chain_cafe.dart';
import 'package:flutter_playground/data/repository/places_repository.dart';
import 'package:flutter_playground/data/wrapper/geolocator_wrapper.dart';
import 'package:flutter_playground/ui/view_model/auth_view_model.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_maps_view_model.freezed.dart';
part 'google_maps_view_model.g.dart';

// The minimum distance the map center must move from the last search center
// before cafes are searched again. Limits billed Places API requests made by
// the `searchNearbyChainCafes` Cloud Function.
const _minSearchDistanceInMeters = 100;

/// Immutable UI state for the Google Maps page.
@freezed
sealed class GoogleMapsState with _$GoogleMapsState {
  /// Creates a [GoogleMapsState].
  const factory({
    /// The device's last known location, or `null` if it isn't known yet.
    LatLng? currentLocation,

    /// The chain cafes found by the latest successful search.
    @Default(<ChainCafe>[]) List<ChainCafe> cafes,

    /// Whether the device's location is being loaded.
    @Default(false) bool isLocating,

    /// Whether a chain cafe search is in progress.
    @Default(false) bool isSearching,

    /// The error message of the latest failed operation, or `null` if the
    /// latest operation hasn't failed.
    String? errorMessage,
  }) = _GoogleMapsState;
}

/// A Riverpod notifier that loads the device's location and searches for
/// nearby chain cafes.
@riverpod
class GoogleMapsViewModel extends _$GoogleMapsViewModel {
  LatLng? _lastSearchCenter;

  // Identifies the latest search so that stale responses are discarded.
  var _searchGeneration = 0;

  @override
  GoogleMapsState build() => const GoogleMapsState();

  /// Loads the device's location and starts a chain cafe search around it.
  ///
  /// Returns the location as soon as it's known, without waiting for the
  /// search, so that the caller can move the camera there. Returns `null` if
  /// the location is unavailable.
  Future<LatLng?> loadNearbyChainCafes({required String languageCode}) async {
    if (state.isLocating) {
      return null;
    }
    state = state.copyWith(isLocating: true, errorMessage: null);

    try {
      final position = await ref
          .read(geolocatorWrapperProvider)
          .currentPosition;
      if (position == null || !ref.mounted) {
        return null;
      }

      developer.log(
        'Current location: ${position.latitude}, ${position.longitude}',
      );

      final location = LatLng(position.latitude, position.longitude);
      state = state.copyWith(currentLocation: location);

      // Starts the search before the caller moves the camera so that the
      // camera idle event fired by the animation doesn't trigger a duplicate
      // search.
      unawaited(_searchChainCafes(location, languageCode: languageCode));
      return location;
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to load current location',
        error: error,
        stackTrace: stackTrace,
      );
      if (ref.mounted) {
        state = state.copyWith(
          errorMessage:
              'Failed to load current location: ${_describeError(error)}',
        );
      }
      return null;
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isLocating: false);
      }
    }
  }

  /// Searches for chain cafes around [center], unless [center] is close to the
  /// center of the last search.
  Future<void> searchChainCafesIfMoved(
    LatLng center, {
    required String languageCode,
  }) async {
    if (state.isLocating) {
      return;
    }
    if (_lastSearchCenter case final lastSearchCenter?
        when Geolocator.distanceBetween(
              lastSearchCenter.latitude,
              lastSearchCenter.longitude,
              center.latitude,
              center.longitude,
            ) <
            _minSearchDistanceInMeters) {
      return;
    }
    await _searchChainCafes(center, languageCode: languageCode);
  }

  /// Replaces the cafes in [state] with the chain cafes around [center].
  Future<void> _searchChainCafes(
    LatLng center, {
    required String languageCode,
  }) async {
    final generation = ++_searchGeneration;
    _lastSearchCenter = center;
    state = state.copyWith(isSearching: true, errorMessage: null);

    try {
      // The Cloud Function rejects unauthenticated calls.
      await ref.read(authViewModelProvider.notifier).signInAnonymously();
      if (!ref.mounted) {
        return;
      }
      final cafes = await ref
          .read(placesRepositoryProvider)
          .searchNearbyChainCafes(
            latitude: center.latitude,
            longitude: center.longitude,
            languageCode: languageCode,
          );
      if (!ref.mounted || generation != _searchGeneration) {
        return;
      }

      developer.log('Found ${cafes.length} nearby chain cafes');
      state = state.copyWith(cafes: cafes);
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to load nearby chain cafes',
        error: error,
        stackTrace: stackTrace,
      );
      if (ref.mounted && generation == _searchGeneration) {
        // Lets the next camera move retry the search at the same place.
        _lastSearchCenter = null;
        state = state.copyWith(
          errorMessage:
              'Failed to load nearby chain cafes: ${_describeError(error)}',
        );
      }
    } finally {
      if (ref.mounted && generation == _searchGeneration) {
        state = state.copyWith(isSearching: false);
      }
    }
  }

  // Firebase exceptions include their stack trace in `toString()`, which is
  // too long for a snackbar.
  String _describeError(Exception error) => switch (error) {
    FirebaseException(:final message?) => message,
    FirebaseException(:final code) => code,
    _ => '$error',
  };
}
