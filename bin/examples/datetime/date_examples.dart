import 'dart:io';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  final date = DateTime.now();

  stdout
    ..writeln(
      DateFormat('yyyy-MM-dd HH:mm:ss').format(date),
    ) // 2050-01-31 12:34:56
    ..writeln('--');

  await initializeDateFormatting('ja');

  stdout
    ..writeln(DateFormat.MMMEd('ja').format(date)) // 1月31日(月)
    ..writeln(DateFormat.yMMMEd('ja').format(date)) // 2050年1月31日(月)
    ..writeln(DateFormat.Md('ja').format(date)) // 1/31
    ..writeln(DateFormat.MEd('ja').format(date)) // 1/31(月)
    ..writeln(DateFormat.yMEd('ja').format(date)); // 2050/1/31(月)
}
