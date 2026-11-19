import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Convenience helpers on [AsyncValue] for debugging Riverpod state.
extension AsyncValueExtension on AsyncValue<dynamic> {
  /// Logs the current data, error, or loading state of this [AsyncValue].
  void debugPrintRiverpod() {
    switch (this) {
      case AsyncData(:final value):
        developer.log('👀data: $value');
      case AsyncError(:final error, :final stackTrace):
        developer.log('👀(error, stackTrace): ($error, $stackTrace)');
      case AsyncLoading():
        developer.log('👀loading');
    }
  }
}
