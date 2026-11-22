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

    if (response case Response(statusCode: 200, data: final data?)) {
      final document = XmlDocument.parse(data);

      final title =
          document.findAllElements('title').firstOrNull?.innerText ?? '';
      stdout
        ..writeln('\nFeed Title: $title')
        ..writeln('--- Recent News ---');

      final items = document.findAllElements('item');

      for (final item in items.take(10)) {
        final itemTitle = item.getElement('title')?.innerText ?? '';
        final pubDate = item.getElement('pubDate')?.innerText ?? '';
        final link = item.getElement('link')?.innerText ?? '';

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
