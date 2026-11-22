import 'dart:io';

String _trimWhitespace(String s) => s.replaceAll(RegExp(r'\s'), '');
void main() {
  stdout.writeln(_trimWhitespace('🍎 🍏　🍊\n🍇')); // 🍎🍏🍊🍇
}
