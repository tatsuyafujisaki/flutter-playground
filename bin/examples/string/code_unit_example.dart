import 'dart:io';

String _convertToCodeUnitInHex(String character) =>
    '0x${character.codeUnitAt(0).toRadixString(16).toUpperCase()}';

void main() {
  const space = ' ';
  stdout.writeln(_convertToCodeUnitInHex(space)); // 0x20

  const ideographicSpace = '　';
  stdout.writeln(_convertToCodeUnitInHex(ideographicSpace)); // 0x3000

  const lineFeed = '\n';
  stdout.writeln(_convertToCodeUnitInHex(lineFeed)); // 0xA
}
