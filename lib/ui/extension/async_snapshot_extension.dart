import 'dart:developer' as developer;

import 'package:material_ui/material_ui.dart';

/// Convenience widget-building helpers on [AsyncSnapshot].
extension AsyncSnapshotExtension<T> on AsyncSnapshot<T> {
  /// Builds a widget from this snapshot by invoking [onData] when non-null
  /// data is available, [onError] when an error occurred, or [onElse]
  /// while loading.
  Widget buildWidget({
    required Widget Function(T data) onData,
    required String errorLogMessage,
    Widget Function()? onError,
    Widget Function()? onElse,
  }) => switch (this) {
    AsyncSnapshot(:final data?) => onData(data),
    AsyncSnapshot() => _buildErrorOrLoading(
      errorLogMessage: errorLogMessage,
      onError: onError,
      onElse: onElse,
    ),
  };

  /// Builds a widget from a `void` snapshot by invoking [onData] when
  /// [connectionState] is [ConnectionState.done], [onError] when an error
  /// occurred, or [onElse] while loading.
  Widget buildVoidWidget({
    required Widget Function() onData,
    required String errorLogMessage,
    Widget Function()? onError,
    Widget Function()? onElse,
  }) => switch (this) {
    AsyncSnapshot(hasError: false, connectionState: .done) => onData(),
    AsyncSnapshot() => _buildErrorOrLoading(
      errorLogMessage: errorLogMessage,
      onError: onError,
      onElse: onElse,
    ),
  };

  Widget _buildErrorOrLoading({
    required String errorLogMessage,
    Widget Function()? onError,
    Widget Function()? onElse,
  }) {
    if (this case AsyncSnapshot(:final error?, :final stackTrace)) {
      developer.log(errorLogMessage, error: error, stackTrace: stackTrace);
      return onError?.call() ?? const Center(child: Icon(Icons.error));
    }
    return onElse?.call() ?? const Center(child: CircularProgressIndicator());
  }
}
