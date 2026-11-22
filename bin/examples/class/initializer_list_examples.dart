import 'dart:io';

class const _Person({
  required final String firstName,
  required String middleName,
  required final String lastName,
}) {
  final String fullName = '$firstName $middleName $lastName';
}

void main() {
  const person = _Person(
    firstName: 'Christopher',
    middleName: 'Robin',
    lastName: 'Milne',
  );
  stdout
    ..writeln(person.firstName)
    ..writeln(person.lastName)
    ..writeln(person.fullName);
}
