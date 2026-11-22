import 'dart:developer' as developer;

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

/// Checks Firebase Remote Config and returns the platform store [Uri] if a
/// force update is required, or `null` otherwise.
Future<Uri?> getForceUpdateStoreUri() async {
  try {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: .zero,
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
    developer.log('', error: error, stackTrace: stackTrace);
    return null;
  }
}

/// Parses [version] into a [Version], or returns `null` if parsing fails.
Version? tryParse(String version) {
  if (version.isEmpty) {
    return null;
  }
  try {
    return .parse(version);
  } on Exception catch (error, stackTrace) {
    developer.log('', error: error, stackTrace: stackTrace);
    return null;
  }
}

bool _shouldForceUpdate({
  required String currentVersionString,
  required String minVersionString,
}) {
  final currentVersion = tryParse(currentVersionString) ?? .none;
  final minVersion = tryParse(minVersionString) ?? .none;
  return currentVersion < minVersion;
}

Uri? _storeUri(String packageName) {
  if (kIsWeb) {
    return null;
  }
  return switch (defaultTargetPlatform) {
    // Replace with your actual App Store ID.
    .iOS => .parse('https://apps.apple.com/app/id544007664'),
    .android => .parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    ),
    .fuchsia || .linux || .macOS || .windows => null,
  };
}
