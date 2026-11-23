import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_playground/firebase_options_dev.dart' as dev;
import 'package:flutter_playground/firebase_options_prod.dart' as prod;
import 'package:flutter_playground/ui/my_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureFlavor();
  await _activateAppCheck();
  _setupErrorHandling();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _configureFlavor() => Firebase.initializeApp(
  options: appFlavor == 'dev'
      ? dev.DefaultFirebaseOptions.currentPlatform
      : prod.DefaultFirebaseOptions.currentPlatform,
);

// Attaches App Check tokens to Firebase requests so that Cloud Functions can
// reject calls that don't come from this app. Debug builds use the debug
// provider, whose token must be registered in the Firebase console.
Future<void> _activateAppCheck() => FirebaseAppCheck.instance.activate(
  providerAndroid: kDebugMode
      ? const AndroidDebugProvider()
      : const AndroidPlayIntegrityProvider(),
  providerApple: kDebugMode
      ? const AppleDebugProvider()
      : const AppleDeviceCheckProvider(),
);

void _setupErrorHandling() {
  FlutterError.onError = (details) {
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      unawaited(FirebaseCrashlytics.instance.recordFlutterFatalError(details));
    }
  };

  PlatformDispatcher.instance.onError = (exception, stackTrace) {
    if (!kDebugMode) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(
          exception,
          stackTrace,
          fatal: true,
        ),
      );
    }
    return !kDebugMode;
  };
}
