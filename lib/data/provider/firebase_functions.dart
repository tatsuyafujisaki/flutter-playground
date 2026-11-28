import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'firebase_functions.g.dart';

// The region where the functions in `functions/` are deployed.
const _region = 'asia-northeast1';

/// Provides the [FirebaseFunctions] instance for the region where this app's
/// Cloud Functions for Firebase are deployed.
@Riverpod(keepAlive: true)
FirebaseFunctions firebaseFunctions(Ref ref) =>
    FirebaseFunctions.instanceFor(region: _region);
