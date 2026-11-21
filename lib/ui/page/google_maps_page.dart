import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_playground/data/repository/places_repository.dart';
import 'package:flutter_playground/data/utils/geolocator_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// A page that displays Google Maps with the user's location and nearby cafes.
class const GoogleMapsPage({super.key}) extends ConsumerStatefulWidget {
  /// Creates a [GoogleMapsPage].
  this;

  @override
  ConsumerState<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends ConsumerState<GoogleMapsPage> {
  final _controller = Completer<GoogleMapController>();

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getCurrentLocation());
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await getPosition();
      if (!mounted) {
        return;
      }

      final cameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 14.4746,
      );

      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(title: 'Your location'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      });

      final controller = await _controller.future;
      if (!mounted) {
        return;
      }
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition),
      );
      if (!mounted) {
        return;
      }

      developer.log(
        'Current location: ${position.latitude}, ${position.longitude}',
      );

      // Fetch nearby cafes
      await _fetchNearbyCafes(position.latitude, position.longitude);
    } on Exception catch (error, stackTrace) {
      developer.log('', error: error, stackTrace: stackTrace);
    }
  }

  Future<void> _fetchNearbyCafes(double latitude, double longitude) async {
    try {
      final repository = ref.read(placesRepositoryProvider);
      final cafes = await repository.fetchNearbyCoffeeShops(
        LatLng(latitude, longitude),
      );

      developer.log('Fetched ${cafes.length} allowed cafes');

      final cafeMarkers = cafes.map(_createCafeMarker).nonNulls.toSet();

      if (!mounted) {
        return;
      }
      setState(() {
        _markers.addAll(cafeMarkers);
      });

      developer.log('Added ${cafeMarkers.length} cafe markers to the map');
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Error fetching cafes',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  Marker? _createCafeMarker(Map<String, dynamic> cafe) {
    if (cafe case {
      'location': {
        'latitude': final num latitude,
        'longitude': final num longitude,
      },
    }) {
      final title = switch (cafe['displayName']) {
        {'text': final String text} => text,
        _ => 'Unknown Cafe',
      };
      final address = cafe['formattedAddress'] as String? ?? '';
      final id = cafe['id'] as String? ?? '';
      final websiteUri = cafe['websiteUri'] as String?;

      return Marker(
        markerId: MarkerId(id),
        position: LatLng(latitude.toDouble(), longitude.toDouble()),
        infoWindow: InfoWindow(
          title: title,
          snippet: address,
          onTap: websiteUri != null
              ? () async {
                  final uri = Uri.parse(websiteUri);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: .externalApplication);
                  } else {
                    developer.log('Could not launch $websiteUri');
                  }
                }
              : null,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Google Maps')),
    body: SafeArea(
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(35.6812, 139.7671), // 東京駅の座標（デフォルト）
          zoom: 14.4746,
        ),
        onMapCreated: _controller.complete,
        markers: _markers,
      ),
    ),
  );
}
