import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_analytics.g.dart';

/// Provides the [FirebaseAnalytics] instance of the default Firebase app.
@Riverpod(keepAlive: true)
FirebaseAnalytics firebaseAnalytics(Ref ref) => FirebaseAnalytics.instance;
