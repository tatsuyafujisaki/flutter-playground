// CLI example script that prints output to stdout.
import 'dart:io';

import 'package:stack_trace/stack_trace.dart';

void main() {
  try {
    throw Exception('💀');
  } on Exception catch (error, stackTrace) {
    stderr
      ..writeln(error)
      ..writeln(Trace.from(stackTrace).terse);
  }
}
