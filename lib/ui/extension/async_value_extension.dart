import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Convenience helpers on [AsyncValue] for debugging Riverpod state.
extension AsyncValueExtension on AsyncValue<dynamic> {
  /// Logs the current data, error, or loading state of this [AsyncValue].
  void debugPrintRiverpod() => when(
    data: (data) => developer.log('👀data: $data'),
    error: (error, stackTrace) =>
        developer.log('👀(error, stackTrace): ($error, $stackTrace)'),
    loading: () => developer.log('👀loading'),
  );
}
