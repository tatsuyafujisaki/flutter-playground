import 'dart:async';
import 'dart:io';

void main() {
  late StreamSubscription<int> subscription;

  subscription =
      Stream.periodic(const Duration(milliseconds: 100), (count) {
            if (count == 3) {
              throw Exception('💀');
            }
            if (count == 7) {
              unawaited(subscription.cancel());
            }
            return count;
          })
          .take(10)
          // Setting "Stream.handleError" will disable ...
          // "Stream.listen()"'s onError and cancelOnError.
          //
          // > If the error is intercepted,
          // > the onError function can decide what to do with it.
          // > It can throw if it wants to raise a new (or the same) error,
          // > or simply return to make this stream forget the error.
          // https://api.dart.dev/stable/dart-async/Stream/handleError.html
          .handleError((Object error, StackTrace stackTrace) {
            stderr
              ..writeln('👀handleError: $error')
              ..writeln(stackTrace);
          })
          .listen(
            (data) => stdout.writeln('👀data: $data'),
            onError: (Object error, StackTrace stackTrace) {
              stderr
                ..writeln('👀onError: $error')
                ..writeln(stackTrace);
            },
            // onDone will not be called if done by cancel.
            //
            // > While a subscription is paused, or when it has been canceled,
            // > the subscription doesn't receive events
            // > and none of the event handler functions are called.
            // https://api.flutter.dev/flutter/async/LazyStream/listen.html
            onDone: () => stdout.writeln('👀onDone'),
            cancelOnError: true,
          );
}
