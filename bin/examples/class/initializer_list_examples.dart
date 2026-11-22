import 'dart:developer' as developer;

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
  developer.log(person.firstName);
  developer.log(person.lastName);
  developer.log(person.fullName);
}
