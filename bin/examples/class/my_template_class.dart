import 'dart:developer' as developer;

class _MyTemplateClass(final List<String> _myList, [DateTime? dateTime]) {
  List<String> get myList => .unmodifiable(_myList);

  final DateTime myDateTime = dateTime ?? .now();
}

void main() {
  final myTemplateClass = _MyTemplateClass(['🍎', '🍊']);
  developer.log(myTemplateClass.myList.toString());
  developer.log(myTemplateClass.myDateTime.toString());
}
