import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_playground/firebase_options_dev.dart' as dev;
import 'package:flutter_playground/firebase_options_prod.dart' as prod;
import 'package:flutter_playground/ui/my_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureFlavor();
  _setupErrorHandling();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> _configureFlavor() => Firebase.initializeApp(
  options: appFlavor == 'dev'
      ? dev.DefaultFirebaseOptions.currentPlatform
      : prod.DefaultFirebaseOptions.currentPlatform,
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
