import 'package:permission_handler/permission_handler.dart';

/// Requests [permission] and returns whether access is granted (including
/// limited access on iOS).
///
/// To access photos and videos, use [isPhotoGranted] instead.
///
/// > Call request() on a Permission to request it. If it has already been
/// > granted before, nothing happens. request() returns the new status of
/// > the Permission.
/// https://pub.dev/packages/permission_handler
Future<bool> isGranted(Permission permission) async {
  final status = await permission
      .onPermanentlyDeniedCallback(openAppSettings)
      .request();
  return status.isGranted || status.isLimited;
}

/// Whether photo library permission is granted (or limited on iOS).
Future<bool> get isPhotoGranted => isGranted(.photos);
