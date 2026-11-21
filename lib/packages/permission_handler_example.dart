import 'package:permission_handler/permission_handler.dart';

/// To access photos and videos, use [isPhotoGranted] instead.
///
/// > Call request() on a Permission to request it. If it has already been
/// > granted before, nothing happens. request() returns the new status of
/// > the Permission.
/// https://pub.dev/packages/permission_handler
Future<bool> isGranted<T extends Permission>(T permission) =>
    permission.onPermanentlyDeniedCallback(openAppSettings).request().isGranted;

/// Whether photo permission is granted for the current platform.
Future<bool> get isPhotoGranted => isGranted(Permission.photos);
