import 'dart:async';

/// A container that manages and disposes multiple stream subscriptions.
class CompositeSubscription {
  final _subscriptions = <StreamSubscription<Object>>{};
  var _isDisposed = false;

  /// Whether this subscription container has been disposed.
  bool get isDisposed => _isDisposed;

  /// Adds [subscription] to this container.
  ///
  /// Throws a [StateError] if this container has already been disposed.
  void add(StreamSubscription<Object> subscription) {
    if (_isDisposed) {
      throw StateError('CompositeSubscription is already disposed.');
    }
    _subscriptions.add(subscription);
  }

  /// Cancels all managed subscriptions and marks this container as disposed.
  Future<void> dispose() async {
    await Future.wait(
      _subscriptions.map((subscription) => subscription.cancel()),
    );
    _subscriptions.clear();
    _isDisposed = true;
  }
}
