import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_playground/data/repository/places_repository.dart';
import 'package:flutter_playground/data/wrapper/geolocator_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  Set<Marker> _markers = {};
  var _isLoading = false;
  var _isOpeningUrl = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadNearbyChainCafes(),
    );
  }

  Future<void> _loadNearbyChainCafes() async {
    if (_isLoading) {
      return;
    }
    final languageCode = Localizations.localeOf(context).languageCode;
    setState(() => _isLoading = true);

    try {
      final position = await ref
          .read(geolocatorWrapperProvider)
          .currentPosition;
      if (position == null || !mounted) {
        return;
      }

      final latLng = LatLng(position.latitude, position.longitude);
      final currentLocationMarker = Marker(
        markerId: const .new('current_location'),
        position: latLng,
        infoWindow: const .new(title: 'Your location'),
        icon: .defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );

      setState(() {
        _resolvedPlaceUris.clear();
        _markers = {currentLocationMarker};
      });

      final controller = await _controller.future;
      if (!mounted) {
        return;
      }
      // Keeps the current zoom level and only moves the center.
      await controller.animateCamera(.newLatLng(latLng));

      developer.log(
        'Current location: ${position.latitude}, ${position.longitude}',
      );

      final cafes = await ref
          .read(placesRepositoryProvider)
          .searchNearbyChainCafes(
            latitude: position.latitude,
            longitude: position.longitude,
            languageCode: languageCode,
          );
      if (!mounted) {
        return;
      }

      final cafeMarkers = cafes.map(_toCafeMarker).nonNulls;
      setState(() {
        _markers = {currentLocationMarker, ...cafeMarkers};
      });

      developer.log('Found ${cafeMarkers.length} nearby chain cafes');
    } on Object catch (error, stackTrace) {
      developer.log(
        'Failed to load current location or nearby chain cafes',
        error: error,
        stackTrace: stackTrace,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load nearby chain cafes: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
        if (_isLoading || _isOpeningUrl)
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
          target: .new(35.6812, 139.7671), // Default: Tokyo Station.
          zoom: 15, // Street level.
        ),
        style: _hideBusinessPoisMapStyle,
        onMapCreated: _controller.complete,
        markers: _markers,
      ),
    ),
  );
}
