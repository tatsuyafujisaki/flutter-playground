import 'dart:io';

class _MyTemplateClass(List<String> myList, [DateTime? dateTime]) {
  final List<String> myList = .unmodifiable(myList);

  final DateTime myDateTime = dateTime ?? .now();
}

void main() {
  final myTemplateClass = _MyTemplateClass(['🍎', '🍊']);
  stdout
    ..writeln(myTemplateClass.myList)
    ..writeln(myTemplateClass.myDateTime);
}
