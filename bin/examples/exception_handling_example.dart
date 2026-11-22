import 'dart:io';

void main() {
  try {
    throw Exception('💀');
  } on Exception catch (error, stackTrace) {
    stderr
      ..writeln('An error occurred: $error')
      ..writeln(stackTrace);
  }
}
