// CLI example script that prints output to stdout.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:xml/xml.dart';

Future<void> main() async {
  final dio = Dio();

  try {
    final response = await dio.get<String>(
      'https://news.google.com/rss',
      options: Options(responseType: .plain, validateStatus: (_) => true),
    );

    if (response.statusCode == 200 && response.data != null) {
      final document = XmlDocument.parse(response.data!);

      final title = document.findAllElements('title').first.innerText;
      stdout
        ..writeln('\nFeed Title: $title')
        ..writeln('--- Recent News ---');

      final items = document.findAllElements('item');

      for (final item in items.take(10)) {
        final itemTitle = item.findElements('title').first.innerText;
        final pubDate = item.findElements('pubDate').first.innerText;
        final link = item.findElements('link').first.innerText;

        stdout
          ..writeln('Title: $itemTitle')
          ..writeln('Date:  $pubDate')
          ..writeln('Link:  $link')
          ..writeln('---');
      }
    } else {
      stderr.writeln(
        'Failed to fetch RSS feed. Status code: ${response.statusCode}',
      );
    }
  } on Exception catch (error, stackTrace) {
    stderr
      ..writeln(error)
      ..writeln(stackTrace);
  } finally {
    dio.close();
  }
}
