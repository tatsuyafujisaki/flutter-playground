import 'dart:async';
import 'dart:developer' as developer;

/// Extension methods for handling and logging [Stream] events.
extension StreamExtension<T> on Stream<T> {
  /// Intercepts data, error, and done events without altering the stream.
  Stream<T> handle({
    void Function(T)? handleData,
    void Function(Object, StackTrace)? handleError,
    void Function()? handleDone,
  }) => transform<T>(
    .fromHandlers(
      handleData: (data, sink) {
        handleData?.call(data);
        sink.add(data);
      },
      handleError: (error, stackTrace, sink) {
        handleError?.call(error, stackTrace);
        sink.addError(error, stackTrace);
      },
      handleDone: (sink) {
        handleDone?.call();
        sink.close();
      },
    ),
  );

  /// Logs data, error, and done events emitted by this stream.
  Stream<T> log() => handle(
    handleData: (data) => developer.log('👀handleData: $data'),
    handleError: (error, stackTrace) =>
        developer.log('👀handleError: $error\n$stackTrace'),
    handleDone: () => developer.log('👀handleDone'),
  );
}
