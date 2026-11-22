import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_playground/data/utils/geolocator_utils.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_ui/material_ui.dart';

/// A page that displays Google Maps with the user's location.
class const GoogleMapsPage({super.key}) extends StatefulWidget {
  /// Creates a [GoogleMapsPage].
  this;

  @override
  State<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  final _controller = Completer<GoogleMapController>();

  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getCurrentLocation());
  }

  @override
  void dispose() {
    if (_controller.isCompleted) {
      unawaited(_controller.future.then((controller) => controller.dispose()));
    }
    super.dispose();
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

      developer.log(
        'Current location: ${position.latitude}, ${position.longitude}',
      );
    } on Exception catch (error, stackTrace) {
      developer.log('', error: error, stackTrace: stackTrace);
    }
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
