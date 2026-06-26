import 'package:todo_cat/core/utils/l10n.dart';

const int _minTimestampLength = 1000000000000;

String timestampToDate(int timestamp) {
  if (timestamp < _minTimestampLength) {
    return l10n.unknownDate;
  }

  // 将时间戳转换为 DateTime 对象
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);

  // 将 DateTime 对象格式化为特定日期格式
  String formattedDate =
      "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}";

  return formattedDate;
}

bool isLeapYear(int year, int month) {
  return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
}

int getMonthDayCount(int year, int month) {
  if (month < 1 || month > 12) {
    throw ArgumentError('Invalid month. Month should be between 1 and 12.');
  }

  if (year < 1) {
    throw ArgumentError('Invalid year. Year should be a positive integer.');
  }

  switch (month) {
    case 1: // January
    case 3: // March
    case 5: // May
    case 7: // July
    case 8: // August
    case 10: // October
    case 12: // December
      return 31;
    case 4: // April
    case 6: // June
    case 9: // September
    case 11: // November
      return 30;
    case 2: // February
      return isLeapYear(year, month) ? 29 : 28;

    default:
      throw ArgumentError('Invalid month');
  }
}

List<int> getMonthDays(int year, int month) =>
    List<int>.generate(getMonthDayCount(year, month), (index) => index + 1);

// 获取当前月份的第一天是星期几
int firstDayWeek(DateTime date) {
  final firstDayOfMonth = DateTime(date.year, date.month, 1);
  return firstDayOfMonth.weekday;
}

String getWeekName(DateTime date) {
  Map<int, String> weekMap = {
    1: l10n.monday,
    2: l10n.tuesday,
    3: l10n.wednesday,
    4: l10n.thursday,
    5: l10n.friday,
    6: l10n.saturday,
    7: l10n.sunday,
  };

  return weekMap[date.weekday] ?? l10n.unknown;
}

String getTimeString(DateTime date) =>
    "${date.hour}${l10n.hour} ${date.minute}${l10n.minute}";

/// 将时间戳转换为完整的日期时间字符串（包含时分秒）
String timestampToDateTime(int timestamp) {
  if (timestamp < _minTimestampLength) {
    return l10n.unknownDate;
  }

  // 将时间戳转换为 DateTime 对象
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);

  // 将 DateTime 对象格式化为完整的日期时间格式：年.月.日 时:分:秒
  String formattedDateTime =
      "${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')} "
      "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}";

  return formattedDateTime;
}