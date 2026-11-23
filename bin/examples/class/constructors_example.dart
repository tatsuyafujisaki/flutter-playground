import 'dart:io';

/// https://dart.dev/language/constructors
class _MyClass(final String sushi, [DateTime? dateTime]) {
  // Redirecting constructor 1
  new myRedirectingConstructor1(String sushi, [DateTime? dateTime])
    : this(sushi, dateTime);

  // Redirecting constructor 2
  new myRedirectingConstructor2(String fish, String rice, [DateTime? dateTime])
    : this(fish + rice, dateTime);

  final DateTime myDateTime = dateTime ?? .now();
}

void main() {
  final myClass1 = _MyClass('🍣');
  stdout.writeln(myClass1);
  final myClass2 = _MyClass.myRedirectingConstructor1('🍣');
  stdout.writeln(myClass2);
  final myClass3 = _MyClass.myRedirectingConstructor2('🐟', '🍚');
  stdout.writeln(myClass3);
}
