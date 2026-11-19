// CLI example script that prints output to stdout.
import 'dart:io';

void main() {
  try {
    throw Exception('💀');
  } on Exception catch (error, stackTrace) {
    stderr
      ..writeln(error)
      ..writeln(stackTrace);
  }
}
