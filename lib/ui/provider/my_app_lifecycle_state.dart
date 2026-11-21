import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_app_lifecycle_state.g.dart';

/// A provider that tracks the current [AppLifecycleState] of the application.
@Riverpod(keepAlive: true)
class MyAppLifecycleState extends _$MyAppLifecycleState {
  @override
  AppLifecycleState build() {
    final listener = AppLifecycleListener(
      onStateChange: (state) => this.state = state,
    );
    ref.onDispose(listener.dispose);
    return WidgetsBinding.instance.lifecycleState ?? .resumed;
  }
}
