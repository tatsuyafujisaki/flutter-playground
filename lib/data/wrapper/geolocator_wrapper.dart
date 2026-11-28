import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geolocator_wrapper.g.dart';

/// Provides the singleton [GeolocatorWrapper] instance.
@Riverpod(keepAlive: true)
GeolocatorWrapper geolocatorWrapper(Ref ref) => const GeolocatorWrapper();

/// Wrapper around [Geolocator] for location permissions and positions.
class const GeolocatorWrapper() {
  /// Creates a [GeolocatorWrapper].
  this;

  Future<bool> get _isAllowed async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == .denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission != .denied && permission != .deniedForever;
  }

  /// The current device [Position], or `null` if location access is denied.
  Future<Position?> get currentPosition async =>
      await _isAllowed ? await Geolocator.getCurrentPosition() : null;
}
