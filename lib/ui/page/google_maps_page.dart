import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_playground/data/wrapper/geolocator_wrapper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// A page that displays Google Maps with the user's location.
class const GoogleMapsPage({super.key}) extends ConsumerStatefulWidget {
  /// Creates a [GoogleMapsPage].
  this;

  @override
  ConsumerState<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends ConsumerState<GoogleMapsPage> {
  // The GoogleMap widget disposes this controller itself.
  final _controller = Completer<GoogleMapController>();

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getCurrentLocation());
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await ref
          .read(geolocatorWrapperProvider)
          .currentPosition;
      if (position == null || !mounted) {
        return;
      }

      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _markers.add(
          Marker(
            markerId: const .new('current_location'),
            position: latLng,
            infoWindow: const .new(title: 'Your location'),
            icon: .defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
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
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Failed to get current location',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Google Maps')),
    body: SafeArea(
      child: GoogleMap(
        initialCameraPosition: const .new(
          target: .new(35.6812, 139.7671), // Default: Tokyo Station.
          zoom: 15, // Street level.
        ),
        onMapCreated: _controller.complete,
        markers: _markers,
      ),
    ),
  );
}
