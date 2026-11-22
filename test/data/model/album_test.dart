import 'package:flutter_playground/data/model/album.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Album', () {
    test('round-trips through JSON serialization', () {
      const album = Album(userId: 1, id: 2, title: 'Playground');
      final json = album.toJson();

      expect(json, {'userId': 1, 'id': 2, 'title': 'Playground'});
      expect(Album.fromJson(json), album);
    });
  });
}
