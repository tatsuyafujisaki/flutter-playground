import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_remote_config.g.dart';

/// Provides the [FirebaseRemoteConfig] instance of the default Firebase app.
@Riverpod(keepAlive: true)
FirebaseRemoteConfig firebaseRemoteConfig(Ref ref) =>
    FirebaseRemoteConfig.instance;
