import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

extension TimestampFormatting on Timestamp {
  /// Форматирует Timestamp в строку вида "26.08.2026, 15:30"
  String toFormattedString({String format = 'dd.MM.yyyy, HH:mm', String locale = 'ru'}) {
    final date = toDate();
    return DateFormat(format, locale).format(date);
  }

  /// Возвращает только дату: "26.08.2026"
  String toDateString({String locale = 'ru'}) {
    return DateFormat('dd.MM.yyyy', locale).format(toDate());
  }

  /// Возвращает только время: "15:30"
  String toTimeString({String locale = 'ru'}) {
    return DateFormat('HH:mm', locale).format(toDate());
  }
}
