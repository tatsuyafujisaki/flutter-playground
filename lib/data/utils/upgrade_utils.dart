import 'dart:developer' as developer;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

/// Checks [remoteConfig] and returns the platform store [Uri] if a force
/// update is required, or `null` otherwise.
Future<Uri?> getForceUpdateStoreUri(FirebaseRemoteConfig remoteConfig) async {
  try {
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode ? .zero : const Duration(hours: 12),
      ),
    );
    await remoteConfig.setDefaults(const {'min_version': '0.0.0'});
    await remoteConfig.fetchAndActivate();

    final minVersion = remoteConfig.getString('min_version').trim();
    if (minVersion.isEmpty) {
      return null;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    if (!_shouldForceUpdate(
      currentVersionString: packageInfo.version,
      minVersionString: minVersion,
    )) {
      return null;
    }

    return _storeUri(packageInfo.packageName);
  } on Exception catch (error, stackTrace) {
    developer.log(
      'Failed to check force update status',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}

/// Parses [version] into a [Version], or returns `null` if parsing fails.
Version? tryParseVersion(String version) {
  if (version.isEmpty) {
    return null;
  }
  try {
    return .parse(version);
  } on Exception catch (error, stackTrace) {
    developer.log(
      'Failed to parse semantic version: $version',
      error: error,
      stackTrace: stackTrace,
    );
    return null;
  }
}

bool _shouldForceUpdate({
  required String currentVersionString,
  required String minVersionString,
}) {
  final currentVersion = tryParseVersion(currentVersionString);
  final minVersion = tryParseVersion(minVersionString);
  if (currentVersion == null || minVersion == null) {
    return false;
  }
  return currentVersion < minVersion;
}

/// The numeric App Store ID, passed with `--dart-define=APP_STORE_ID=...`.
const _appStoreId = String.fromEnvironment('APP_STORE_ID');

Uri? _storeUri(String packageName) {
  if (kIsWeb) {
    return null;
  }
  return switch (defaultTargetPlatform) {
    .iOS when _appStoreId.isNotEmpty => .parse(
      'https://apps.apple.com/app/id$_appStoreId',
    ),
    .android => .parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    ),
    .iOS || .fuchsia || .linux || .macOS || .windows => null,
  };
}
