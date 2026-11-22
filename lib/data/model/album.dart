import 'package:freezed_annotation/freezed_annotation.dart';

part 'album.freezed.dart';
part 'album.g.dart';

/// https://jsonplaceholder.typicode.com/albums/1
@freezed
sealed class Album with _$Album {
  /// Creates an [Album].
  const factory({int? userId, int? id, String? title}) = _Album;

  /// Creates an [Album] from a JSON map.
  factory fromJson(Map<String, dynamic> json) => _$AlbumFromJson(json);
}
