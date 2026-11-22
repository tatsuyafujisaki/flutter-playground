import 'dart:io';

/// https://stackoverflow.com/a/12649574/10867055
class _MySingleton._() {
  factory() {
    if (!initialized) {
      initialized = true;
      stdout.writeln('Perform some initialization.');
    }
    return _singleton;
  }
  static final _singleton = _MySingleton._();
  static bool initialized = false;
  final DateTime initializedAt = .now();
}

void main() {
  stdout
    ..writeln(_MySingleton() == _MySingleton()) // true
    ..writeln(
      _MySingleton().initializedAt,
    ); // prints the same timestamp as above.
}
