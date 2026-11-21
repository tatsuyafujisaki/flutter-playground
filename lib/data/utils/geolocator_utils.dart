import 'package:geolocator/geolocator.dart';

/// Returns the current device [Position] after checking location permissions.
Future<Position> getPosition() async {
  final locationServiceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!locationServiceEnabled) {
    throw Exception('Location service is disabled.');
  }

  var permission = await Geolocator.checkPermission();
  if (permission == .denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == .denied || permission == .deniedForever) {
    throw Exception('Location permission is denied.');
  }

  return await Geolocator.getCurrentPosition();
}
