import 'dart:io';

/// https://dart.dev/language/constructors
class _MyClass {
  // Generative constructor
  new(this.sushi, [DateTime? dateTime]) : myDateTime = dateTime ?? .now();

  // Named constructor
  new myNamedConstructor1(this.sushi, [DateTime? dateTime])
    : myDateTime = dateTime ?? .now();

  // Named constructor
  new myNamedConstructor2(String fish, String rice, [DateTime? dateTime])
    : sushi = fish + rice,
      myDateTime = dateTime ?? .now();

  // Redirecting constructor 1
  new myRedirectingConstructor1(String sushi, [DateTime? dateTime])
    : this(sushi, dateTime ?? .now());

  // Redirecting constructor 2
  new myRedirectingConstructor2(String fish, String rice, [DateTime? dateTime])
    : this(fish + rice, dateTime ?? .now());

  final String sushi;
  final DateTime myDateTime;
}

void main() {
  final myClass1 = _MyClass('🍣');
  stdout.writeln(myClass1);
  final myClass2 = _MyClass.myNamedConstructor1('🍣');
  stdout.writeln(myClass2);
  final myClass3 = _MyClass.myNamedConstructor2('🐟', '🍚');
  stdout.writeln(myClass3);
  final myClass4 = _MyClass.myRedirectingConstructor1('🍣');
  stdout.writeln(myClass4);
  final myClass5 = _MyClass.myRedirectingConstructor2('🐟', '🍚');
  stdout.writeln(myClass5);
}
