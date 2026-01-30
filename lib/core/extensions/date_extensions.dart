import 'package:intl/intl.dart';

extension DateTimeExtension on DateTime {
  String get yMd => DateFormat.yMd().format(this);
  String get yMMMMd => DateFormat.yMMMMd().format(this);
  String get mMMd => DateFormat.MMMd().format(this);

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  DateTime get dateOnly => DateTime(year, month, day);
}
