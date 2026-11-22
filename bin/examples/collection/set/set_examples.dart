import 'dart:io';

void _addOrRemove<T>(Set<T> set, T value) {
  if (!set.add(value)) {
    set.remove(value);
  }
}

void main() {
  final fruits = {'🍎', '🍊'};
  _addOrRemove(fruits, '🍏');
  stdout.writeln(fruits);
  _addOrRemove(fruits, '🍏');
  stdout.writeln(fruits);
}
