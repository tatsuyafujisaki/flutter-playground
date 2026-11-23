import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_playground/data/repository/places_repository.dart';
import 'package:flutter_playground/data/utils/debouncer.dart';
import 'package:flutter_playground/data/wrapper/geolocator_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:googleapis/places/v1.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

// Hides default business POIs (including independent cafes) so only chain cafe
// markers stand out on the map.
const _hideBusinessPoisMapStyle = '''
[
  {
    "featureType": "poi.business",
    "stylers": [
      {"visibility": "off"}
    ]
  }
]
''';

// Default: Tokyo Station.
const _defaultCameraTarget = LatLng(35.6812, 139.7671);

const _cameraIdleDebounceDuration = Duration(milliseconds: 500);

// The minimum distance the map center must move from the last search center
// before cafes are searched again. Limits billed Places API requests.
const _minSearchDistanceInMeters = 100;

/// A page that displays Google Maps with the user's location and nearby chain
/// cafes.
class const GoogleMapsPage({super.key}) extends ConsumerStatefulWidget {
  /// Creates a [GoogleMapsPage].
  this;

  @override
  ConsumerState<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends ConsumerState<GoogleMapsPage> {
  // The GoogleMap widget disposes this controller itself.
  final _controller = Completer<GoogleMapController>();
  final _resolvedPlaceUris = <String, Uri?>{};
  final _cameraIdleDebouncer = Debouncer(_cameraIdleDebounceDuration);

  Marker? _currentLocationMarker;
  Set<Marker> _cafeMarkers = {};
  LatLng _cameraTarget = _defaultCameraTarget;
  LatLng? _lastSearchCenter;

  // Identifies the latest search so that stale responses are discarded.
  var _searchGeneration = 0;
  var _isLocating = false;
  var _isSearching = false;
  var _isOpeningUrl = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadNearbyChainCafes(),
    );
  }

  @override
  void dispose() {
    _cameraIdleDebouncer.dispose();
    super.dispose();
  }

  /// Moves the camera to the current location and searches for cafes there.
  Future<void> _loadNearbyChainCafes() async {
    if (_isLocating) {
      return;
    }
    setState(() => _isLocating = true);

    try {
      final position = await ref
          .read(geolocatorWrapperProvider)
          .currentPosition;
      if (position == null || !mounted) {
        return;
      }

      developer.log(
        'Current location: ${position.latitude}, ${position.longitude}',
      );

      final latLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _resolvedPlaceUris.clear();
        _currentLocationMarker = Marker(
          markerId: const .new('current_location'),
          position: latLng,
          infoWindow: const .new(title: 'Your location'),
          icon: .defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        );
      });

      // Starts the search before moving the camera so that the camera idle
      // event fired by the animation doesn't trigger a duplicate search.
      final search = _searchChainCafes(latLng);
      final controller = await _controller.future;
      if (mounted) {
        // Keeps the current zoom level and only moves the center.
        await controller.animateCamera(.newLatLng(latLng));
      }
      await search;
    } on Object catch (error, stackTrace) {
      developer.log(
        'Failed to load current location',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load current location: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  void _onCameraIdle() {
    // Waits for the camera to settle so that consecutive gestures cause only
    // one search.
    _cameraIdleDebouncer.run(() {
      if (!mounted || _isLocating) {
        return;
      }
      final lastSearchCenter = _lastSearchCenter;
      if (lastSearchCenter != null &&
          Geolocator.distanceBetween(
                lastSearchCenter.latitude,
                lastSearchCenter.longitude,
                _cameraTarget.latitude,
                _cameraTarget.longitude,
              ) <
              _minSearchDistanceInMeters) {
        return;
      }
      unawaited(_searchChainCafes(_cameraTarget));
    });
  }

  /// Replaces the cafe markers with the chain cafes around [center].
  Future<void> _searchChainCafes(LatLng center) async {
    final generation = ++_searchGeneration;
    final languageCode = Localizations.localeOf(context).languageCode;
    _lastSearchCenter = center;
    setState(() => _isSearching = true);

    try {
      final cafes = await ref
          .read(placesRepositoryProvider)
          .searchNearbyChainCafes(
            latitude: center.latitude,
            longitude: center.longitude,
            languageCode: languageCode,
          );
      if (!mounted || generation != _searchGeneration) {
        return;
      }

      final cafeMarkers = cafes.map(_toCafeMarker).nonNulls.toSet();
      setState(() => _cafeMarkers = cafeMarkers);

      developer.log('Found ${cafeMarkers.length} nearby chain cafes');
    } on Object catch (error, stackTrace) {
      developer.log(
        'Failed to load nearby chain cafes',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted && generation == _searchGeneration) {
        // Lets the next camera move retry the search at the same place.
        _lastSearchCenter = null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load nearby chain cafes: $error')),
        );
      }
    } finally {
      if (mounted && generation == _searchGeneration) {
        setState(() => _isSearching = false);
      }
    }
  }

  Marker? _toCafeMarker(GoogleMapsPlacesV1Place place) {
    final latitude = place.location?.latitude;
    final longitude = place.location?.longitude;
    if (latitude == null || longitude == null) {
      return null;
    }

    final markerId = place.id ?? '${latitude}_$longitude';
    return Marker(
      markerId: .new(markerId),
      position: .new(latitude, longitude),
      infoWindow: .new(
        title: place.displayName?.text ?? 'Cafe',
        // Tapping the marker only shows the info window; tapping the info
        // window opens the cafe's website.
        onTap: () => unawaited(_openCafeUrl(place)),
      ),
      icon: .defaultMarkerWithHue(BitmapDescriptor.hueOrange),
    );
  }

  Future<void> _openCafeUrl(GoogleMapsPlacesV1Place place) async {
    if (_isOpeningUrl) {
      return;
    }
    setState(() => _isOpeningUrl = true);

    try {
      final uri = await _resolveCafeUri(place);
      if (!mounted) {
        return;
      }

      if (uri == null) {
        final name = place.displayName?.text ?? 'this cafe';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No URL available for $name')));
        return;
      }

      final launched = await launchUrl(uri, mode: .externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Could not open $uri')));
      }
    } on Object catch (error, stackTrace) {
      developer.log(
        'Failed to open cafe URL',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open cafe URL: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isOpeningUrl = false);
      }
    }
  }

  Future<Uri?> _resolveCafeUri(GoogleMapsPlacesV1Place place) async {
    final websiteUri = _parseHttpUri(place.websiteUri);
    if (websiteUri != null) {
      return websiteUri;
    }

    final placeId = place.id;
    if (placeId != null && placeId.isNotEmpty) {
      if (_resolvedPlaceUris.containsKey(placeId)) {
        return _resolvedPlaceUris[placeId] ??
            _parseHttpUri(place.googleMapsUri);
      }

      try {
        final uri = await ref
            .read(placesRepositoryProvider)
            .getPlaceUri(placeId);
        _resolvedPlaceUris[placeId] = uri;
        if (uri != null) {
          return uri;
        }
      } on Object catch (error, stackTrace) {
        developer.log(
          'Failed to fetch Place Details URI for $placeId; falling back to '
          'googleMapsUri',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    return _parseHttpUri(place.googleMapsUri);
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Google Maps'),
      actions: [
        if (_isLocating || _isSearching || _isOpeningUrl)
          const Padding(
            padding: .all(16),
            child: SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload nearby chain cafes',
            onPressed: _loadNearbyChainCafes,
          ),
      ],
    ),
    body: SafeArea(
      child: GoogleMap(
        initialCameraPosition: const .new(
          target: _defaultCameraTarget,
          zoom: 15, // Street level.
        ),
        style: _hideBusinessPoisMapStyle,
        onMapCreated: _controller.complete,
        onCameraMove: (position) => _cameraTarget = position.target,
        onCameraIdle: _onCameraIdle,
        markers: {?_currentLocationMarker, ..._cafeMarkers},
      ),
    ),
  );
}
