import 'package:get/get.dart';

const int minTimestampLength = 1000000000000;

String timestampToDate(int timestamp) {
  if (timestamp.isLowerThan(minTimestampLength)) {
    return "unknownDate".tr;
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

List<int> getMonthDays(int year, int month) {
  int monthDayCount = getMonthDayCount(year, month);
  return List<int>.generate(monthDayCount, (index) => index + 1);
}

// 获取当前月份的第一天是星期几
int firstDayWeek(DateTime date) {
  final firstDayOfMonth = DateTime(date.year, date.month, 1);
  return firstDayOfMonth.weekday;
}

String getWeekName(DateTime date) {
  const Map<int, String> weekMap = {
    1: 'monday',
    2: 'tuesday',
    3: 'wednesday',
    4: 'thursday',
    5: 'friday',
    6: 'saturday',
    7: 'sunday',
  };

  return weekMap[date.weekday] ?? 'unknown';
}

String getTimeString(DateTime date) {
  return "${date.hour}${"hour".tr} ${date.minute}${"minute".tr}";
}
