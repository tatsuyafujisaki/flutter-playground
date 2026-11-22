import 'dart:developer' as developer;

class _MyTemplateClass(List<String> myList, [DateTime? dateTime]) {
  final List<String> myList = .unmodifiable(myList);

  final DateTime myDateTime = dateTime ?? .now();
}

void main() {
  final myTemplateClass = _MyTemplateClass(['🍎', '🍊']);
  developer.log(myTemplateClass.myList.toString());
  developer.log(myTemplateClass.myDateTime.toString());
}
