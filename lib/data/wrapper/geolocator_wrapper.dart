import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'geolocator_wrapper.g.dart';

/// Provides the singleton [GeolocatorWrapper] instance.
@Riverpod(keepAlive: true)
GeolocatorWrapper geolocatorWrapper(Ref ref) {
  final wrapper = GeolocatorWrapper();
  ref.onDispose(() => unawaited(wrapper.dispose()));
  return wrapper;
}

/// Wrapper around [Geolocator] for location permissions and updates.
class GeolocatorWrapper {
  StreamController<Position>? _controller;
  StreamSubscription<Position>? _subscription;

  LocationSettings get _locationSettings {
    if (kIsWeb) {
      return const LocationSettings();
    }
    return switch (defaultTargetPlatform) {
      // No foregroundNotificationConfig: this app only tracks location while
      // it is open, so it needs no foreground service or background location.
      .android => AndroidSettings(),
      .iOS => AppleSettings(),
      .fuchsia || .linux || .macOS || .windows => const LocationSettings(),
    };
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
    if (!await _isAllowed) {
      return null;
    }
    final controller = _controller ??= StreamController<Position>.broadcast(
      onListen: () {
        _subscription ??=
            Geolocator.getPositionStream(locationSettings: _locationSettings)
                .listen(
                  (position) => _controller?.add(position),
                  onError: (Object error, StackTrace stackTrace) =>
                      _controller?.addError(error, stackTrace),
                );
      },
      onCancel: () {
        unawaited(_subscription?.cancel());
        _subscription = null;
      },
    );
    return controller.stream;
  }

  /// Cancels any active location subscription and closes the stream controller.
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    await _controller?.close();
    _controller = null;
  }
}
