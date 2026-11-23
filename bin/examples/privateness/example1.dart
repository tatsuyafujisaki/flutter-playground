import 'dart:io';

const _myTopPrivateLevelVariable = '_myTopPrivateLevelVariable';

/// A top-level public variable.
const myTopLevelPublicVariable = 'myTopLevelPublicVariable';

/// A public class demonstrating public and private members.
class MyPublic() {
  /// Creates a [MyPublic].
  this;

  final _myPrivateVariable = '_myPrivateVariable';

  /// A public instance variable.
  final myPublicVariable = 'myPublicVariable';

  void _myPrivateMethod() {
    stdout.writeln('_myPrivateMethod');
  }

  /// Logs a message from this public method.
  void myPublicMethod() {
    stdout.writeln('myPublicMethod');
  }
}

class const _MyPrivate();

void main() {
  // Top-level private variables are only accessible from within the same file.
  stdout
    ..writeln(_myTopPrivateLevelVariable)
    ..writeln(myTopLevelPublicVariable);

  final myPublic = MyPublic();
  // Private instance variables can only be accessed from the same file.
  stdout
    ..writeln(myPublic._myPrivateVariable)
    ..writeln(myPublic.myPublicVariable);
  // Private instance methods can only be accessed from the same file.
  myPublic
    .._myPrivateMethod()
    ..myPublicMethod();

  // Private classes can only be accessed from the same file.
  const myPrivate = _MyPrivate();
  stdout.writeln(myPrivate);
}
