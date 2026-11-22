import 'dart:io';

class _MyClass {
  final _myNonFinalString = '🍎';
  // Trying to replace myNonFinalString itself outside the class will cause a
  // build error.
  // myTemplateClass.myNonFinalString = '🍏'; // causes a build error.
  String get myFinalString => _myNonFinalString;

  final _myList = <String>['🍎'];

  // Trying to replace myList itself outside the class will cause a build error.
  // myTemplateClass.myList = ['🍏']; // causes a build error.
  //
  // Adding, deleting, or replacing items in myList outside of the class will
  // work.
  // myTemplateClass.myList.clear();
  // myTemplateClass.myList.addAll(['🍏']);
  List<String> get myList => _myList;

  // Trying to replace myUnmodifiableList itself outside the class will cause a
  // build error.
  // myTemplateClass.myUnmodifiableList = ['🍏']; // causes a build error.
  //
  // Trying to add, delete, or replace items in myList outside the class ...
  // ... will throw a runtime exception.
  // myTemplateClass.myUnmodifiableList.clear();
  // myTemplateClass.myUnmodifiableList.addAll(['🍏']);
  List<String> get myUnmodifiableList => .unmodifiable(_myList);
}

void main() {
  final myTemplateClass = _MyClass();

  // myTemplateClass.myNonFinalString = '🍏'; // causes a build error.
  stdout.writeln(myTemplateClass.myFinalString);

  // myTemplateClass.myList = ['🍏']; // causes a build error.
  myTemplateClass.myList
    ..clear()
    ..addAll(['🍏']);
  stdout
    ..writeln(myTemplateClass.myList)
    // myTemplateClass.myUnmodifiableList = ['🍏']; // causes a build error.
    // myTemplateClass.myUnmodifiableList.clear(); // throws a runtime exception.
    // myTemplateClass.myUnmodifiableList.addAll(['🍏']); // throws a runtime exception.
    ..writeln(myTemplateClass.myUnmodifiableList);
}
