import 'dart:io';

import 'example1.dart';

void main() {
  // Top-level private variables are only accessible from within the same file.
  // stdout.writeln(_myTopPrivateLevelVariable);
  stdout.writeln(myTopLevelPublicVariable);

  final myPublic = MyPublic();
  // Private instance variables can only be accessed from the same file.
  // stdout.writeln(myPublic._myPrivateVariable);
  stdout.writeln(myPublic.myPublicVariable);
  // Private instance methods can only be accessed from the same file.
  // myPublic._myPrivateMethod();
  myPublic.myPublicMethod();

  // Private classes can only be accessed from the same file.
  // final myPrivate = _MyPrivate();
}
