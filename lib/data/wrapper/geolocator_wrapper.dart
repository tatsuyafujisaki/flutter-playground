import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

/// Singleton wrapper around [Geolocator] for location permissions and updates.
class GeolocatorWrapper {
  /// Returns the singleton [GeolocatorWrapper] instance.
  factory() => _instance;
  new _internal() {
    _controller = StreamController();
  }
  static final _instance = GeolocatorWrapper._internal();
  late final StreamController<Position> _controller;

  LocationSettings get _locationSettings {
    if (Platform.isAndroid) {
      return AndroidSettings(
        // > (Optional) Set foreground notification config
        // > to keep the app alive when going to the background
        // https://pub.dev/documentation/geolocator/
        //
        // If you specify foregroundNotificationConfig,
        // you must specify the following in AndroidManifest.xml.
        // <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
        // Otherwise, you won't get any location updates
        // not only in the background but also in the foreground.
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: '',
          notificationText: '',
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings();
    }
    return const LocationSettings();
  }

  Future<bool> get _isAllowed async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == .denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == .denied || permission == .deniedForever) {
      return false;
    }
    return true;
  }

  /// The current device [Position], or `null` if location access is denied.
  Future<Position?> get currentPosition async =>
      await _isAllowed ? await Geolocator.getCurrentPosition() : null;

  /// A stream of device [Position] updates.
  Future<Stream<Position>?> get positionStream async {
    if (!_controller.hasListener && await _isAllowed) {
      await _controller.addStream(
        Geolocator.getPositionStream(locationSettings: _locationSettings),
      );
    }
    return _controller.stream;
  }

  /// Logs the current device position once for demonstration.
  void demoOneShot() {
    Future<void>.delayed(
      .zero,
      () => developer.log(currentPosition.toString()),
    );
  }

  /// Subscribes to [positionStream] and logs each update for demonstration.
  void demoListen() {
    Future<void>.delayed(
      .zero,
      () async => (await GeolocatorWrapper().positionStream)?.listen(
        (position) => developer.log(
          '$position, Time: ${DateFormat.Hms().format(.now())}',
        ),
      ),
    );
  }
}
