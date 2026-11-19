import 'dart:developer' as developer;

class _MyTemplateClass {
  new(this._myList, [DateTime? dateTime]) : myDateTime = dateTime ?? .now();

  final List<String> _myList;
  List<String> get myList => .unmodifiable(_myList);

  final DateTime myDateTime;
}

void main() {
  final myTemplateClass = _MyTemplateClass(['🍎', '🍊']);
  developer.log(myTemplateClass.myList.toString());
  developer.log(myTemplateClass.myDateTime.toString());
}
